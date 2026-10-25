USE UniversityDB;

-- Q1. INNER JOIN

-- Q1.1 All students along with their department name. Students - Programs - Departments
select s.StudentID, s.`Name`, d.DeptName
from Students s
join Programs p ON s.ProgramID = p.ProgramID
join Departments d ON p.DeptID = d.DeptID;

-- Q1.2 All courses along with the faculty name who teaches them.
select  c.CourseName, f.`Name` AS FacultyName
from Courses c
join CourseFaculty cf ON c.CourseID = cf.CourseID
join Faculty f ON cf.FacultyID = f.FacultyID;


-- Q2. LEFT OUTER JOIN
-- Q2.1 All programs along with the names of students enrolled in them
-- (a student's program is Students.ProgramID directly, not the Enrollments
-- table, which tracks course enrollment); programs with no students show NULL.
SELECT p.ProgramName, s.StudentID, s.`Name`
FROM Programs p
LEFT JOIN Students s ON p.ProgramID = s.ProgramID
ORDER BY p.ProgramName;

-- Q2.2 All departments and the names of their HOD, even if no HOD is assigned.
select d.DeptName, f.`Name` AS HODName
from  Departments d
left JOIN Faculty f ON d.HODFacultyID = f.FacultyID;


-- Q3. RIGHT OUTER JOIN


-- Q3.1 All hostels along with room number and student details for each
-- occupied room; hostels with no occupied rooms are still shown (RIGHT JOIN
-- keeps every row of Hostels regardless of matches in HostelAllotment/Students).
SELECT h.HostelName, ha.RoomNo, s.StudentID, s.`Name`
FROM HostelAllotment ha
JOIN Students s ON ha.StudentID = s.StudentID
RIGHT JOIN Hostels h ON ha.HostelID = h.HostelID
ORDER BY h.HostelName;


-- Q4. FULL OUTER JOIN (Simulated via LEFT JOIN + UNION + LEFT JOIN)

-- Q4.1 All books and all students who have borrowed them via BookIssues.
-- Books never issued and students who never borrowed are both included.
SELECT lb.Title, s.StudentID, s.`Name`
from LibraryBooks lb
LEFT JOIN BookIssues bi ON lb.BookID = bi.BookID
LEFT JOIN Students s ON bi.StudentID = s.StudentID
union
SELECT lb.Title, s.StudentID, s.`Name`
FROM Students s
left join BookIssues bi ON s.StudentID = bi.StudentID
left  join LibraryBooks lb ON bi.BookID = lb.BookID;


-- Q5. Aggregation with JOINs

-- Q5.1 Total students enrolled per department, including departments with none.
select d.DeptName, COUNT(s.StudentID) AS total_students
FROM Departments d
left JOIN Programs p ON d.DeptID = p.DeptID
left JOIN Students s ON p.ProgramID = s.ProgramID
group BY d.DeptName;

-- Q5.2 For each course-semester combination: number of enrolled students
-- and the name of the faculty member who taught it.
SELECT c.CourseName, en.Semester,
       COUNT(DISTINCT en.StudentID) AS total_enrolled,
       f.`Name` AS FacultyName
FROM Courses c
JOIN Enrollments en ON c.CourseID = en.CourseID
LEFT JOIN CourseFaculty cf ON c.CourseID = cf.CourseID AND en.Semester = cf.Semester
LEFT JOIN Faculty f ON cf.FacultyID = f.FacultyID
GROUP BY c.CourseName, en.Semester, f.`Name`;


-- Q6. Conditional JOINs

-- Q6.1 Students with at least one Attendance record with Status = 'Late',
-- together with their department name.
select DISTINCT s.StudentID, s.`Name`, d.DeptName
from Students s
join Programs p ON s.ProgramID = p.ProgramID
join Departments d ON p.DeptID = d.DeptID
join Attendance a ON s.StudentID = a.StudentID
WHERE a.Status = 'Late';

-- Q6.2 All students along with their payments (pending and paid) and payment
-- types, including students who have no payment records.
select s.StudentID, s.`Name`, py.Amount, py.PaymentType, py.Status
from  Students s
left JOIN Payments py ON s.StudentID = py.StudentID;