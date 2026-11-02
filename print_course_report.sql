-- Parameterised explicit cursor in a cursor FOR loop, a user-defined RECORD,
-- and an associative array (indexed by VARCHAR2) for the grade distribution.
CREATE OR REPLACE PROCEDURE print_course_report (
  p_course_id IN courses.course_id%TYPE,
  p_semester  IN enrollments.semester%TYPE
) IS
  l_course courses%ROWTYPE;

  TYPE t_report_rec IS RECORD (
    student_id students.student_id%TYPE,
    full_name  VARCHAR2(120),
    score      enrollments.score%TYPE,
    letter     VARCHAR2(5)
  );
  l_rec t_report_rec;

  TYPE t_dist IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(5);
  l_dist  t_dist;
  l_key   VARCHAR2(5);
  l_total PLS_INTEGER := 0;
  l_avg   NUMBER;

  CURSOR c_rep (cp_course courses.course_id%TYPE, cp_sem enrollments.semester%TYPE) IS
    SELECT s.student_id,
           s.first_name || ' ' || s.last_name AS full_name,
           e.score,
           e.letter_grade
      FROM enrollments e
      JOIN students s ON s.student_id = e.student_id
     WHERE e.course_id = cp_course AND e.semester = cp_sem
     ORDER BY e.score DESC NULLS LAST, s.last_name;
BEGIN
  SELECT * INTO l_course FROM courses WHERE course_id = p_course_id;

  DBMS_OUTPUT.PUT_LINE('=== ' || l_course.course_id || ' - ' || l_course.course_name || ' | ' || p_semester || ' ===');
  DBMS_OUTPUT.PUT_LINE(RPAD('ID', 8) || RPAD('Student', 26) || RPAD('Score', 8) || 'Grade');

  FOR r IN c_rep(p_course_id, p_semester) LOOP
    l_total := l_total + 1;
    l_rec.student_id := r.student_id;
    l_rec.full_name  := r.full_name;
    l_rec.score      := r.score;
    l_rec.letter     := CASE
                          WHEN r.letter_grade IS NOT NULL THEN r.letter_grade
                          WHEN r.score IS NOT NULL        THEN get_letter_grade(r.score)
                          ELSE 'N/A'
                        END;
    DBMS_OUTPUT.PUT_LINE(RPAD(l_rec.student_id, 8) || RPAD(l_rec.full_name, 26)
                         || RPAD(NVL(TO_CHAR(l_rec.score), '-'), 8) || l_rec.letter);

    IF l_dist.EXISTS(l_rec.letter) THEN
      l_dist(l_rec.letter) := l_dist(l_rec.letter) + 1;
    ELSE
      l_dist(l_rec.letter) := 1;
    END IF;
  END LOOP;

  IF l_total = 0 THEN
    RAISE_APPLICATION_ERROR(-20061, 'No enrollments for ' || p_course_id || ' in ' || p_semester || '.');
  END IF;

  DBMS_OUTPUT.PUT_LINE('--- Grade distribution ---');
  l_key := l_dist.FIRST;
  WHILE l_key IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(l_key, 6) || l_dist(l_key));
    l_key := l_dist.NEXT(l_key);
  END LOOP;

  BEGIN
    l_avg := get_course_average(p_course_id, p_semester);
    DBMS_OUTPUT.PUT_LINE('Average score: ' || l_avg || ' (' || l_total || ' enrolled)');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -20121 THEN
        DBMS_OUTPUT.PUT_LINE('Average score: n/a (no scores recorded yet)');
      ELSE
        RAISE;
      END IF;
  END;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20060, 'Course ' || p_course_id || ' does not exist.');
  WHEN OTHERS THEN
    IF SQLCODE BETWEEN -20999 AND -20000 THEN RAISE; END IF;
    RAISE_APPLICATION_ERROR(-20099, 'print_course_report failed: ' || SQLERRM);
END print_course_report;
/
