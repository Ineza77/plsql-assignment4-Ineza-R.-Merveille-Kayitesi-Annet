-- Returns a whole row as a %ROWTYPE record (PL/SQL callers only, not SQL).
CREATE OR REPLACE FUNCTION get_student_record (
  p_student_id IN students.student_id%TYPE
) RETURN students%ROWTYPE IS
  l_rec students%ROWTYPE;
BEGIN
  SELECT * INTO l_rec FROM students WHERE student_id = p_student_id;
  RETURN l_rec;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20140, 'get_student_record: student ' || p_student_id || ' does not exist.');
END get_student_record;
/
