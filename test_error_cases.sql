-- ============================================================
-- ERROR CASES: every block must print PASS.
-- Each block calls code that should fail and checks the expected error code.
-- Re-runnable: removes any 2026-S2 rows it creates.
-- ============================================================
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 200

DELETE FROM enrollments WHERE semester = '2026-S2';
COMMIT;

-- E1: register: unknown student
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  register_student_course(9999,'INSY8311','2026-S2',l_msg);
  DBMS_OUTPUT.PUT_LINE('E1 FAIL (no error raised): register: unknown student');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E1 ' || CASE WHEN SQLCODE = -20001 THEN 'PASS' ELSE 'FAIL' END
                         || ' | register: unknown student | ' || SQLERRM);
END;
/

-- E2: register: unknown course
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  register_student_course(1001,'XXX0000','2026-S2',l_msg);
  DBMS_OUTPUT.PUT_LINE('E2 FAIL (no error raised): register: unknown course');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E2 ' || CASE WHEN SQLCODE = -20002 THEN 'PASS' ELSE 'FAIL' END
                         || ' | register: unknown course | ' || SQLERRM);
END;
/

-- E3: register: suspended student
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  register_student_course(1010,'INSY8311','2026-S2',l_msg);
  DBMS_OUTPUT.PUT_LINE('E3 FAIL (no error raised): register: suspended student');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E3 ' || CASE WHEN SQLCODE = -20003 THEN 'PASS' ELSE 'FAIL' END
                         || ' | register: suspended student | ' || SQLERRM);
END;
/

-- E4: register: course full (user-defined exception)
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  register_student_course(1001,'MAT1101','2026-S1',l_msg);
  DBMS_OUTPUT.PUT_LINE('E4 FAIL (no error raised): register: course full (user-defined exception)');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E4 ' || CASE WHEN SQLCODE = -20004 THEN 'PASS' ELSE 'FAIL' END
                         || ' | register: course full (user-defined exception) | ' || SQLERRM);
END;
/

-- E5: register: duplicate (DUP_VAL_ON_INDEX)
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  register_student_course(1001,'INSY8311','2026-S1',l_msg);
  DBMS_OUTPUT.PUT_LINE('E5 FAIL (no error raised): register: duplicate (DUP_VAL_ON_INDEX)');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E5 ' || CASE WHEN SQLCODE = -20005 THEN 'PASS' ELSE 'FAIL' END
                         || ' | register: duplicate (DUP_VAL_ON_INDEX) | ' || SQLERRM);
END;
/

-- E6: withdraw: not enrolled (SQL%NOTFOUND)
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  withdraw_student(1001,'MAT1101','2026-S1',l_n);
  DBMS_OUTPUT.PUT_LINE('E6 FAIL (no error raised): withdraw: not enrolled (SQL%NOTFOUND)');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E6 ' || CASE WHEN SQLCODE = -20010 THEN 'PASS' ELSE 'FAIL' END
                         || ' | withdraw: not enrolled (SQL%NOTFOUND) | ' || SQLERRM);
END;
/

-- E7: withdraw: already graded
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  withdraw_student(1001,'INSY8311','2026-S1',l_n);
  DBMS_OUTPUT.PUT_LINE('E7 FAIL (no error raised): withdraw: already graded');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E7 ' || CASE WHEN SQLCODE = -20010 THEN 'PASS' ELSE 'FAIL' END
                         || ' | withdraw: already graded | ' || SQLERRM);
END;
/

-- E8: status: unknown student
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  update_student_status(9999,'ACTIVE',l_n);
  DBMS_OUTPUT.PUT_LINE('E8 FAIL (no error raised): status: unknown student');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E8 ' || CASE WHEN SQLCODE = -20020 THEN 'PASS' ELSE 'FAIL' END
                         || ' | status: unknown student | ' || SQLERRM);
END;
/

-- E9: status: invalid value (ORA-02290 mapped)
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  update_student_status(1001,'FOO',l_n);
  DBMS_OUTPUT.PUT_LINE('E9 FAIL (no error raised): status: invalid value (ORA-02290 mapped)');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E9 ' || CASE WHEN SQLCODE = -20021 THEN 'PASS' ELSE 'FAIL' END
                         || ' | status: invalid value (ORA-02290 mapped) | ' || SQLERRM);
END;
/

-- E10: letter grades: unknown course (NO_DATA_FOUND)
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  compute_letter_grades('XXX0000','2026-S1',l_n);
  DBMS_OUTPUT.PUT_LINE('E10 FAIL (no error raised): letter grades: unknown course (NO_DATA_FOUND)');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E10 ' || CASE WHEN SQLCODE = -20030 THEN 'PASS' ELSE 'FAIL' END
                         || ' | letter grades: unknown course (NO_DATA_FOUND) | ' || SQLERRM);
END;
/

