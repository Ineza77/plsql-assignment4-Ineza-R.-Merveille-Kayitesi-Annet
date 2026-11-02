-- Implicit DELETE cursor: SQL%FOUND / SQL%NOTFOUND / SQL%ROWCOUNT.
-- Only ungraded enrollments can be withdrawn.
CREATE OR REPLACE PROCEDURE withdraw_student (
  p_student_id   IN  students.student_id%TYPE,
  p_course_id    IN  courses.course_id%TYPE,
  p_semester     IN  enrollments.semester%TYPE,
  p_rows_deleted OUT NUMBER
) IS
BEGIN
  DELETE FROM enrollments
   WHERE student_id = p_student_id
     AND course_id  = p_course_id
     AND semester   = p_semester
     AND score IS NULL;

  p_rows_deleted := SQL%ROWCOUNT;

  IF SQL%NOTFOUND THEN
    RAISE_APPLICATION_ERROR(-20010, 'No ungraded enrollment found for student ' || p_student_id
                            || ' in ' || p_course_id || ' (' || p_semester || ').');
  END IF;

  IF SQL%FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Withdrawn: ' || p_rows_deleted || ' enrollment(s) removed.');
  END IF;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE BETWEEN -20999 AND -20000 THEN RAISE; END IF;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20099, 'withdraw_student failed: ' || SQLERRM);
END withdraw_student;
/
