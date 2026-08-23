drop database UniversityDB;	
CREATE DATABASE UniversityDB;
USE UniversityDB;
CREATE TABLE Colleges(
	CollegeID INT PRIMARY KEY,
    CollegeName VARCHAR(20) UNIQUE
);
CREATE TABLE Departments(
	DeptID INT PRIMARY KEY,
    DeptName VARCHAR(25) UNIQUE NOT NULL,
    CollegeID INT,
    FOREIGN KEY(CollegeID) REFERENCES Colleges(CollegeID)
);
CREATE TABLE Faculty(
	FacultyID INT  PRIMARY KEY,
    `Name` VARCHAR(20) NOT NULL,
    DeptID INT,
    FOREIGN KEY(DeptID) REFERENCES Departments(DeptID),
    Designation VARCHAR(30),
    Email VARCHAR(35) UNIQUE,
    Phone VARCHAR(15) UNIQUE
);

ALTER TABLE Departments 
ADD HODFacultyID INT, 
ADD FOREIGN KEY (HODFacultyID) 
REFERENCES Faculty(FacultyID);

CREATE TABLE Programs(
	ProgramID INT PRIMARY KEY,
    ProgramName VARCHAR(20) NOT NULL,
    DegreeType VARCHAR(20),
    DeptID INT,
    FOREIGN KEY(DeptID) REFERENCES Departments(DeptID),
    UNIQUE (ProgramName, DeptID)
);
CREATE TABLE Students(
	StudentID INT PRIMARY KEY,
    `Name` VARCHAR(20) NOT NULL,
    DOB CHAR(10),
    -- Gender CHAR(1) CHECK (Gender IN ('M', 'F', 'O')),or
    Gender ENUM( 'M', 'F', 'O'),
    AdmissionYear INT CHECK (AdmissionYear>= 2000),
    Email VARCHAR(35) UNIQUE,
    Phone VARCHAR(15) UNIQUE,
    ProgramID INT,
    FOREIGN KEY(ProgramID) REFERENCES Programs(ProgramID)
);


-- Q3-
INSERT INTO Colleges (CollegeID, CollegeName)
VALUES
(1, 'Engineering'),
(2, 'Medicine'),
(3, 'Law'),
(4, 'Business'),
(5, 'Science'),
(6, 'Arts'),
(7, 'Education'),
(8, 'Architecture'),
(9, 'Design'),
(10, 'Computer Science');

INSERT INTO Departments (DeptID, DeptName, CollegeID)
VALUES
(1, 'Computer Science', 1),
(2, 'Mechanical Eng', 1),
(3, 'Electrical Eng', 1),
(4, 'Medicine', 2),
(5, 'Law', 3),
(6, 'Business Admin', 4),
(7, 'Physics', 5),
(8, 'English', 6),
(9, 'Education', 7),
(10, 'Architecture', 8);

INSERT INTO Faculty (FacultyID, `Name`, DeptID, Designation, Email, Phone)
VALUES
(1, 'John Smith', 1, 'Professor', 'john@univ.com', 1000000001),
(2, 'Sarah Khan', 1, 'Assistant Professor', 'sarah@univ.com', 1000000002),
(3, 'David Lee', 2, 'Professor', 'david@univ.com', 1000000003),
(4, 'Maria Garcia', 2, 'Lecturer', 'maria@univ.com', 1000000004),
(5, 'Ali Ahmed', 3, 'Professor', 'ali@univ.com', 1000000005),
(6, 'Emma Brown', 4, 'Professor', 'emma@univ.com', 1000000006),
(7, 'Robert Wilson', 4, 'Lecturer', 'robert@univ.com', 1000000007),
(8, 'Priya Sharma', 5, 'Professor', 'priya@univ.com', 1000000008),
(9, 'James Taylor', 6, 'Professor', 'james@univ.com', 1000000009),
(10, 'Aisha Patel', 7, 'Lecturer', 'aisha@univ.com', 1000000010),
(11, 'Daniel Clark', 8, 'Professor', 'daniel@univ.com', 1000000011),
(12, 'Sofia Martin', 9, 'Lecturer', 'sofia@univ.com', 1000000012),
(13, 'Michael Davis', 10, 'Professor', 'michael@univ.com', 1000000013),
(14, 'Nina Wilson', 3, 'Assistant Professor', 'nina@univ.com', 1000000014),
(15, 'Omar Hassan', 5, 'Lecturer', 'omar@univ.com', 1000000015);

