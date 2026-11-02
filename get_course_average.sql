-- Average score for a course in a semester. Raises an error instead of returning NULL/0 when there is no data.
CREATE OR REPLACE FUNCTION get_course_average (
  p_course_id IN courses.course_id%TYPE,
  p_semester  IN enrollments.semester%TYPE
) RETURN NUMBER IS
  l_course_id courses.course_id%TYPE;
  l_avg       NUMBER;
  l_scored    PLS_INTEGER;
BEGIN
  SELECT course_id INTO l_course_id FROM courses WHERE course_id = p_course_id;

  SELECT AVG(score), COUNT(score) INTO l_avg, l_scored
    FROM enrollments
   WHERE course_id = p_course_id AND semester = p_semester;

  IF l_scored = 0 THEN
    RAISE_APPLICATION_ERROR(-20121, 'get_course_average: no scores for ' || p_course_id || ' in ' || p_semester || '.');
  END IF;
  RETURN ROUND(l_avg, 2);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20120, 'get_course_average: course ' || p_course_id || ' does not exist.');
END get_course_average;
/