-- E11: letter grades: nothing to grade
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  compute_letter_grades('CSC3000','2026-S1',l_n);
  DBMS_OUTPUT.PUT_LINE('E11 FAIL (no error raised): letter grades: nothing to grade');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E11 ' || CASE WHEN SQLCODE = -20031 THEN 'PASS' ELSE 'FAIL' END
                         || ' | letter grades: nothing to grade | ' || SQLERRM);
END;
/

-- E12: curve: out of range
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  apply_score_curve('INSY8311','2026-S1',500,l_i,l_f,FALSE);
  DBMS_OUTPUT.PUT_LINE('E12 FAIL (no error raised): curve: out of range');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E12 ' || CASE WHEN SQLCODE = -20040 THEN 'PASS' ELSE 'FAIL' END
                         || ' | curve: out of range | ' || SQLERRM);
END;
/

-- E13: curve: no scored rows
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  apply_score_curve('CSC3000','2026-S1',5,l_i,l_f,FALSE);
  DBMS_OUTPUT.PUT_LINE('E13 FAIL (no error raised): curve: no scored rows');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E13 ' || CASE WHEN SQLCODE = -20041 THEN 'PASS' ELSE 'FAIL' END
                         || ' | curve: no scored rows | ' || SQLERRM);
END;
/

-- E14: bulk enroll: empty list
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  bulk_enroll_students(t_number_list(),'CSC2101','2026-S2',l_i,l_f);
  DBMS_OUTPUT.PUT_LINE('E14 FAIL (no error raised): bulk enroll: empty list');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E14 ' || CASE WHEN SQLCODE = -20050 THEN 'PASS' ELSE 'FAIL' END
                         || ' | bulk enroll: empty list | ' || SQLERRM);
END;
/

-- E15: bulk enroll: unknown course
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  bulk_enroll_students(t_number_list(1001),'XXX0000','2026-S2',l_i,l_f);
  DBMS_OUTPUT.PUT_LINE('E15 FAIL (no error raised): bulk enroll: unknown course');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E15 ' || CASE WHEN SQLCODE = -20051 THEN 'PASS' ELSE 'FAIL' END
                         || ' | bulk enroll: unknown course | ' || SQLERRM);
END;
/

-- E16: bulk enroll: not enough seats
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  bulk_enroll_students(t_number_list(1007),'MAT1101','2026-S1',l_i,l_f);
  DBMS_OUTPUT.PUT_LINE('E16 FAIL (no error raised): bulk enroll: not enough seats');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E16 ' || CASE WHEN SQLCODE = -20052 THEN 'PASS' ELSE 'FAIL' END
                         || ' | bulk enroll: not enough seats | ' || SQLERRM);
END;
/

-- E17: report: unknown course
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  print_course_report('XXX0000','2026-S1');
  DBMS_OUTPUT.PUT_LINE('E17 FAIL (no error raised): report: unknown course');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E17 ' || CASE WHEN SQLCODE = -20060 THEN 'PASS' ELSE 'FAIL' END
                         || ' | report: unknown course | ' || SQLERRM);
END;
/

-- E18: report: no enrollments
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  print_course_report('CSC3000','2026-S1');
  DBMS_OUTPUT.PUT_LINE('E18 FAIL (no error raised): report: no enrollments');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E18 ' || CASE WHEN SQLCODE = -20061 THEN 'PASS' ELSE 'FAIL' END
                         || ' | report: no enrollments | ' || SQLERRM);
END;
/

-- E19: benchmark: invalid row count
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  benchmark_bulk_update(0);
  DBMS_OUTPUT.PUT_LINE('E19 FAIL (no error raised): benchmark: invalid row count');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E19 ' || CASE WHEN SQLCODE = -20070 THEN 'PASS' ELSE 'FAIL' END
                         || ' | benchmark: invalid row count | ' || SQLERRM);
END;
/

-- E20: get_letter_grade: NULL
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  l_str := get_letter_grade(NULL);
  DBMS_OUTPUT.PUT_LINE('E20 FAIL (no error raised): get_letter_grade: NULL');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E20 ' || CASE WHEN SQLCODE = -20100 THEN 'PASS' ELSE 'FAIL' END
                         || ' | get_letter_grade: NULL | ' || SQLERRM);
END;
/

-- E21: get_letter_grade: 105
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  l_str := get_letter_grade(105);
  DBMS_OUTPUT.PUT_LINE('E21 FAIL (no error raised): get_letter_grade: 105');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E21 ' || CASE WHEN SQLCODE = -20101 THEN 'PASS' ELSE 'FAIL' END
                         || ' | get_letter_grade: 105 | ' || SQLERRM);
END;
/

-- E22: calculate_gpa: unknown student
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  l_n := calculate_gpa(9999);
  DBMS_OUTPUT.PUT_LINE('E22 FAIL (no error raised): calculate_gpa: unknown student');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E22 ' || CASE WHEN SQLCODE = -20110 THEN 'PASS' ELSE 'FAIL' END
                         || ' | calculate_gpa: unknown student | ' || SQLERRM);
END;
/