UPDATE Departments SET HODFacultyID = 1 WHERE DeptID = 1;
UPDATE Departments SET HODFacultyID = 3 WHERE DeptID = 2;
UPDATE Departments SET HODFacultyID = 5 WHERE DeptID = 3;
UPDATE Departments SET HODFacultyID = 6 WHERE DeptID = 4;
UPDATE Departments SET HODFacultyID = 8 WHERE DeptID = 5;
UPDATE Departments SET HODFacultyID = 9 WHERE DeptID = 6;
UPDATE Departments SET HODFacultyID = 10 WHERE DeptID = 7;
UPDATE Departments SET HODFacultyID = 11 WHERE DeptID = 8;
UPDATE Departments SET HODFacultyID = 12 WHERE DeptID = 9;
UPDATE Departments SET HODFacultyID = 13 WHERE DeptID = 10;

INSERT INTO Programs (ProgramID, ProgramName, DegreeType, DeptID)
VALUES
(1, 'Computer Science', 'BSc', 1),
(2, 'Data Science', 'BSc', 1),
(3, 'Mechanical Eng', 'BTech', 2),
(4, 'Automotive Eng', 'BTech', 2),
(5, 'Electrical Eng', 'BTech', 3),
(6, 'Medicine', 'MBBS', 4),
(7, 'Nursing', 'BSc', 4),
(8, 'Corporate Law', 'LLB', 5),
(9, 'Business Admin', 'BBA', 6),
(10, 'Finance', 'BCom', 6),
(11, 'Physics', 'BSc', 7),
(12, 'English Lit', 'BA', 8),
(13, 'Teacher Education', 'BEd', 9),
(14, 'Architecture', 'BArch', 10),
(15, 'Urban Design', 'BArch', 10);

INSERT INTO Students
(StudentID, `Name`, DOB, Gender, AdmissionYear, Email, Phone, ProgramID)
VALUES
(1, 'Aarav Sharma', '2005-01-15', 'M', 2024, 'aarav.sharma@univ.com', 9000000001, 1),
(2, 'Ananya Singh', '2005-02-20', 'F', 2024, 'ananya.singh@univ.com', 9000000002, 2),
(3, 'Rohan Mehta', '2004-03-10', 'M', 2023, 'rohan.mehta@univ.com', 9000000003, 3),
(4, 'Priya Kapoor', '2005-04-05', 'F', 2024, 'priya.kapoor@univ.com', 9000000004, 4),
(5, 'Arjun Verma', '2004-05-18', 'M', 2023, 'arjun.verma@univ.com', 9000000005, 5),
(6, 'Isha Gupta', '2005-06-22', 'F', 2024, 'isha.gupta@univ.com', 9000000006, 6),
(7, 'Kabir Malhotra', '2004-07-11', 'M', 2023, 'kabir.malhotra@univ.com', 9000000007, 7),
(8, 'Meera Joshi', '2005-08-14', 'F', 2024, 'meera.joshi@univ.com', 9000000008, 8),
(9, 'Aditya Rao', '2005-09-19', 'M', 2024, 'aditya.rao@univ.com', 9000000009, 9),
(10, 'Simran Kaur', '2004-10-25', 'F', 2023, 'simran.kaur@univ.com', 9000000010, 10),

(11, 'Vihaan Patel', '2005-11-02', 'M', 2024, 'vihaan.patel@univ.com', 9000000011, 11),
(12, 'Diya Shah', '2005-12-08', 'F', 2024, 'diya.shah@univ.com', 9000000012, 12),
(13, 'Karan Nair', '2004-01-17', 'M', 2023, 'karan.nair@univ.com', 9000000013, 13),
(14, 'Riya Bansal', '2005-02-23', 'F', 2024, 'riya.bansal@univ.com', 9000000014, 14),
(15, 'Dev Agarwal', '2004-03-29', 'M', 2023, 'dev.agarwal@univ.com', 9000000015, 15),
(16, 'Tanya Sethi', '2005-04-12', 'F', 2024, 'tanya.sethi@univ.com', 9000000016, 1),
(17, 'Yash Khanna', '2004-05-21', 'M', 2023, 'yash.khanna@univ.com', 9000000017, 2),
(18, 'Nisha Arora', '2005-06-16', 'F', 2024, 'nisha.arora@univ.com', 9000000018, 3),
(19, 'Rahul Sinha', '2004-07-27', 'M', 2023, 'rahul.sinha@univ.com', 9000000019, 4),
(20, 'Pooja Mishra', '2005-08-30', 'F', 2024, 'pooja.mishra@univ.com', 9000000020, 5),

