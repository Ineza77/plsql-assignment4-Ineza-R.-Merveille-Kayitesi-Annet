-- Compares row-by-row UPDATE (one SQL call per row) with BULK COLLECT + FORALL
-- (one SQL call for all rows). Both runs are rolled back so the data stays identical.
CREATE OR REPLACE PROCEDURE benchmark_bulk_update (
  p_rows IN PLS_INTEGER DEFAULT 50000
) IS
  TYPE t_id_tab IS TABLE OF perf_test.id%TYPE;
  l_ids       t_id_tab;
  l_t0        NUMBER;
  l_row_cs    NUMBER;
  l_bulk_cs   NUMBER;
BEGIN
  IF p_rows IS NULL OR p_rows NOT BETWEEN 1 AND 200000 THEN
    RAISE_APPLICATION_ERROR(-20070, 'p_rows must be between 1 and 200000.');
  END IF;

  DELETE FROM perf_test;
  INSERT INTO perf_test (id, val) SELECT LEVEL, 0 FROM dual CONNECT BY LEVEL <= p_rows;
  COMMIT;

  -- 1) Row-by-row
  l_t0 := DBMS_UTILITY.GET_TIME;
  FOR r IN (SELECT id FROM perf_test) LOOP
    UPDATE perf_test SET val = val + 1 WHERE id = r.id;
  END LOOP;
  l_row_cs := DBMS_UTILITY.GET_TIME - l_t0;
  ROLLBACK;

  -- 2) Bulk
  l_t0 := DBMS_UTILITY.GET_TIME;
  SELECT id BULK COLLECT INTO l_ids FROM perf_test;
  FORALL i IN 1 .. l_ids.COUNT
    UPDATE perf_test SET val = val + 1 WHERE id = l_ids(i);
  l_bulk_cs := DBMS_UTILITY.GET_TIME - l_t0;
  ROLLBACK;

  DBMS_OUTPUT.PUT_LINE('Rows updated per run : ' || p_rows);
  DBMS_OUTPUT.PUT_LINE('Row-by-row loop      : ' || l_row_cs  * 10 || ' ms');
  DBMS_OUTPUT.PUT_LINE('BULK COLLECT + FORALL: ' || l_bulk_cs * 10 || ' ms');
  IF l_bulk_cs > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Speed-up             : ' || ROUND(l_row_cs / l_bulk_cs, 1) || 'x');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE BETWEEN -20999 AND -20000 THEN RAISE; END IF;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20099, 'benchmark_bulk_update failed: ' || SQLERRM);
END benchmark_bulk_update;
/
