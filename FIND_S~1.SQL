-- Demonstrates NO_DATA_FOUND and TOO_MANY_ROWS from SELECT INTO.
CREATE OR REPLACE FUNCTION find_student_id_by_last_name (
  p_last_name IN students.last_name%TYPE
) RETURN NUMBER IS
  l_id students.student_id%TYPE;
BEGIN
  SELECT student_id INTO l_id FROM students WHERE UPPER(last_name) = UPPER(p_last_name);
  RETURN l_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20130, 'No student with last name ' || p_last_name || '.');
  WHEN TOO_MANY_ROWS THEN
    RAISE_APPLICATION_ERROR(-20131, 'More than one student has last name ' || p_last_name || '; search by student_id instead.');
END find_student_id_by_last_name;
/
