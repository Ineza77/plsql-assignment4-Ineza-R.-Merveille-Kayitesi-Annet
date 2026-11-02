-- Sample data. Two students share the surname 'Mugisha' on purpose
-- (used to demonstrate TOO_MANY_ROWS). Student 1010 is SUSPENDED on purpose.
INSERT INTO departments VALUES (10, 'Information Systems');
INSERT INTO departments VALUES (20, 'Computer Science');
INSERT INTO departments VALUES (30, 'Mathematics');

INSERT INTO students VALUES (1001,'Alice','Mugisha','alice.mugisha@auca.ac.rw',10,'ACTIVE');
INSERT INTO students VALUES (1002,'Eric','Niyonzima','eric.niyonzima@auca.ac.rw',10,'ACTIVE');
INSERT INTO students VALUES (1003,'Grace','Uwase','grace.uwase@auca.ac.rw',10,'ACTIVE');
INSERT INTO students VALUES (1004,'David','Habimana','david.habimana@auca.ac.rw',20,'ACTIVE');
INSERT INTO students VALUES (1005,'Jean','Mugisha','jean.mugisha@auca.ac.rw',20,'ACTIVE');
INSERT INTO students VALUES (1006,'Sandra','Ingabire','sandra.ingabire@auca.ac.rw',10,'ACTIVE');
INSERT INTO students VALUES (1007,'Patrick','Nshuti','patrick.nshuti@auca.ac.rw',20,'ACTIVE');
INSERT INTO students VALUES (1008,'Clarisse','Uwimana','clarisse.uwimana@auca.ac.rw',30,'ACTIVE');
INSERT INTO students VALUES (1009,'Olivier','Kamanzi','olivier.kamanzi@auca.ac.rw',30,'ACTIVE');
INSERT INTO students VALUES (1010,'Beatrice','Mukamana','beatrice.mukamana@auca.ac.rw',10,'SUSPENDED');

INSERT INTO courses VALUES ('INSY8311','Database Development with PL/SQL',3,30,10);
INSERT INTO courses VALUES ('CSC2101','Data Structures',4,30,20);
INSERT INTO courses VALUES ('MAT1101','Calculus I',3,3,30);        -- capacity 3: becomes full
INSERT INTO courses VALUES ('CSC3000','Capstone Project',6,20,20);  -- no enrollments

-- Semester 2026-S1 enrollments with scores (letter_grade left NULL on purpose;
-- compute_letter_grades fills it in).
INSERT INTO enrollments (student_id, course_id, semester, score) VALUES (1001,'INSY8311','2026-S1',92);
INSERT INTO enrollments (student_id, course_id, semester, score) VALUES (1002,'INSY8311','2026-S1',85);
INSERT INTO enrollments (student_id, course_id, semester, score) VALUES (1003,'INSY8311','2026-S1',74);
INSERT INTO enrollments (student_id, course_id, semester, score) VALUES (1004,'INSY8311','2026-S1',66);
INSERT INTO enrollments (student_id, course_id, semester, score) VALUES (1005,'INSY8311','2026-S1',48);
INSERT INTO enrollments (student_id, course_id, semester, score) VALUES (1006,'INSY8311','2026-S1',NULL);

INSERT INTO enrollments (student_id, course_id, semester, score) VALUES (1001,'CSC2101','2026-S1',88);
INSERT INTO enrollments (student_id, course_id, semester, score) VALUES (1002,'CSC2101','2026-S1',79);
INSERT INTO enrollments (student_id, course_id, semester, score) VALUES (1007,'CSC2101','2026-S1',95);
INSERT INTO enrollments (student_id, course_id, semester, score) VALUES (1008,'CSC2101','2026-S1',58);

INSERT INTO enrollments (student_id, course_id, semester, score) VALUES (1003,'MAT1101','2026-S1',71);
INSERT INTO enrollments (student_id, course_id, semester, score) VALUES (1004,'MAT1101','2026-S1',64);
INSERT INTO enrollments (student_id, course_id, semester, score) VALUES (1005,'MAT1101','2026-S1',55);

COMMIT;
