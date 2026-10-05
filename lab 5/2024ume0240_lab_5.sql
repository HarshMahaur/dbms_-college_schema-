USE UniversityDB;

-- Q1. Using DISTINCT

-- Q1.1 Unique departments from which students are enrolled.
-- (Students -> Programs -> Departments)
SELECT DISTINCT d.DeptName
FROM Students s, Programs p, Departments d
WHERE s.ProgramID = p.ProgramID
  AND p.DeptID = d.DeptID;

-- Q1.2 All distinct exam dates scheduled in the database.
SELECT DISTINCT ExamDate
FROM Exams;


-- Q2. Using LIMIT

-- Q2.1 Top 5 students with the highest marks in any exam.
SELECT s.StudentID, s.`Name`, er.MarksObtained
FROM Students s, ExamResults er
WHERE s.StudentID = er.StudentID
ORDER BY er.MarksObtained DESC
LIMIT 5;

-- Q2.2 First 10 students admitted to the University (AdmissionYear ascending).
SELECT StudentID, `Name`, AdmissionYear
FROM Students
ORDER BY AdmissionYear ASC
LIMIT 10;


-- Q3. Using USING in Joins

-- Q3.1 Student names and their enrolled courses.
SELECT s.`Name`, c.CourseName
FROM Students s
JOIN Enrollments en USING (StudentID)
JOIN Courses c USING (CourseID);

-- Q3.2 Books issued along with student names.
SELECT s.`Name`, lb.Title
FROM BookIssues bi
JOIN LibraryBooks lb USING (BookID)
JOIN Students s USING (StudentID);


-- Q4. Using UNION

-- Q4.1 Students who are in a Computer Science program OR staying in a hostel.
SELECT s.`Name`
FROM Students s, Programs p, Departments d
WHERE s.ProgramID = p.ProgramID
  AND p.DeptID = d.DeptID
  AND d.DeptName = 'Computer Science'
UNION
SELECT s.`Name`
FROM Students s, HostelAllotment h
WHERE s.StudentID = h.StudentID;

-- Q4.2 Names of all Faculty and Students in one result set.
SELECT `Name` FROM Faculty
UNION
SELECT `Name` FROM Students;


-- Q5. Simulating INTERSECT (MySQL has no INTERSECT operator)

-- Q5.1 Students who have issued books from the library AND have pending payments.
SELECT DISTINCT s.StudentID, s.`Name`
FROM Students s
WHERE s.StudentID IN (SELECT StudentID FROM BookIssues)
  AND s.StudentID IN (SELECT StudentID FROM Payments WHERE Status = 'Pending');

-- Q5.2 Students enrolled in more than one course AND who have also appeared in exams.
SELECT s.StudentID, s.`Name`
FROM Students s
WHERE s.StudentID IN (
        SELECT StudentID
        FROM Enrollments
        GROUP BY StudentID
        HAVING COUNT(DISTINCT CourseID) > 1
      )
  AND s.StudentID IN (SELECT StudentID FROM ExamResults);


-- Q6. Simulating EXCEPT (MySQL has no EXCEPT operator)

-- Q6.1 Students who enrolled in courses but never appeared in exams.
SELECT DISTINCT s.StudentID, s.`Name`
FROM Students s
JOIN Enrollments en ON s.StudentID = en.StudentID
WHERE s.StudentID NOT IN (SELECT StudentID FROM ExamResults);

-- Q6.2 Students who have never stayed in any hostel.
SELECT s.StudentID, s.`Name`
FROM Students s
WHERE s.StudentID NOT IN (SELECT StudentID FROM HostelAllotment);


-- Q7. Using WITH (Common Table Expressions)

-- Q7.1 Average marks per department; select the department(s) with the highest average.
-- (ExamResults -> Exams -> Courses -> Departments, using Courses.DeptID)
WITH DeptAvg AS (
    SELECT d.DeptID, d.DeptName, AVG(er.MarksObtained) AS avg_marks
    FROM ExamResults er, Exams e, Courses c, Departments d
    WHERE er.ExamID = e.ExamID
      AND e.CourseID = c.CourseID
      AND c.DeptID = d.DeptID
    GROUP BY d.DeptID, d.DeptName
)
SELECT DeptName, avg_marks
FROM DeptAvg
WHERE avg_marks = (SELECT MAX(avg_marks) FROM DeptAvg);

-- Q7.2 Students with total fees paid greater than 50,000.
WITH TotalPaid AS (
    SELECT StudentID, SUM(Amount) AS total_paid
    FROM Payments
    WHERE Status = 'Paid'
    GROUP BY StudentID
)
SELECT s.StudentID, s.`Name`, tp.total_paid
FROM Students s
JOIN TotalPaid tp ON s.StudentID = tp.StudentID
WHERE tp.total_paid > 50000;


-- Q8. Upsert (INSERT ... ON DUPLICATE KEY UPDATE, in place of MERGE)

-- Required unique key so the upsert can identify a specific payment occasion
-- (a student can legitimately have several payments of the same type across
-- different dates, so (StudentID, PaymentType) alone would be too restrictive).
ALTER TABLE Payments
ADD UNIQUE (StudentID, PaymentType, `Date`);

-- Merge new fee payment data into Payments:
--  - Row 1 matches an existing (StudentID, PaymentType, Date) combination
--    (StudentID 1, 'Tuition', '2026-01-05' already exists as PaymentID 1) ->
--    this UPDATES that existing row's Amount/Status instead of inserting a duplicate.
--  - Row 2 has a (StudentID, PaymentType, Date) combination that does not exist yet ->
--    this INSERTS a new row.
INSERT INTO Payments
    (PaymentID, StudentID, `Date`, Amount, PaymentType, Status)
VALUES
    (51, 1, '2026-01-05', 55000, 'Tuition', 'Paid'),
    (52, 1, '2026-07-01', 300,   'Fine',    'Paid')
ON DUPLICATE KEY UPDATE
    Amount = VALUES(Amount),
    Status = VALUES(Status);