(21, 'Manav Tiwari', '2005-09-13', 'M', 2024, 'manav.tiwari@univ.com', 9000000021, 6),
(22, 'Sneha Iyer', '2004-10-07', 'F', 2023, 'sneha.iyer@univ.com', 9000000022, 7),
(23, 'Dhruv Jain', '2005-11-19', 'M', 2024, 'dhruv.jain@univ.com', 9000000023, 8),
(24, 'Kavya Reddy', '2005-12-24', 'F', 2024, 'kavya.reddy@univ.com', 9000000024, 9),
(25, 'Siddharth Roy', '2004-01-31', 'M', 2023, 'siddharth.roy@univ.com', 9000000025, 10),
(26, 'Aditi Menon', '2005-02-14', 'F', 2024, 'aditi.menon@univ.com', 9000000026, 11),
(27, 'Harsh Vardhan', '2004-03-22', 'M', 2023, 'harsh.vardhan@univ.com', 9000000027, 12),
(28, 'Neha Saxena', '2005-04-28', 'F', 2024, 'neha.saxena@univ.com', 9000000028, 13),
(29, 'Ishaan Das', '2004-05-09', 'M', 2023, 'ishaan.das@univ.com', 9000000029, 14),
(30, 'Mahi Chawla', '2005-06-18', 'F', 2024, 'mahi.chawla@univ.com', 9000000030, 15),

(31, 'Aryan Bose', '2005-07-26', 'M', 2024, 'aryan.bose@univ.com', 9000000031, 1),
(32, 'Sanya Roy', '2004-08-15', 'F', 2023, 'sanya.roy@univ.com', 9000000032, 2),
(33, 'Ankit Yadav', '2005-09-20', 'M', 2024, 'ankit.yadav@univ.com', 9000000033, 3),
(34, 'Shreya Das', '2005-10-11', 'F', 2024, 'shreya.das@univ.com', 9000000034, 4),
(35, 'Mohit Kumar', '2004-11-29', 'M', 2023, 'mohit.kumar@univ.com', 9000000035, 5),
(36, 'Lavanya Rao', '2005-12-17', 'F', 2024, 'lavanya.rao@univ.com', 9000000036, 6),
(37, 'Aman Srivastava', '2004-01-08', 'M', 2023, 'aman.srivastava@univ.com', 9000000037, 7),
(38, 'Ishita Bose', '2005-02-26', 'F', 2024, 'ishita.bose@univ.com', 9000000038, 8),
(39, 'Varun Jain', '2004-03-15', 'M', 2023, 'varun.jain@univ.com', 9000000039, 9),
(40, 'Muskan Ali', '2005-04-21', 'F', 2024, 'muskan.ali@univ.com', 9000000040, 10),

(41, 'Reyansh Gupta', '2005-05-13', 'M', 2024, 'reyansh.gupta@univ.com', 9000000041, 11),
(42, 'Sakshi Jain', '2004-06-09', 'F', 2023, 'sakshi.jain@univ.com', 9000000042, 12),
(43, 'Nakul Sharma', '2005-07-18', 'M', 2024, 'nakul.sharma@univ.com', 9000000043, 13),
(44, 'Palak Suri', '2005-08-23', 'F', 2024, 'palak.suri@univ.com', 9000000044, 14),
(45, 'Abhishek Roy', '2004-09-12', 'M', 2023, 'abhishek.roy@univ.com', 9000000045, 15),
(46, 'Anjali Verma', '2005-10-19', 'F', 2024, 'anjali.verma@univ.com', 9000000046, 1),
(47, 'Ritesh Kumar', '2004-11-05', 'M', 2023, 'ritesh.kumar@univ.com', 9000000047, 2),
(48, 'Komal Gupta', '2005-12-14', 'F', 2024, 'komal.gupta@univ.com', 9000000048, 3),
(49, 'Samar Singh', '2004-01-25', 'M', 2023, 'samar.singh@univ.com', 9000000049, 4),
(50, 'Ayesha Khan', '2005-02-09', 'F', 2024, 'ayesha.khan@univ.com', 9000000050, 5),

