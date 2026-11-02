-- Implicit UPDATE cursor + exception mapped to a check constraint violation (ORA-02290).
CREATE OR REPLACE PROCEDURE update_student_status (
  p_student_id IN  students.student_id%TYPE,
  p_status     IN  students.status%TYPE,
  p_rows       OUT NUMBER
) IS
  e_bad_status EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_bad_status, -2290);
BEGIN
  UPDATE students SET status = p_status WHERE student_id = p_student_id;
  p_rows := SQL%ROWCOUNT;

  IF SQL%NOTFOUND THEN
    RAISE_APPLICATION_ERROR(-20020, 'Student ' || p_student_id || ' does not exist.');
  END IF;
  COMMIT;
EXCEPTION
  WHEN e_bad_status THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20021, 'Invalid status ''' || p_status || ''' (use ACTIVE, SUSPENDED or GRADUATED).');
  WHEN OTHERS THEN
    IF SQLCODE BETWEEN -20999 AND -20000 THEN RAISE; END IF;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20099, 'update_student_status failed: ' || SQLERRM);
END update_student_status;
/
