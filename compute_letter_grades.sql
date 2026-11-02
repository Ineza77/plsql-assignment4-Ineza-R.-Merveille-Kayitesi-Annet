-- Explicit cursor with OPEN / FETCH / CLOSE, %ROWTYPE record, FOR UPDATE + WHERE CURRENT OF.
-- Calls get_letter_grade (function) for each scored enrollment.
CREATE OR REPLACE PROCEDURE compute_letter_grades (
  p_course_id IN  courses.course_id%TYPE,
  p_semester  IN  enrollments.semester%TYPE,
  p_updated   OUT NUMBER
) IS
  CURSOR c_enr IS
    SELECT enrollment_id, score
      FROM enrollments
     WHERE course_id = p_course_id
       AND semester  = p_semester
       AND score IS NOT NULL
       FOR UPDATE OF letter_grade;
  l_row    c_enr%ROWTYPE;
  l_course courses.course_id%TYPE;
BEGIN
  p_updated := 0;
  SELECT course_id INTO l_course FROM courses WHERE course_id = p_course_id;

  OPEN c_enr;
  LOOP
    FETCH c_enr INTO l_row;
    EXIT WHEN c_enr%NOTFOUND;
    UPDATE enrollments
       SET letter_grade = get_letter_grade(l_row.score)
     WHERE CURRENT OF c_enr;
    p_updated := p_updated + SQL%ROWCOUNT;
  END LOOP;
  CLOSE c_enr;

  IF p_updated = 0 THEN
    RAISE_APPLICATION_ERROR(-20031, 'No scored enrollments for ' || p_course_id || ' in ' || p_semester || '.');
  END IF;
  COMMIT;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20030, 'Course ' || p_course_id || ' does not exist.');
  WHEN OTHERS THEN
    IF c_enr%ISOPEN THEN CLOSE c_enr; END IF;
    IF SQLCODE BETWEEN -20999 AND -20000 THEN RAISE; END IF;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20099, 'compute_letter_grades failed: ' || SQLERRM);
END compute_letter_grades;
/