(51, 'Raghav Mehta', '2005-03-18', 'M', 2024, 'raghav.mehta@univ.com', 9000000051, 6),
(52, 'Nandini Rao', '2004-04-27', 'F', 2023, 'nandini.rao@univ.com', 9000000052, 7),
(53, 'Arnav Kapoor', '2005-05-16', 'M', 2024, 'arnav.kapoor@univ.com', 9000000053, 8),
(54, 'Ira Malhotra', '2005-06-22', 'F', 2024, 'ira.malhotra@univ.com', 9000000054, 9),
(55, 'Veer Singh', '2004-07-31', 'M', 2023, 'veer.singh@univ.com', 9000000055, 10),
(56, 'Aanya Joshi', '2005-08-13', 'F', 2024, 'aanya.joshi@univ.com', 9000000056, 11),
(57, 'Kunal Patel', '2004-09-24', 'M', 2023, 'kunal.patel@univ.com', 9000000057, 12),
(58, 'Rhea Nair', '2005-10-07', 'F', 2024, 'rhea.nair@univ.com', 9000000058, 13),
(59, 'Adit Shah', '2004-11-17', 'M', 2023, 'adit.shah@univ.com', 9000000059, 14),
(60, 'Sia Bhatia', '2005-12-28', 'F', 2024, 'sia.bhatia@univ.com', 9000000060, 15),

(61, 'Krish Arora', '2005-01-11', 'M', 2024, 'krish.arora@univ.com', 9000000061, 1),
(62, 'Mira Sethi', '2004-02-19', 'F', 2023, 'mira.sethi@univ.com', 9000000062, 2),
(63, 'Devansh Jain', '2005-03-27', 'M', 2024, 'devansh.jain@univ.com', 9000000063, 3),
(64, 'Tisha Sharma', '2005-04-15', 'F', 2024, 'tisha.sharma@univ.com', 9000000064, 4),
(65, 'Yuvraj Singh', '2004-05-23', 'M', 2023, 'yuvraj.singh@univ.com', 9000000065, 5),
(66, 'Navya Kapoor', '2005-06-30', 'F', 2024, 'navya.kapoor@univ.com', 9000000066, 6),
(67, 'Atharv Gupta', '2004-07-14', 'M', 2023, 'atharv.gupta@univ.com', 9000000067, 7),
(68, 'Myra Khan', '2005-08-21', 'F', 2024, 'myra.khan@univ.com', 9000000068, 8),
(69, 'Rudra Mehta', '2004-09-08', 'M', 2023, 'rudra.mehta@univ.com', 9000000069, 9),
(70, 'Kiara Shah', '2005-10-26', 'F', 2024, 'kiara.shah@univ.com', 9000000070, 10),

(71, 'Shaurya Rao', '2005-11-12', 'M', 2024, 'shaurya.rao@univ.com', 9000000071, 11),
(72, 'Avni Patel', '2004-12-19', 'F', 2023, 'avni.patel@univ.com', 9000000072, 12),
(73, 'Parth Joshi', '2005-01-28', 'M', 2024, 'parth.joshi@univ.com', 9000000073, 13),
(74, 'Zoya Khan', '2005-02-16', 'F', 2024, 'zoya.khan@univ.com', 9000000074, 14),
(75, 'Vivaan Das', '2004-03-24', 'M', 2023, 'vivaan.das@univ.com', 9000000075, 15),
(76, 'Anika Roy', '2005-04-09', 'F', 2024, 'anika.roy@univ.com', 9000000076, 1),
(77, 'Rishabh Sinha', '2004-05-17', 'M', 2023, 'rishabh.sinha@univ.com', 9000000077, 2),
(78, 'Tara Mehta', '2005-06-25', 'F', 2024, 'tara.mehta@univ.com', 9000000078, 3),
(79, 'Sahil Verma', '2004-07-13', 'M', 2023, 'sahil.verma@univ.com', 9000000079, 4),
(80, 'Ritika Sharma', '2005-08-29', 'F', 2024, 'ritika.sharma@univ.com', 9000000080, 5),

(81, 'Aayush Jain', '2005-09-16', 'M', 2024, 'aayush.jain@univ.com', 9000000081, 6),
(82, 'Shivani Rao', '2004-10-22', 'F', 2023, 'shivani.rao@univ.com', 9000000082, 7),
(83, 'Armaan Khan', '2005-11-08', 'M', 2024, 'armaan.khan@univ.com', 9000000083, 8),
(84, 'Pihu Gupta', '2005-12-15', 'F', 2024, 'pihu.gupta@univ.com', 9000000084, 9),
(85, 'Lakshya Singh', '2004-01-20', 'M', 2023, 'lakshya.singh@univ.com', 9000000085, 10),
(86, 'Saanvi Kapoor', '2005-02-28', 'F', 2024, 'saanvi.kapoor@univ.com', 9000000086, 11),
(87, 'Aryan Mehta', '2004-03-11', 'M', 2023, 'aryan.mehta@univ.com', 9000000087, 12),
(88, 'Ishani Patel', '2005-04-18', 'F', 2024, 'ishani.patel@univ.com', 9000000088, 13),
(89, 'Rohan Das', '2004-05-26', 'M', 2023, 'rohan.das@univ.com', 9000000089, 14),
(90, 'Manya Suri', '2005-06-07', 'F', 2024, 'manya.suri@univ.com', 9000000090, 15),

