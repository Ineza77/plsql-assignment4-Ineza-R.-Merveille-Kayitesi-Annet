-- ============================================================
-- SUCCESS CASES  (run after schema, sample data, functions, procedures)
-- Re-runnable: removes any 2026-S2 rows it creates.
-- ============================================================
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 160
SET PAGESIZE 50

PROMPT >>> S0: cleanup of semester 2026-S2
DELETE FROM enrollments WHERE semester = '2026-S2';
COMMIT;

PROMPT >>> S1: function get_letter_grade used inside SQL
SELECT enrollment_id, student_id, score, get_letter_grade(score) AS letter
  FROM enrollments
 WHERE course_id = 'INSY8311' AND semester = '2026-S1' AND score IS NOT NULL
 ORDER BY score DESC;

PROMPT >>> S2: compute_letter_grades (explicit cursor OPEN/FETCH/CLOSE, WHERE CURRENT OF)
DECLARE
  l_n NUMBER;
BEGIN
  FOR c IN (SELECT course_id FROM courses WHERE course_id IN ('INSY8311','CSC2101','MAT1101') ORDER BY 1) LOOP
    compute_letter_grades(c.course_id, '2026-S1', l_n);
    DBMS_OUTPUT.PUT_LINE(c.course_id || ': ' || l_n || ' letter grade(s) written');
  END LOOP;
END;
/

PROMPT >>> S3: register_student_course (implicit INSERT cursor, %ROWTYPE)
DECLARE
  l_msg VARCHAR2(200);
BEGIN
  register_student_course(1007, 'INSY8311', '2026-S2', l_msg);
  DBMS_OUTPUT.PUT_LINE(l_msg);
END;
/

PROMPT >>> S4: update_student_status (implicit UPDATE cursor, SQL%ROWCOUNT)
DECLARE
  l_rows NUMBER;
BEGIN
  update_student_status(1009, 'SUSPENDED', l_rows);
  DBMS_OUTPUT.PUT_LINE('Suspended 1009, rows updated: ' || l_rows);
  update_student_status(1009, 'ACTIVE', l_rows);
  DBMS_OUTPUT.PUT_LINE('Reinstated 1009, rows updated: ' || l_rows);
END;
/

PROMPT >>> S5: withdraw_student (implicit DELETE cursor, SQL%FOUND)
DECLARE
  l_rows NUMBER;
BEGIN
  withdraw_student(1007, 'INSY8311', '2026-S2', l_rows);
  DBMS_OUTPUT.PUT_LINE('Rows deleted: ' || l_rows);
END;
/

PROMPT >>> S6: bulk_enroll_students (nested table + FORALL INSERT)
DECLARE
  l_ids      t_number_list := t_number_list(1001, 1002, 1003);
  l_enrolled NUMBER;
  l_failed   NUMBER;
BEGIN
  bulk_enroll_students(l_ids, 'CSC2101', '2026-S2', l_enrolled, l_failed);
  DBMS_OUTPUT.PUT_LINE('Enrolled: ' || l_enrolled || ', failed: ' || l_failed);
END;
/

PROMPT >>> S7: apply_score_curve +5 (BULK COLLECT + FORALL UPDATE), then rolled back
DECLARE
  l_upd NUMBER;
  l_fail NUMBER;
BEGIN
  apply_score_curve('INSY8311', '2026-S1', 5, l_upd, l_fail, FALSE);
  DBMS_OUTPUT.PUT_LINE('Updated: ' || l_upd || ', failed: ' || l_fail);
END;
/
SELECT student_id, score FROM enrollments WHERE course_id = 'INSY8311' AND semester = '2026-S1' ORDER BY score DESC;
ROLLBACK;

PROMPT >>> S8: print_course_report (cursor FOR loop, record, associative array)
BEGIN
  print_course_report('INSY8311', '2026-S1');
  print_course_report('CSC2101',  '2026-S1');
END;
/

PROMPT >>> S9: functions called from SQL and PL/SQL
SELECT student_id, calculate_gpa(student_id) AS gpa_all, calculate_gpa(student_id, '2026-S1') AS gpa_s1
  FROM students WHERE student_id IN (1001, 1002, 1007) ORDER BY student_id;

SELECT course_id, get_course_average(course_id, '2026-S1') AS avg_score
  FROM courses WHERE course_id IN ('INSY8311','CSC2101','MAT1101') ORDER BY course_id;

SELECT s.student_id, s.first_name, s.last_name
  FROM students s
 WHERE s.student_id IN (SELECT COLUMN_VALUE FROM TABLE(get_top_students('INSY8311', '2026-S1', 3)));

DECLARE
  l_id  NUMBER;
  l_rec students%ROWTYPE;
BEGIN
  l_id  := find_student_id_by_last_name('Niyonzima');
  l_rec := get_student_record(l_id);
  DBMS_OUTPUT.PUT_LINE('Found id ' || l_id || ': ' || l_rec.first_name || ' ' || l_rec.last_name
                       || ' <' || l_rec.email || '> status=' || l_rec.status);
END;
/

PROMPT >>> S10: benchmark_bulk_update (row-by-row vs BULK COLLECT + FORALL)
BEGIN
  benchmark_bulk_update(50000);
END;
/

PROMPT >>> S11: final cleanup of 2026-S2
DELETE FROM enrollments WHERE semester = '2026-S2';
COMMIT;
