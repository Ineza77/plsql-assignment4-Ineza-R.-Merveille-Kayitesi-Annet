-- Nested-table parameter + FORALL ... SAVE EXCEPTIONS (bulk INSERT).
-- Duplicates (ORA-00001) and unknown students (ORA-02291) are reported per row; valid rows are inserted.
CREATE OR REPLACE PROCEDURE bulk_enroll_students (
  p_student_ids IN  t_number_list,
  p_course_id   IN  courses.course_id%TYPE,
  p_semester    IN  enrollments.semester%TYPE,
  p_enrolled    OUT NUMBER,
  p_failed      OUT NUMBER
) IS
  l_course courses%ROWTYPE;
  l_taken  PLS_INTEGER;
  l_seats  PLS_INTEGER;
  e_bulk_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_bulk_errors, -24381);
BEGIN
  p_enrolled := 0;
  p_failed   := 0;

  IF p_student_ids IS NULL OR p_student_ids.COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20050, 'The list of student ids is empty.');
  END IF;

  SELECT * INTO l_course FROM courses WHERE course_id = p_course_id;
  SELECT COUNT(*) INTO l_taken FROM enrollments WHERE course_id = p_course_id AND semester = p_semester;
  l_seats := l_course.capacity - l_taken;

  IF p_student_ids.COUNT > l_seats THEN
    RAISE_APPLICATION_ERROR(-20052, 'Only ' || l_seats || ' seat(s) left in ' || p_course_id
                            || ' but ' || p_student_ids.COUNT || ' student(s) requested.');
  END IF;

  FORALL i IN 1 .. p_student_ids.COUNT SAVE EXCEPTIONS
    INSERT INTO enrollments (student_id, course_id, semester)
    VALUES (p_student_ids(i), p_course_id, p_semester);

  p_enrolled := SQL%ROWCOUNT;
  COMMIT;
EXCEPTION
  WHEN e_bulk_errors THEN
    p_failed   := SQL%BULK_EXCEPTIONS.COUNT;
    p_enrolled := p_student_ids.COUNT - p_failed;
    FOR j IN 1 .. p_failed LOOP
      DBMS_OUTPUT.PUT_LINE('  Skipped student_id=' || p_student_ids(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX)
                           || ' -> ' || SQLERRM(-SQL%BULK_EXCEPTIONS(j).ERROR_CODE));
    END LOOP;
    COMMIT;
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20051, 'Course ' || p_course_id || ' does not exist.');
  WHEN OTHERS THEN
    IF SQLCODE BETWEEN -20999 AND -20000 THEN RAISE; END IF;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20099, 'bulk_enroll_students failed: ' || SQLERRM);
END bulk_enroll_students;
/