(91, 'Abeer Sharma', '2005-07-19', 'M', 2024, 'abeer.sharma@univ.com', 9000000091, 1),
(92, 'Kritika Jain', '2004-08-27', 'F', 2023, 'kritika.jain@univ.com', 9000000092, 2),
(93, 'Ritvik Gupta', '2005-09-14', 'M', 2024, 'ritvik.gupta@univ.com', 9000000093, 3),
(94, 'Tanvi Rao', '2005-10-23', 'F', 2024, 'tanvi.rao@univ.com', 9000000094, 4),
(95, 'Om Patel', '2004-11-18', 'M', 2023, 'om.patel@univ.com', 9000000095, 5),
(96, 'Aarohi Singh', '2005-12-06', 'F', 2024, 'aarohi.singh@univ.com', 9000000096, 6),
(97, 'Kartik Mehta', '2004-01-13', 'M', 2023, 'kartik.mehta@univ.com', 9000000097, 7),
(98, 'Shanaya Roy', '2005-02-21', 'F', 2024, 'shanaya.roy@univ.com', 9000000098, 8),
(99, 'Rehan Khan', '2004-03-30', 'M', 2023, 'rehan.khan@univ.com', 9000000099, 9),
(100, 'Ishika Verma', '2005-04-16', 'F', 2024, 'ishika.verma@univ.com', 9000000100, 10);

-- show all colleges;
SELECT * FROM Colleges;

-- show all department
SELECT * FROM Departments;
-- show all faculty
SELECT * FROM Faculty;
-- Show Departments with their HODs 
SELECT
    d.DeptID,
    d.DeptName,
    d.HODFacultyID,
    f.FacultyID,
    f.`Name` AS HODName
FROM Departments d
JOIN Faculty f
    ON d.HODFacultyID = f.FacultyID;
-- shows all programs
SELECT * FROM Programs;
-- shows all the students
SELECT * FROM Students ;

-- ERRORS
-- Student with duplicate Email
/*
INSERT INTO Students
(StudentID, `Name`, DOB, Gender, AdmissionYear, Email, Phone, ProgramID)
VALUES
(101, 'Test Student', '2005-01-01', 'M', 2024,
'aarav.sharma@univ.com', 9111111111, 1);
*/
-- Student with duplicate Phone
/*
INSERT INTO Students
(StudentID, `Name`, DOB, Gender, AdmissionYear, Email, Phone, ProgramID)
VALUES
(102, 'Test Student 2', '2005-01-01', 'F', 2024,
'test102@univ.com', 9000000001, 1);
*/
-- Department with non-existent CollegeID
/*
INSERT INTO Departments
(DeptID, DeptName, CollegeID)
VALUES
(99, 'Invalid Department', 999);
*/

-- Faculty with non-existent DeptID
/*
INSERT INTO Faculty
(FacultyID, `Name`, DeptID, Designation, Email, Phone)
VALUES
(99, 'Invalid Faculty', 999, 'Professor',
'invalidfaculty@univ.com', 9111111199);
*/

-- Student with invalid Gender
/*
INSERT INTO Students
(StudentID, `Name`, DOB, Gender, AdmissionYear, Email, Phone, ProgramID)
VALUES
(103, 'Invalid Gender', '2005-01-01', 'X', 2024,
'invalidgender@univ.com', 9111111113, 1);
*/

-- Student with AdmissionYear earlier than 2000
/*
INSERT INTO Students
(StudentID, `Name`, DOB, Gender, AdmissionYear, Email, Phone, ProgramID)
VALUES
(104, 'Invalid Year', '1999-01-01', 'M', 1999,
'invalidyear@univ.com', 9111111114, 1);
*/

-- Program with duplicate (ProgramName, DeptID)
/*
INSERT INTO Programs
(ProgramID, ProgramName, DegreeType, DeptID)
VALUES
(99, 'Computer Science', 'BSc', 1);
*/
-- end 
