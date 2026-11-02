-- Converts a numeric score to a letter grade. Invalid input raises an error
-- (it never silently returns a misleading grade).
CREATE OR REPLACE FUNCTION get_letter_grade (
  p_score IN NUMBER
) RETURN VARCHAR2 DETERMINISTIC IS
BEGIN
  IF p_score IS NULL THEN
    RAISE_APPLICATION_ERROR(-20100, 'get_letter_grade: score cannot be NULL.');
  ELSIF p_score < 0 OR p_score > 100 THEN
    RAISE_APPLICATION_ERROR(-20101, 'get_letter_grade: score must be between 0 and 100, got ' || p_score);
  END IF;

  RETURN CASE
           WHEN p_score >= 90 THEN 'A'
           WHEN p_score >= 80 THEN 'B'
           WHEN p_score >= 70 THEN 'C'
           WHEN p_score >= 60 THEN 'D'
           ELSE 'F'
         END;
END get_letter_grade;
/
