# Student Registration & Grading System (Oracle PL/SQL)

**Course:** Database Development with PL/SQL (INSY 8311) - Group Assignment IV
**Group members**

| Name | Student ID |
|------|-----------|
| _Full name 1_ | _ID 1_ |
| _Full name 2_ | _ID 2_ |

## 1. Application description

A university registers students in courses each semester, records scores, converts scores to letter
grades and reports results. The database enforces the rules (capacity, unique registration, valid score
range) and the PL/SQL layer implements the business operations as stored procedures and functions.

### Requirements
- Register a student in a course for a semester (student must exist and be ACTIVE, course must exist, seats available, no duplicate registration).
- Withdraw a student from a course (only while ungraded).
- Change a student's status (ACTIVE / SUSPENDED / GRADUATED).
- Enrol many students at once; report the ones that fail without losing the ones that succeed.
- Apply a score curve to a whole class in bulk; skip rows that would break the 0-100 rule.
- Derive letter grades, GPA (credit-weighted), course averages, top-N students.
- Print a course report with grade distribution.

## 2. Schema

```
departments (dept_id PK, dept_name UQ)
    |1                      |1
    |N                      |N
students (student_id PK, ..., dept_id FK, status CK)     courses (course_id PK, credits CK, capacity CK, dept_id FK)
    |1                                                        |1
    |N                                                        |N
              enrollments (enrollment_id PK identity, student_id FK, course_id FK, semester,
                           score CK 0..100, letter_grade CK, UNIQUE(student_id, course_id, semester))
perf_test (id PK, val)   -- work table for the bulk-processing benchmark
```
Types: `t_number_list` (schema-level nested table of NUMBER).

## 3. Where each concept is demonstrated

| Requirement | Where |
|---|---|
| %ROWTYPE records | `register_student_course`, `compute_letter_grades` (cursor %ROWTYPE), `get_student_record` |
| User-defined records | `print_course_report` (`t_report_rec`), `calculate_gpa` (`t_grade_rec`) |
| Associative array | `print_course_report` (`t_dist`, indexed by VARCHAR2) |
| Nested table | `t_number_list` in `bulk_enroll_students`, `get_top_students` |
| Local collections via BULK COLLECT | `apply_score_curve`, `calculate_gpa`, `benchmark_bulk_update` |
| Implicit cursors | INSERT: `register_student_course`; UPDATE: `update_student_status`; DELETE: `withdraw_student` (`SQL%ROWCOUNT`, `SQL%FOUND`, `SQL%NOTFOUND`) |
| Explicit cursors | OPEN/FETCH/CLOSE + `WHERE CURRENT OF`: `compute_letter_grades`; parameterised cursor FOR loop: `print_course_report` |
| BULK COLLECT / FORALL | `apply_score_curve` (UPDATE), `bulk_enroll_students` (INSERT), `benchmark_bulk_update` |
| Bulk DML errors | `SAVE EXCEPTIONS` + `SQL%BULK_EXCEPTIONS` (ORA-24381) in the two bulk procedures |
| Predefined exceptions | `NO_DATA_FOUND`, `TOO_MANY_ROWS` (`find_student_id_by_last_name`), `DUP_VAL_ON_INDEX` |
| User-defined exceptions | `e_not_active`, `e_course_full`, `e_bulk_errors`, `e_bad_status` (`EXCEPTION_INIT`) |
| RAISE_APPLICATION_ERROR | every procedure/function (codes in section 5) |

## 4. How to run

Requires Oracle 12c or later (identity columns). Use SQL*Plus, SQLcl or SQL Developer, connected as the schema owner.

1. `00_schema/01_create_tables.sql`
2. `00_schema/02_insert_sample_data.sql`
3. Compile `02_functions/*.sql` **before** `01_procedures/*.sql` (procedures call `get_letter_grade` and `get_course_average`). If you compile in the other order, run `EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE);` afterwards.
4. Run `03_tests/test_success_cases.sql`, then `03_tests/test_error_cases.sql` (with `SET SERVEROUTPUT ON`). Every error test prints `PASS`.
5. Take screenshots into `screenshots/` (one per test, e.g. `S2_compute_letter_grades_output.png`).

Shortcut from the repository root in SQL*Plus/SQLcl: `@run_all.sql`

## 5. Error codes

| Range | Source |
|---|---|
| -20001..-20005 | `register_student_course` (student missing, course missing, not active, course full, duplicate) |
| -20010 | `withdraw_student` |
| -20020, -20021 | `update_student_status` |
| -20030, -20031 | `compute_letter_grades` |
| -20040, -20041 | `apply_score_curve` |
| -20050..-20052 | `bulk_enroll_students` |
| -20060, -20061 | `print_course_report` |
| -20070 | `benchmark_bulk_update` |
| -20099 | unexpected error (original `SQLERRM` is included, never swallowed) |
| -20100..-20151 | functions |

## 6. AI assistance disclosure

An AI assistant (Claude, by Anthropic) was used to draft the initial version of the schema, PL/SQL code,
tests and documentation. _Edit this section to describe what your group reviewed, ran, changed and tested yourselves._
Both members have read, executed and can explain all code in this repository.

See `docs/IMPLEMENTATION_NOTES.md` for implementation and performance notes.
