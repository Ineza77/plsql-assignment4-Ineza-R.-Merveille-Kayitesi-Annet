-- Registers one student in one course. Uses %ROWTYPE records, an implicit INSERT cursor
-- (SQL%ROWCOUNT), predefined exceptions, user-defined exceptions and RAISE_APPLICATION_ERROR.
CREATE OR REPLACE PROCEDURE register_student_course (
  p_student_id IN  students.student_id%TYPE,
  p_course_id  IN  courses.course_id%TYPE,
  p_semester   IN  enrollments.semester%TYPE,
  p_message    OUT VARCHAR2
) IS
  l_student     students%ROWTYPE;
  l_course      courses%ROWTYPE;
  l_enrolled    PLS_INTEGER;
  l_step        VARCHAR2(10);
  e_not_active  EXCEPTION;
  e_course_full EXCEPTION;
BEGIN
  l_step := 'STUDENT';
  SELECT * INTO l_student FROM students WHERE student_id = p_student_id;
  IF l_student.status <> 'ACTIVE' THEN
    RAISE e_not_active;
  END IF;

  l_step := 'COURSE';
  SELECT * INTO l_course FROM courses WHERE course_id = p_course_id;

  SELECT COUNT(*) INTO l_enrolled
    FROM enrollments WHERE course_id = p_course_id AND semester = p_semester;
  IF l_enrolled >= l_course.capacity THEN
    RAISE e_course_full;
  END IF;

  INSERT INTO enrollments (student_id, course_id, semester)
  VALUES (p_student_id, p_course_id, p_semester);

  IF SQL%ROWCOUNT = 1 THEN
    p_message := l_student.first_name || ' ' || l_student.last_name || ' registered in '
                 || l_course.course_name || ' (' || p_semester || ').';
  END IF;
  COMMIT;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF l_step = 'STUDENT' THEN
      RAISE_APPLICATION_ERROR(-20001, 'Student ' || p_student_id || ' does not exist.');
    ELSE
      RAISE_APPLICATION_ERROR(-20002, 'Course ' || p_course_id || ' does not exist.');
    END IF;
  WHEN e_not_active THEN
    RAISE_APPLICATION_ERROR(-20003, 'Student ' || p_student_id || ' is ' || l_student.status || ' and cannot register.');
  WHEN e_course_full THEN
    RAISE_APPLICATION_ERROR(-20004, 'Course ' || p_course_id || ' is full (' || l_course.capacity || ' seats) for ' || p_semester || '.');
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20005, 'Student ' || p_student_id || ' is already registered in ' || p_course_id || ' for ' || p_semester || '.');
  WHEN OTHERS THEN
    IF SQLCODE BETWEEN -20999 AND -20000 THEN RAISE; END IF;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20099, 'register_student_course failed: ' || SQLERRM);
END register_student_course;
/
