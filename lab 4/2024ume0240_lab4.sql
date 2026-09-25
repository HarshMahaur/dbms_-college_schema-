USE UniversityDB;
-- Q1. Display the names of students admitted in 2023, sorted by name.
SELECT `Name`
FROM Students
WHERE AdmissionYear = 2023
ORDER BY `Name`;


-- Q2. Find the total number of students in each department.
-- (Students -> Programs -> Departments)

SELECT d.DeptName, COUNT(s.StudentID) AS total_students
FROM Students s, Programs p, Departments d
WHERE s.ProgramID = p.ProgramID
  AND p.DeptID = d.DeptID
GROUP BY d.DeptName;


-- Q3. Find departments having more than 8 students.
-- (Students -> Programs -> Departments)
SELECT d.DeptName, COUNT(s.StudentID) AS total_students
FROM Students s, Programs p, Departments d
WHERE s.ProgramID = p.ProgramID
  AND p.DeptID = d.DeptID
GROUP BY d.DeptName
HAVING COUNT(s.StudentID) > 8;



-- Q4. Display the maximum, minimum, and average marks obtained in each course. (ExamResults -> Exams -> Courses)
SELECT c.CourseID, c.CourseName,
       MAX(er.MarksObtained) AS max_marks,
       MIN(er.MarksObtained) AS min_marks,
       AVG(er.MarksObtained) AS avg_marks
FROM ExamResults er, Exams e, Courses c
WHERE er.ExamID = e.ExamID
  AND e.CourseID = c.CourseID
GROUP BY c.CourseID, c.CourseName;


-- Q5. Retrieve all students who scored between 70 and 100 in any exam.
SELECT DISTINCT s.StudentID, s.`Name`
FROM Students s, ExamResults er
WHERE s.StudentID = er.StudentID
  AND er.MarksObtained BETWEEN 70 AND 100;


-- Q6. Find the number of male, female, and other gender students.
SELECT Gender, COUNT(*) AS total_students
FROM Students
GROUP BY Gender;


-- Q7. Retrieve students whose names start with 's' and were admitted in 2025.
-- the database have the record of the student till 2024*
SELECT StudentID, `Name`, AdmissionYear
FROM Students
WHERE `Name` LIKE 's%'
  AND AdmissionYear = 2025;


-- Q8. List programs where more than 5 students are enrolled.
SELECT p.ProgramName, COUNT(s.StudentID) AS total_students
FROM Programs p, Students s
WHERE p.ProgramID = s.ProgramID
GROUP BY p.ProgramName
HAVING COUNT(s.StudentID) > 5;


-- Q9. Find the top 5 students with the highest marks in any exam.
SELECT s.StudentID, s.`Name`, er.MarksObtained
FROM Students s, ExamResults er
WHERE s.StudentID = er.StudentID
ORDER BY er.MarksObtained DESC
LIMIT 5;


-- Q10. Count how many students each program admitted in 2024.
SELECT p.ProgramName, COUNT(s.StudentID) AS students_admitted_2024
FROM Programs p, Students s
WHERE p.ProgramID = s.ProgramID
  AND s.AdmissionYear = 2024
GROUP BY p.ProgramName;


-- Q11. Find average marks per department (based on exam results).
-- (ExamResults -> Exams -> Courses -> Departments, using Courses.DeptID)
SELECT d.DeptName, AVG(er.MarksObtained) AS avg_marks
FROM ExamResults er, Exams e, Courses c, Departments d
WHERE er.ExamID = e.ExamID
  AND e.CourseID = c.CourseID
  AND c.DeptID = d.DeptID
GROUP BY d.DeptName;


-- Q12. Retrieve all students who do not have an email.
SELECT StudentID, `Name`
FROM Students
WHERE Email IS NULL;
-- this is empty coz all every students have one email id in the database that is also unique


-- Q13. Find courses where the average marks are greater than or equal to 60.
-- (ExamResults -> Exams -> Courses)
SELECT c.CourseID, c.CourseName, AVG(er.MarksObtained) AS avg_marks
FROM ExamResults er, Exams e, Courses c
WHERE er.ExamID = e.ExamID
  AND e.CourseID = c.CourseID
GROUP BY c.CourseID, c.CourseName
HAVING AVG(er.MarksObtained) >= 60;


-- Q14. Display all students with grade 'A' in their enrollments.
SELECT DISTINCT s.StudentID, s.`Name`
FROM Students s, Enrollments en
WHERE s.StudentID = en.StudentID
  AND en.Grade = 'A';