-- E23: calculate_gpa: student with no grades
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  l_n := calculate_gpa(1009);
  DBMS_OUTPUT.PUT_LINE('E23 FAIL (no error raised): calculate_gpa: student with no grades');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E23 ' || CASE WHEN SQLCODE = -20111 THEN 'PASS' ELSE 'FAIL' END
                         || ' | calculate_gpa: student with no grades | ' || SQLERRM);
END;
/

-- E24: course average: unknown course
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  l_n := get_course_average('XXX0000','2026-S1');
  DBMS_OUTPUT.PUT_LINE('E24 FAIL (no error raised): course average: unknown course');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E24 ' || CASE WHEN SQLCODE = -20120 THEN 'PASS' ELSE 'FAIL' END
                         || ' | course average: unknown course | ' || SQLERRM);
END;
/

-- E25: course average: no scores
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  l_n := get_course_average('CSC3000','2026-S1');
  DBMS_OUTPUT.PUT_LINE('E25 FAIL (no error raised): course average: no scores');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E25 ' || CASE WHEN SQLCODE = -20121 THEN 'PASS' ELSE 'FAIL' END
                         || ' | course average: no scores | ' || SQLERRM);
END;
/

-- E26: find by last name: none (NO_DATA_FOUND)
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  l_n := find_student_id_by_last_name('Zzzz');
  DBMS_OUTPUT.PUT_LINE('E26 FAIL (no error raised): find by last name: none (NO_DATA_FOUND)');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E26 ' || CASE WHEN SQLCODE = -20130 THEN 'PASS' ELSE 'FAIL' END
                         || ' | find by last name: none (NO_DATA_FOUND) | ' || SQLERRM);
END;
/

-- E27: find by last name: two matches (TOO_MANY_ROWS)
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  l_n := find_student_id_by_last_name('Mugisha');
  DBMS_OUTPUT.PUT_LINE('E27 FAIL (no error raised): find by last name: two matches (TOO_MANY_ROWS)');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E27 ' || CASE WHEN SQLCODE = -20131 THEN 'PASS' ELSE 'FAIL' END
                         || ' | find by last name: two matches (TOO_MANY_ROWS) | ' || SQLERRM);
END;
/

-- E28: get_student_record: unknown student
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  l_r := get_student_record(9999);
  DBMS_OUTPUT.PUT_LINE('E28 FAIL (no error raised): get_student_record: unknown student');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E28 ' || CASE WHEN SQLCODE = -20140 THEN 'PASS' ELSE 'FAIL' END
                         || ' | get_student_record: unknown student | ' || SQLERRM);
END;
/

-- E29: top students: n = 0
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  l_ids := get_top_students('INSY8311','2026-S1',0);
  DBMS_OUTPUT.PUT_LINE('E29 FAIL (no error raised): top students: n = 0');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E29 ' || CASE WHEN SQLCODE = -20150 THEN 'PASS' ELSE 'FAIL' END
                         || ' | top students: n = 0 | ' || SQLERRM);
END;
/

-- E30: top students: nothing graded
DECLARE
  l_msg VARCHAR2(200); l_str VARCHAR2(200);
  l_n NUMBER; l_i NUMBER; l_f NUMBER;
  l_r students%ROWTYPE; l_ids t_number_list;
BEGIN
  l_ids := get_top_students('CSC3000','2026-S1',3);
  DBMS_OUTPUT.PUT_LINE('E30 FAIL (no error raised): top students: nothing graded');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('E30 ' || CASE WHEN SQLCODE = -20151 THEN 'PASS' ELSE 'FAIL' END
                         || ' | top students: nothing graded | ' || SQLERRM);
END;
/

-- ------------------------------------------------------------
-- Partial-failure demos: bulk DML errors are collected, valid rows still succeed.
-- ------------------------------------------------------------
PROMPT >>> B1: apply_score_curve +10 -> score 92 would become 102 (violates ck_enr_score)
DECLARE
  l_upd NUMBER; l_fail NUMBER;
BEGIN
  apply_score_curve('INSY8311', '2026-S1', 10, l_upd, l_fail, FALSE);
  DBMS_OUTPUT.PUT_LINE('B1 ' || CASE WHEN l_fail = 1 AND l_upd = 5 THEN 'PASS' ELSE 'FAIL' END
                       || ' | updated=' || l_upd || ' failed=' || l_fail);
END;
/
ROLLBACK;

PROMPT >>> B2: bulk_enroll_students with a duplicate id and an unknown id
DECLARE
  l_ids t_number_list := t_number_list(1001, 1001, 9999, 1002);
  l_ok NUMBER; l_fail NUMBER;
BEGIN
  bulk_enroll_students(l_ids, 'CSC2101', '2026-S2', l_ok, l_fail);
  DBMS_OUTPUT.PUT_LINE('B2 ' || CASE WHEN l_ok = 2 AND l_fail = 2 THEN 'PASS' ELSE 'FAIL' END
                       || ' | enrolled=' || l_ok || ' failed=' || l_fail);
END;
/

DELETE FROM enrollments WHERE semester = '2026-S2';
COMMIT;
