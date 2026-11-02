-- ============================================================
-- Student Registration & Grading System - Schema
-- Re-runnable: drops existing objects first.
-- ============================================================
BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN ('ENROLLMENTS','COURSES','STUDENTS','DEPARTMENTS','PERF_TEST')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
  FOR ty IN (SELECT type_name FROM user_types WHERE type_name = 'T_NUMBER_LIST') LOOP
    EXECUTE IMMEDIATE 'DROP TYPE ' || ty.type_name || ' FORCE';
  END LOOP;
END;
/

-- Schema-level nested table type (usable in SQL and as procedure/function parameter)
CREATE TYPE t_number_list AS TABLE OF NUMBER;
/

CREATE TABLE departments (
  dept_id    NUMBER(4)     CONSTRAINT pk_departments PRIMARY KEY,
  dept_name  VARCHAR2(60)  NOT NULL CONSTRAINT uq_dept_name UNIQUE
);

CREATE TABLE students (
  student_id NUMBER(6)     CONSTRAINT pk_students PRIMARY KEY,
  first_name VARCHAR2(40)  NOT NULL,
  last_name  VARCHAR2(40)  NOT NULL,
  email      VARCHAR2(100) NOT NULL CONSTRAINT uq_student_email UNIQUE
                           CONSTRAINT ck_student_email CHECK (email LIKE '%@%'),
  dept_id    NUMBER(4)     NOT NULL CONSTRAINT fk_student_dept REFERENCES departments(dept_id),
  status     VARCHAR2(10)  DEFAULT 'ACTIVE' NOT NULL
                           CONSTRAINT ck_student_status CHECK (status IN ('ACTIVE','SUSPENDED','GRADUATED'))
);

CREATE TABLE courses (
  course_id   VARCHAR2(10)  CONSTRAINT pk_courses PRIMARY KEY,
  course_name VARCHAR2(80)  NOT NULL,
  credits     NUMBER(2)     NOT NULL CONSTRAINT ck_course_credits CHECK (credits BETWEEN 1 AND 6),
  capacity    NUMBER(4)     NOT NULL CONSTRAINT ck_course_capacity CHECK (capacity > 0),
  dept_id     NUMBER(4)     NOT NULL CONSTRAINT fk_course_dept REFERENCES departments(dept_id)
);

CREATE TABLE enrollments (
  enrollment_id NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_enrollments PRIMARY KEY,
  student_id    NUMBER(6)    NOT NULL CONSTRAINT fk_enr_student REFERENCES students(student_id),
  course_id     VARCHAR2(10) NOT NULL CONSTRAINT fk_enr_course  REFERENCES courses(course_id),
  semester      VARCHAR2(10) NOT NULL,
  score         NUMBER(5,2)  CONSTRAINT ck_enr_score CHECK (score BETWEEN 0 AND 100),
  letter_grade  VARCHAR2(2)  CONSTRAINT ck_enr_letter CHECK (letter_grade IN ('A','B','C','D','F')),
  enrolled_on   DATE         DEFAULT SYSDATE NOT NULL,
  CONSTRAINT uq_enrollment UNIQUE (student_id, course_id, semester)
);

CREATE INDEX idx_enr_course_sem ON enrollments(course_id, semester);

-- Work table used only by benchmark_bulk_update
CREATE TABLE perf_test (
  id  NUMBER PRIMARY KEY,
  val NUMBER
);
