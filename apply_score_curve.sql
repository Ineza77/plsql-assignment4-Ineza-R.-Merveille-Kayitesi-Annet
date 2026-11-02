-- BULK COLLECT + FORALL ... SAVE EXCEPTIONS (bulk UPDATE).
-- Adds p_curve points to every scored enrollment. Rows that would violate ck_enr_score
-- (score > 100 or < 0) are skipped and reported; the rest are updated.
-- p_commit => FALSE lets tests inspect results and then ROLLBACK.
CREATE OR REPLACE PROCEDURE apply_score_curve (
  p_course_id IN  courses.course_id%TYPE,
  p_semester  IN  enrollments.semester%TYPE,
  p_curve     IN  NUMBER,
  p_updated   OUT NUMBER,
  p_failed    OUT NUMBER,
  p_commit    IN  BOOLEAN DEFAULT TRUE
) IS
  TYPE t_id_tab    IS TABLE OF enrollments.enrollment_id%TYPE;
  TYPE t_score_tab IS TABLE OF enrollments.score%TYPE;
  l_ids    t_id_tab;
  l_scores t_score_tab;
  e_bulk_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_bulk_errors, -24381);
BEGIN
  p_updated := 0;
  p_failed  := 0;

  IF p_curve IS NULL OR p_curve NOT BETWEEN -100 AND 100 THEN
    RAISE_APPLICATION_ERROR(-20040, 'Curve must be between -100 and 100.');
  END IF;

  SELECT enrollment_id, score
    BULK COLLECT INTO l_ids, l_scores
    FROM enrollments
   WHERE course_id = p_course_id AND semester = p_semester AND score IS NOT NULL;

  IF l_ids.COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20041, 'No scored enrollments for ' || p_course_id || ' in ' || p_semester || '.');
  END IF;

  FORALL i IN 1 .. l_ids.COUNT SAVE EXCEPTIONS
    UPDATE enrollments
       SET score = l_scores(i) + p_curve
     WHERE enrollment_id = l_ids(i);

  p_updated := SQL%ROWCOUNT;
  IF p_commit THEN COMMIT; END IF;
EXCEPTION
  WHEN e_bulk_errors THEN
    p_failed  := SQL%BULK_EXCEPTIONS.COUNT;
    p_updated := l_ids.COUNT - p_failed;
    FOR j IN 1 .. p_failed LOOP
      DBMS_OUTPUT.PUT_LINE('  Skipped enrollment_id=' || l_ids(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX)
                           || ' -> ' || SQLERRM(-SQL%BULK_EXCEPTIONS(j).ERROR_CODE));
    END LOOP;
    IF p_commit THEN COMMIT; END IF;   -- keep the rows that succeeded
  WHEN OTHERS THEN
    IF SQLCODE BETWEEN -20999 AND -20000 THEN RAISE; END IF;
    IF p_commit THEN ROLLBACK; END IF;
    RAISE_APPLICATION_ERROR(-20099, 'apply_score_curve failed: ' || SQLERRM);
END apply_score_curve;
/
