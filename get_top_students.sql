-- Returns the ids of the top-N scorers as a nested table (collection), queryable with TABLE().
CREATE OR REPLACE FUNCTION get_top_students (
  p_course_id IN courses.course_id%TYPE,
  p_semester  IN enrollments.semester%TYPE,
  p_n         IN PLS_INTEGER DEFAULT 3
) RETURN t_number_list IS
  l_ids t_number_list;
BEGIN
  IF p_n IS NULL OR p_n < 1 THEN
    RAISE_APPLICATION_ERROR(-20150, 'get_top_students: p_n must be >= 1.');
  END IF;

  SELECT student_id BULK COLLECT INTO l_ids
    FROM (SELECT student_id FROM enrollments
           WHERE course_id = p_course_id AND semester = p_semester AND score IS NOT NULL
           ORDER BY score DESC, student_id)
   WHERE ROWNUM <= p_n;

  IF l_ids.COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20151, 'get_top_students: no graded students for ' || p_course_id || ' in ' || p_semester || '.');
  END IF;
  RETURN l_ids;
END get_top_students;
/
