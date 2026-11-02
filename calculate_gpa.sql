-- Credit-weighted GPA on a 4.0 scale (A=4,B=3,C=2,D=1,F=0).
-- p_semester NULL = all semesters. Uses BULK COLLECT into a collection of user-defined records.
CREATE OR REPLACE FUNCTION calculate_gpa (
  p_student_id IN students.student_id%TYPE,
  p_semester   IN enrollments.semester%TYPE DEFAULT NULL
) RETURN NUMBER IS
  TYPE t_grade_rec IS RECORD (
    credits courses.credits%TYPE,
    score   enrollments.score%TYPE
  );
  TYPE t_grade_tab IS TABLE OF t_grade_rec;
  l_rows    t_grade_tab;
  l_exists  students.student_id%TYPE;
  l_points  NUMBER := 0;
  l_credits NUMBER := 0;
  l_pts     NUMBER;
BEGIN
  SELECT student_id INTO l_exists FROM students WHERE student_id = p_student_id;  -- NO_DATA_FOUND if absent

  SELECT c.credits, e.score
    BULK COLLECT INTO l_rows
    FROM enrollments e
    JOIN courses c ON c.course_id = e.course_id
   WHERE e.student_id = p_student_id
     AND e.score IS NOT NULL
     AND (p_semester IS NULL OR e.semester = p_semester);

  IF l_rows.COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20111, 'calculate_gpa: student ' || p_student_id || ' has no graded courses.');
  END IF;

  FOR i IN 1 .. l_rows.COUNT LOOP
    l_pts := CASE get_letter_grade(l_rows(i).score)
               WHEN 'A' THEN 4 WHEN 'B' THEN 3 WHEN 'C' THEN 2 WHEN 'D' THEN 1 ELSE 0 END;
    l_points  := l_points  + l_pts * l_rows(i).credits;
    l_credits := l_credits + l_rows(i).credits;
  END LOOP;

  RETURN ROUND(l_points / l_credits, 2);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20110, 'calculate_gpa: student ' || p_student_id || ' does not exist.');
END calculate_gpa;
/
