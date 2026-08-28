use universitydb;
show tables;
create table courses(
	CourseID int primary key,
    CourseName varchar(40) not null,
    Credits int check(Credits<=6 and Credits>=1),
    SemesterOffered varchar(20) not null,
    DeptID int,
    PrerequisiteCourseID int,
    foreign key (DeptID) REFERENCES Departments(DeptID),
    FOREIGN KEY (PrerequisiteCourseID) REFERENCES Courses(CourseID)
    -- Whatever number is placed in PrerequisiteCourseID must be an existing CourseID in the Courses table
);

create table CourseFaculty(
	CFID int primary key,
    FacultyID int ,
    foreign key (FacultyID) REFERENCES Faculty(FacultyID),
    CourseID int ,
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    Semester varchar(20) not null,
    UNIQUE (FacultyID, CourseID, Semester)
);

create table Enrollments(
	EnrollmentID int primary key,
    StudentID int ,
    foreign key (StudentID) REFERENCES Students(StudentID),
    CourseID int ,
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    Semester varchar(20) not null,
    Grade CHAR(1) CHECK (Grade IN ('A','B','C','D','E','F','I')),
    UNIQUE (StudentID, CourseID, Semester)
);

create table Exams(
	ExamID int primary key,
    ExamDate date not null,
    CourseID int ,
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    MaxMarks int check(MaxMarks>=0)
    
);

create table ExamResults(
	ResultID int primary key,
    StudentID int not null,
    foreign key(StudentID) references Students(StudentID),
    ExamID int,
    FOREIGN KEY (ExamID) REFERENCES Exams(ExamID),
    MarksObtained int check(MarksObtained>=0),
    UNIQUE (ExamID, StudentID) 
    
);

DELIMITER //

CREATE TRIGGER check_marks
BEFORE INSERT ON ExamResults
FOR EACH ROW
BEGIN
    DECLARE max_marks INT;

    SELECT MaxMarks INTO max_marks
    FROM Exams
    WHERE ExamID = NEW.ExamID;

    IF NEW.MarksObtained > max_marks THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Marks cannot exceed maximum marks';
    END IF;
END//

DELIMITER ;

create table Attendance(
	AttendanceID int primary key,
    StudentID int not null,
    foreign key(StudentID) references Students(StudentID),
    CourseID int,
    FOREIGN KEY (CourseID) REFERENCES courses(CourseID),
    `Date` date not null,
    Status VARCHAR(10) CHECK (Status IN ('Present', 'Absent', 'Late')),
    UNIQUE (StudentID, CourseID, `Date`)
);
create table Hostels(
	HostelID int primary key,
    HostelName varchar(40) unique,
    Capacity int check(Capacity>0)
);
create table HostelAllotment(
	AllotmentID int primary key,
    HostelID int ,
    foreign key(HostelID) references Hostels(HostelID),
	StudentID int unique,
	foreign key (StudentID) references Students(StudentID),
    RoomNo int not null,
    UNIQUE (HostelID, RoomNo)
);
create table LibraryBooks(
	BookID int primary key,
    Title varchar(70) not null,
    Author varchar(20) not null,
    Publisher varchar(40) not null,
    ISBN int unique,
    Edition int,
    YearPublished SMALLINT,
    DeptID int,
    foreign key(DeptID) references Departments(DeptID),
    CopiesAvailable int check(CopiesAvailable>=0)
);
create table BookIssues(
	IssueID int primary key,
    BookID int,
    foreign key(BookID) references LibraryBooks(BookID),
	StudentID int,
    foreign key(StudentID) references Students(StudentID),
    IssueDate DATE DEFAULT (CURRENT_DATE),
    ReturnDate DATE
    
);

DELIMITER //

CREATE TRIGGER before_book_issue
BEFORE INSERT ON BookIssues
FOR EACH ROW
BEGIN
    DECLARE copies INT;

    SELECT CopiesAvailable INTO copies
    from LibraryBooks
    where BookID = NEW.BookID;

    IF copies = 0 THEN
        signal SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Book is not available';
    ELSE
        UPDATE LibraryBooks
        SET CopiesAvailable = CopiesAvailable - 1
        WHERE BookID = NEW.BookID;
    END IF;
END//

CREATE TRIGGER after_book_return
AFTER UPDATE ON BookIssues
FOR EACH ROW
BEGIN
    IF OLD.ReturnDate IS NULL AND NEW.ReturnDate IS NOT NULL THEN
        update LibraryBooks
        SET CopiesAvailable = CopiesAvailable + 1
        WHERE BookID = NEW.BookID;
    END IF;
END//

DELIMITER ;

create table Payments(
	PaymentID int primary key,
	StudentID int,
    foreign key(StudentID) references Students(StudentID),
    `Date` DATE DEFAULT (CURRENT_DATE),
    Amount int check(Amount>0),
    PaymentType varchar(20) check(PaymentType in ('Tuition','Hostel','Fine','Other')),
    Status varchar(20) check(Status in ('Paid','Pending'))
    
);
create table Timetable(
	TimetableID int primary key,
	CourseID int,
    foreign key(CourseID) references Courses(CourseID),
	FacultyID int,
    foreign key(FacultyID) references Faculty(FacultyID),
    `day` varchar(20) check(`Day` in ('mon','tue','wed','thu','fri','sat','sun')),
    TimeSlot varchar(20) not null,
    RoomNo int not null,
    UNIQUE (RoomNo, Day, TimeSlot),
    UNIQUE (FacultyID, Day, TimeSlot)
    
);

-- q2 data insertion -
INSERT INTO Courses
    (CourseID, CourseName, Credits, SemesterOffered, DeptID, PrerequisiteCourseID)
VALUES
    (101, 'Programming Basics', 4, 'Semester 1', 1, NULL),
    (102, 'Calculus I',         4, 'Semester 1', 1, NULL),
    (103, 'Physics I',          4, 'Semester 1', 7, NULL),
    (104, 'Digital Logic',     3, 'Semester 1', 3, NULL),
    (105, 'Data Structures',    4, 'Semester 2', 1, NULL),
    (106, 'Discrete Math',      3, 'Semester 1', 1, NULL),
    (107, 'English Comm',       2, 'Semester 1', 8, NULL),
    (108, 'Database Basics',    3, 'Semester 2', 1, NULL),
    (109, 'Statistics',         3, 'Semester 2', 6, NULL),
    (110, 'Computer Networks',  3, 'Semester 3', 1, NULL);
    
-- added the coursees first to avoid dependency eror; the we will insert the other 10 that are dependent of the first 10
INSERT INTO Courses
    (CourseID, CourseName, Credits, SemesterOffered, DeptID, PrerequisiteCourseID)
VALUES
    (111, 'Advanced Programming', 4, 'Semester 2', 1, 101),
    (112, 'Calculus II',           4, 'Semester 2', 1, 102),
    (113, 'Physics II',            4, 'Semester 2', 7, 103),
    (114, 'Computer Systems',      4, 'Semester 2', 3, 104),
    (115, 'Data Mining',           4, 'Semester 3', 1, 105),
    (116, 'Advanced Mathematics',  3, 'Semester 2', 1, 106),
    (117, 'Technical Writing',     3, 'Semester 2', 8, 107),
    (118, 'Database Systems',      4, 'Semester 3', 1, 108),
    (119, 'Applied Statistics',    3, 'Semester 3', 6, 109),
    (120, 'Advanced Networks',     4, 'Semester 4', 1, 110);
    
INSERT INTO CourseFaculty
    (CFID, FacultyID, CourseID, Semester)
VALUES
	(1,  1, 101, 'Semester 1'),
    (2,  1, 102, 'Semester 1'),
    (3,  1, 106, 'Semester 1'),
    (4,  1, 110, 'Semester 3'),

    (5,  2, 102, 'Semester 1'),
    (6,  2, 103, 'Semester 1'),
    (7,  2, 107, 'Semester 1'),
    (8,  2, 115, 'Semester 3'),

    (9,  3, 103, 'Semester 1'),
    (10, 3, 105, 'Semester 2'),
    (11, 3, 109, 'Semester 2'),
    (12, 3, 119, 'Semester 3'),

    (13, 4, 104, 'Semester 1'),
    (14, 4, 108, 'Semester 2'),
    (15, 4, 120, 'Semester 4'),

    (16, 5, 104, 'Semester 1'),
    (17, 5, 114, 'Semester 2'),
    (18, 5, 116, 'Semester 2'),

    (19, 6, 106, 'Semester 1'),
    (20, 6, 109, 'Semester 2'),
    (21, 6, 119, 'Semester 3'),

    (22, 7, 103, 'Semester 1'),
    (23, 7, 113, 'Semester 2'),

    (24, 8, 105, 'Semester 2'),
    (25, 8, 115, 'Semester 3'),

    (26, 9, 109, 'Semester 2'),
    (27, 9, 119, 'Semester 3'),

    (28, 10, 107, 'Semester 1'),
    (29, 10, 117, 'Semester 2');

INSERT INTO Enrollments
    (EnrollmentID, StudentID, CourseID, Semester)
VALUES
    (1,  1, 101, 'Semester 1', 'B'),
    (2,  1, 102, 'Semester 1', 'B'),
    (3,  1, 103, 'Semester 1', 'C'),
    (4,  1, 104, 'Semester 1', 'A'),
    (5,  1, 106, 'Semester 1', NULL),
    (6,  2, 101, 'Semester 1', 'C'),
    (7,  2, 102, 'Semester 1', 'D'),
    (8,  2, 104, 'Semester 1', 'C'),
    (9,  2, 106, 'Semester 1', NULL),
    (10, 2, 107, 'Semester 1', NULL),
    (11, 3, 101, 'Semester 1', 'A'),
    (12, 3, 103, 'Semester 1', 'A'),
    (13, 3, 104, 'Semester 1', 'B'),
    (14, 3, 106, 'Semester 1', NULL),
    (15, 3, 107, 'Semester 1', NULL),
    (16, 4, 102, 'Semester 1', 'C'),
    (17, 4, 103, 'Semester 1', 'D'),
    (18, 4, 104, 'Semester 1', 'C'),
    (19, 4, 106, 'Semester 1', NULL),
    (20, 4, 107, 'Semester 1', NULL),
    (21, 5, 101, 'Semester 1', 'B'),
    (22, 5, 102, 'Semester 1', 'B'),
    (23, 5, 103, 'Semester 1', 'B'),
    (24, 5, 106, 'Semester 1', NULL),
    (25, 5, 107, 'Semester 1', NULL),
    (26, 6, 105, 'Semester 2', 'B'),
    (27, 6, 108, 'Semester 2', 'B'),
    (28, 6, 109, 'Semester 2', 'B'),
    (29, 6, 111, 'Semester 2', 'C'),
    (30, 6, 112, 'Semester 2', 'B'),
    (31, 7, 105, 'Semester 2', 'C'),
    (32, 7, 108, 'Semester 2', 'C'),
    (33, 7, 109, 'Semester 2', 'B'),
    (34, 7, 111, 'Semester 2', 'B'),
    (35, 7, 113, 'Semester 2', 'C'),
    (36, 8, 105, 'Semester 2', 'A'),
    (37, 8, 108, 'Semester 2', 'A'),
    (38, 8, 109, 'Semester 2', 'A'),
    (39, 8, 112, 'Semester 2', 'A'),
    (40, 8, 113, 'Semester 2', 'B'),
    (41, 9, 105, 'Semester 2', 'D'),
    (42, 9, 108, 'Semester 2', 'B'),
    (43, 9, 109, 'Semester 2', 'C'),
    (44, 9, 111, 'Semester 2', 'C'),
    (45, 9, 112, 'Semester 2', 'C'),
    (46, 10, 105, 'Semester 2', 'B'),
    (47, 10, 108, 'Semester 2', 'C'),
    (48, 10, 109, 'Semester 2', 'B'),
    (49, 10, 111, 'Semester 2', 'B'),
    (50, 10, 113, 'Semester 2', 'A'),
    (51, 2, 103, 'Semester 1', 'B'),
    (52, 3, 102, 'Semester 1', 'A'),
    (53, 4, 101, 'Semester 1', 'C'),
    (54, 5, 104, 'Semester 1', 'A'),
    (55, 6, 113, 'Semester 2', 'A'),
    (56, 7, 112, 'Semester 2', 'C'),
    (57, 8, 111, 'Semester 2', 'A'),
    (58, 9, 113, 'Semester 2', 'B'),
    (59, 10, 112, 'Semester 2', 'B');

INSERT INTO Exams
    (ExamID, ExamDate, CourseID, MaxMarks)
VALUES
    (1,  '2026-02-10', 101, 100),
    (2,  '2026-02-11', 102, 100),
    (3,  '2026-02-12', 103, 100),
    (4,  '2026-02-13', 104, 100),
    (5,  '2026-02-14', 106, 100),

    (6,  '2026-06-10', 105, 100),
    (7,  '2026-06-11', 108, 100),
    (8,  '2026-06-12', 109, 100),
    (9,  '2026-06-13', 111, 100),
    (10, '2026-06-14', 112, 100),

    (11, '2026-06-15', 113, 100),
    (12, '2026-06-16', 107, 100),
    (13, '2026-06-17', 114, 100),
    (14, '2026-06-18', 116, 100),
    (15, '2026-06-19', 117, 100),

    (16, '2026-06-20', 118, 100),
    (17, '2026-06-21', 119, 100),
    (18, '2026-06-22', 120, 100),
    (19, '2026-06-23', 110, 100),
    (20, '2026-06-24', 115, 100);
    
INSERT INTO ExamResults
    (ResultID, StudentID, ExamID, MarksObtained)
VALUES
    (1,  1,  1, 85),
    (2,  2,  1, 78),
    (3,  3,  1, 92),
    (4,  4,  1, 74),
    (5,  5,  1, 88),

    (6,  1,  2, 81),
    (7,  2,  2, 69),
    (8,  3,  2, 95),
    (9,  4,  2, 77),
    (10, 5,  2, 84),

    (11, 1,  3, 76),
    (12, 2,  3, 88),
    (13, 3,  3, 91),
    (14, 4,  3, 68),
    (15, 5,  3, 82),

    (16, 1,  4, 90),
    (17, 2,  4, 73),
    (18, 3,  4, 87),
    (19, 4,  4, 79),
    (20, 5,  4, 94),

    (21, 6,  6, 83),
    (22, 7,  6, 75),
    (23, 8,  6, 91),
    (24, 9,  6, 68),
    (25, 10, 6, 86),

    (26, 6,  7, 89),
    (27, 7,  7, 72),
    (28, 8,  7, 94),
    (29, 9,  7, 81),
    (30, 10, 7, 77),

    (31, 6,  8, 80),
    (32, 7,  8, 85),
    (33, 8,  8, 93),
    (34, 9,  8, 76),
    (35, 10, 8, 88),

    (36, 6,  9, 78),
    (37, 7,  9, 84),
    (38, 8,  9, 96),
    (39, 9,  9, 71),
    (40, 10, 9, 89),

    (41, 6,  10, 87),
    (42, 7,  10, 79),
    (43, 8,  10, 92),
    (44, 9,  10, 74),
    (45, 10, 10, 85),

    (46, 6,  11, 90),
    (47, 7,  11, 76),
    (48, 8,  11, 88),
    (49, 9, 11, 82),
    (50, 10, 11, 95);
    
    INSERT INTO Attendance
    (AttendanceID, StudentID, CourseID, `Date`, Status)
VALUES
    (1,  1, 101, '2026-01-15', 'Present'),
    (2,  2, 101, '2026-01-15', 'Present'),
    (3,  3, 101, '2026-01-15', 'Absent'),
    (4,  4, 101, '2026-01-15', 'Present'),
    (5,  5, 101, '2026-01-15', 'Late'),

    (6,  1, 102, '2026-01-16', 'Present'),
    (7,  2, 102, '2026-01-16', 'Absent'),
    (8,  3, 102, '2026-01-16', 'Present'),
    (9,  4, 102, '2026-01-16', 'Late'),
    (10, 5, 102, '2026-01-16', 'Present'),

    (11, 1, 103, '2026-01-17', 'Present'),
    (12, 2, 103, '2026-01-17', 'Present'),
    (13, 3, 103, '2026-01-17', 'Late'),
    (14, 4, 103, '2026-01-17', 'Absent'),
    (15, 5, 103, '2026-01-17', 'Present'),

    (16, 1, 104, '2026-01-18', 'Absent'),
    (17, 2, 104, '2026-01-18', 'Present'),
    (18, 3, 104, '2026-01-18', 'Present'),
    (19, 4, 104, '2026-01-18', 'Late'),
    (20, 5, 104, '2026-01-18', 'Present'),

    (21, 1, 106, '2026-01-19', 'Present'),
    (22, 2, 106, '2026-01-19', 'Late'),
    (23, 3, 106, '2026-01-19', 'Present'),
    (24, 4, 106, '2026-01-19', 'Absent'),
    (25, 5, 106, '2026-01-19', 'Present'),

    (26, 6, 105, '2026-02-15', 'Present'),
    (27, 7, 105, '2026-02-15', 'Absent'),
    (28, 8, 105, '2026-02-15', 'Present'),
    (29, 9, 105, '2026-02-15', 'Late'),
    (30, 10, 105, '2026-02-15', 'Present'),

    (31, 6, 108, '2026-02-16', 'Present'),
    (32, 7, 108, '2026-02-16', 'Present'),
    (33, 8, 108, '2026-02-16', 'Absent'),
    (34, 9, 108, '2026-02-16', 'Late'),
    (35, 10, 108, '2026-02-16', 'Present'),

    (36, 6, 109, '2026-02-17', 'Absent'),
    (37, 7, 109, '2026-02-17', 'Present'),
    (38, 8, 109, '2026-02-17', 'Present'),
    (39, 9, 109, '2026-02-17', 'Late'),
    (40, 10, 109, '2026-02-17', 'Present'),

    (41, 6, 111, '2026-02-18', 'Present'),
    (42, 7, 111, '2026-02-18', 'Late'),
    (43, 8, 111, '2026-02-18', 'Present'),
    (44, 9, 111, '2026-02-18', 'Absent'),
    (45, 10, 111, '2026-02-18', 'Present'),

    (46, 6, 112, '2026-02-19', 'Present'),
    (47, 7, 112, '2026-02-19', 'Present'),
    (48, 8, 112, '2026-02-19', 'Late'),
    (49, 9, 112, '2026-02-19', 'Present'),
    (50, 10, 112, '2026-02-19', 'Absent'),

    (51, 6, 113, '2026-02-20', 'Absent'),
    (52, 7, 113, '2026-02-20', 'Present'),
    (53, 8, 113, '2026-02-20', 'Present'),
    (54, 9, 113, '2026-02-20', 'Late'),
    (55, 10, 113, '2026-02-20', 'Present'),

    (56, 6, 111, '2026-02-21', 'Present'),
    (57, 7, 111, '2026-02-21', 'Absent'),
    (58, 8, 111, '2026-02-21', 'Present'),
    (59, 9, 111, '2026-02-21', 'Present'),
    (60, 10, 111, '2026-02-21', 'Late'),
    (61,  1, 101, '2026-01-22', 'Present'),
    (62,  2, 101, '2026-01-22', 'Late'),
    (63,  3, 101, '2026-01-22', 'Present'),
    (64,  4, 101, '2026-01-22', 'Absent'),
    (65,  5, 101, '2026-01-22', 'Present'),

    (66,  1, 102, '2026-01-23', 'Late'),
    (67,  2, 102, '2026-01-23', 'Present'),
    (68,  3, 102, '2026-01-23', 'Absent'),
    (69,  4, 102, '2026-01-23', 'Present'),
    (70,  5, 102, '2026-01-23', 'Present'),

    (71,  1, 103, '2026-01-24', 'Present'),
    (72,  2, 103, '2026-01-24', 'Absent'),
    (73,  3, 103, '2026-01-24', 'Late'),
    (74,  4, 103, '2026-01-24', 'Present'),
    (75,  5, 103, '2026-01-24', 'Present'),

    (76,  1, 104, '2026-01-25', 'Present'),
    (77,  2, 104, '2026-01-25', 'Present'),
    (78,  3, 104, '2026-01-25', 'Absent'),
    (79,  4, 104, '2026-01-25', 'Late'),
    (80,  5, 104, '2026-01-25', 'Present'),

    (81,  1, 106, '2026-01-26', 'Late'),
    (82,  2, 106, '2026-01-26', 'Present'),
    (83,  3, 106, '2026-01-26', 'Present'),
    (84,  4, 106, '2026-01-26', 'Absent'),
    (85,  5, 106, '2026-01-26', 'Present'),

    (86,  6, 105, '2026-02-22', 'Present'),
    (87,  7, 105, '2026-02-22', 'Late'),
    (88,  8, 105, '2026-02-22', 'Absent'),
    (89,  9, 105, '2026-02-22', 'Present'),
    (90, 10, 105, '2026-02-22', 'Present'),

    (91,  6, 108, '2026-02-23', 'Absent'),
    (92,  7, 108, '2026-02-23', 'Present'),
    (93,  8, 108, '2026-02-23', 'Late'),
    (94,  9, 108, '2026-02-23', 'Present'),
    (95, 10, 108, '2026-02-23', 'Present'),

    (96,  6, 109, '2026-02-24', 'Present'),
    (97,  7, 109, '2026-02-24', 'Absent'),
    (98,  8, 109, '2026-02-24', 'Present'),
    (99,  9, 109, '2026-02-24', 'Late'),
    (100, 10, 109, '2026-02-24', 'Present'),

    (101, 6, 111, '2026-02-25', 'Present'),
    (102, 7, 111, '2026-02-25', 'Present'),
    (103, 8, 111, '2026-02-25', 'Absent'),
    (104, 9, 111, '2026-02-25', 'Late'),
    (105, 10, 111, '2026-02-25', 'Present'),

    (106, 6, 112, '2026-02-26', 'Late'),
    (107, 7, 112, '2026-02-26', 'Present'),
    (108, 8, 112, '2026-02-26', 'Present'),
    (109, 9, 112, '2026-02-26', 'Absent'),
    (110, 10, 112, '2026-02-26', 'Present'),

    (111, 6, 113, '2026-02-27', 'Present'),
    (112, 7, 113, '2026-02-27', 'Absent'),
    (113, 8, 113, '2026-02-27', 'Late'),
    (114, 9, 113, '2026-02-27', 'Present'),
    (115, 10, 113, '2026-02-27', 'Present'),

    (116, 6, 111, '2026-02-28', 'Absent'),
    (117, 7, 111, '2026-02-28', 'Present'),
    (118, 8, 111, '2026-02-28', 'Present'),
    (119, 9, 111, '2026-02-28', 'Late'),
    (120, 10, 111, '2026-02-28', 'Present');
    
    
INSERT INTO Hostels
    (HostelID, HostelName, Capacity)
VALUES
    (1, 'Vivekanand Hostel', 120),
    (2, 'Tagore Hostel', 100),
    (3, 'Gandhi Hostel', 150),
    (4, 'Nehru Hostel', 100),
    (5, 'Shivaji Hostel', 120),
    (6, 'Rani Laxmi Hostel', 80),
    (7, 'Subhash Hostel', 100),
    (8, 'APJ Abdul Kalam Hostel', 150),
    (9, 'Sardar Patel Hostel', 120),
    (10, 'Sarojini Hostel', 80);
    
INSERT INTO HostelAllotment
    (AllotmentID, HostelID, StudentID, RoomNo)
VALUES
    (1,  1,  1, 101),
    (2,  1,  2, 102),
    (3,  1,  3, 103),
    (4,  1,  4, 104),
    (5,  1,  5, 105),

    (6,  2,  6, 201),
    (7,  2,  7, 202),
    (8,  2,  8, 203),
    (9,  2,  9, 204),
    (10, 2, 10, 205),

    (11, 3, 11, 301),
    (12, 3, 12, 302),
    (13, 3, 13, 303),
    (14, 3, 14, 304),
    (15, 3, 15, 305),

    (16, 4, 16, 401),
    (17, 4, 17, 402),
    (18, 4, 18, 403),
    (19, 4, 19, 404),
    (20, 4, 20, 405),

    (21, 5, 21, 501),
    (22, 5, 22, 502),
    (23, 5, 23, 503),
    (24, 5, 24, 504),
    (25, 5, 25, 505),

    (26, 6, 26, 601),
    (27, 6, 27, 602),
    (28, 6, 28, 603),
    (29, 6, 29, 604),
    (30, 6, 30, 605),

    (31, 7, 31, 701),
    (32, 7, 32, 702),
    (33, 7, 33, 703),
    (34, 7, 34, 704),
    (35, 7, 35, 705),

    (36, 8, 36, 801),
    (37, 8, 37, 802),
    (38, 8, 38, 803),
    (39, 8, 39, 804),
    (40, 8, 40, 805),

    (41, 9, 41, 901),
    (42, 9, 42, 902),
    (43, 9, 43, 903),
    (44, 9, 44, 904),
    (45, 9, 45, 905),

    (46, 10, 46, 1001),
    (47, 10, 47, 1002),
    (48, 10, 48, 1003),
    (49, 10, 49, 1004),
    (50, 10, 50, 1005);
    
INSERT INTO LibraryBooks
    (BookID, Title, Author, Publisher, ISBN, Edition, YearPublished, DeptID, CopiesAvailable)
VALUES
    (5,  'Algorithms',              'Cormen',       'MIT Press',  1000000005, 4, 2022, 1, 5),
    (6,  'Artificial Intelligence', 'Russell',      'Pearson',    1000000006, 4, 2021, 1, 5),
    (7,  'Machine Learning',        'Tom Mitchell', 'McGrawHill', 1000000007, 1, 2017, 1, 5),
    (8,  'Discrete Mathematics',    'Rosen',        'McGrawHill', 1000000008, 8, 2019, 1, 5),
    (9,  'Calculus',                'Thomas',       'Pearson',    1000000009, 14, 2020, 1, 5),
    (10, 'Physics Fundamentals',    'Halliday',     'Wiley',      1000000010, 11, 2018, 7, 5),
    (11, 'Software Engineering',    'Pressman',     'McGrawHill', 1000000011, 9, 2020, 1, 5),
    (12, 'Web Development',         'Duckett',      'Wiley',      1000000012, 2, 2021, 1, 5),
    (13, 'Programming in C',        'Kernighan',    'Pearson',    1000000013, 2, 2018, 1, 5),
    (14, 'Java Programming',        'Herbert',      'McGrawHill', 1000000014, 11, 2020, 1, 5),
    (15, 'Computer Architecture',   'Patterson',    'Morgan',     1000000015, 6, 2019, 1, 5);

INSERT INTO BookIssues
    (IssueID, BookID, StudentID, IssueDate, ReturnDate)
VALUES
    (1,  5,  1,  '2026-07-01', '2026-07-08'),
    (2,  5,  2,  '2026-07-02', '2026-07-09'),

    (3,  6,  3,  '2026-07-03', '2026-07-10'),
    (4,  6,  4,  '2026-07-04', '2026-07-11'),

    (5,  7,  5,  '2026-07-05', '2026-07-12'),
    (6,  7,  6,  '2026-07-06', '2026-07-13'),

    (7,  8,  7,  '2026-07-07', '2026-07-14'),
    (8,  8,  8,  '2026-07-08', '2026-07-15'),

    (9,  9,  9,  '2026-07-09', '2026-07-16'),
    (10, 9, 10, '2026-07-10', '2026-07-17'),

    (11, 10, 1, '2026-07-11', '2026-07-18'),
    (12, 10, 2, '2026-07-12', '2026-07-19'),

    (13, 11, 3, '2026-07-13', '2026-07-20'),
    (14, 11, 4, '2026-07-14', '2026-07-21'),

    (15, 12, 5, '2026-07-15', '2026-07-22'),
    (16, 12, 6, '2026-07-16', '2026-07-23'),

    (17, 13, 7, '2026-07-17', '2026-07-24'),
    (18, 13, 8, '2026-07-18', '2026-07-25'),

    (19, 14, 9, '2026-07-19', '2026-07-26'),
    (20, 14, 10, '2026-07-20', '2026-07-27'),

    (21, 15, 1, '2026-07-21', '2026-07-28'),
    (22, 15, 3, '2026-07-22', '2026-07-29'),

    (23, 5, 4, '2026-07-23', '2026-07-30'),
    (24, 6, 5, '2026-07-24', '2026-07-31'),

    (25, 7, 6, '2026-07-25', '2026-08-01'),
    (26, 8, 7, '2026-07-26', '2026-08-02'),

    (27, 9, 8, '2026-07-27', '2026-08-03'),
    (28, 10, 9, '2026-07-28', '2026-08-04'),

    (29, 11, 10, '2026-07-29', '2026-08-05'),
    (30, 12, 1, '2026-07-30', '2026-08-06');

    
INSERT INTO Payments
    (PaymentID, StudentID, `Date`, Amount, PaymentType, Status)
VALUES
    (1,  1,  '2026-01-05', 50000, 'Tuition', 'Paid'),
    (2,  2,  '2026-01-06', 50000, 'Tuition', 'Paid'),
    (3,  3,  '2026-01-07', 50000, 'Tuition', 'Pending'),
    (4,  4,  '2026-01-08', 50000, 'Tuition', 'Paid'),
    (5,  5,  '2026-01-09', 50000, 'Tuition', 'Pending'),

    (6,  6,  '2026-02-05', 45000, 'Tuition', 'Paid'),
    (7,  7,  '2026-02-06', 45000, 'Tuition', 'Paid'),
    (8,  8,  '2026-02-07', 45000, 'Tuition', 'Pending'),
    (9,  9,  '2026-02-08', 45000, 'Tuition', 'Paid'),
    (10, 10, '2026-02-09', 45000, 'Tuition', 'Pending'),

    (11, 1,  '2026-02-15', 10000, 'Hostel', 'Paid'),
    (12, 2,  '2026-02-16', 10000, 'Hostel', 'Pending'),
    (13, 3,  '2026-02-17', 10000, 'Hostel', 'Paid'),
    (14, 4,  '2026-02-18', 10000, 'Hostel', 'Paid'),
    (15, 5,  '2026-02-19', 10000, 'Hostel', 'Pending'),

    (16, 6,  '2026-03-05', 12000, 'Hostel', 'Paid'),
    (17, 7,  '2026-03-06', 12000, 'Hostel', 'Pending'),
    (18, 8,  '2026-03-07', 12000, 'Hostel', 'Paid'),
    (19, 9,  '2026-03-08', 12000, 'Hostel', 'Paid'),
    (20, 10, '2026-03-09', 12000, 'Hostel', 'Pending'),

    (21, 1,  '2026-03-15', 500, 'Fine', 'Paid'),
    (22, 2,  '2026-03-16', 750, 'Fine', 'Pending'),
    (23, 3,  '2026-03-17', 500, 'Fine', 'Paid'),
    (24, 4,  '2026-03-18', 1000, 'Fine', 'Paid'),
    (25, 5,  '2026-03-19', 750, 'Fine', 'Pending'),

    (26, 6,  '2026-04-05', 500, 'Fine', 'Paid'),
    (27, 7,  '2026-04-06', 750, 'Fine', 'Pending'),
    (28, 8,  '2026-04-07', 1000, 'Fine', 'Paid'),
    (29, 9,  '2026-04-08', 500, 'Fine', 'Paid'),
    (30, 10, '2026-04-09', 750, 'Fine', 'Pending'),

    (31, 1,  '2026-04-15', 5000, 'Other', 'Paid'),
    (32, 2,  '2026-04-16', 3000, 'Other', 'Pending'),
    (33, 3,  '2026-04-17', 4500, 'Other', 'Paid'),
    (34, 4,  '2026-04-18', 2500, 'Other', 'Paid'),
    (35, 5,  '2026-04-19', 3500, 'Other', 'Pending'),

    (36, 6,  '2026-05-05', 4000, 'Other', 'Paid'),
    (37, 7,  '2026-05-06', 3500, 'Other', 'Pending'),
    (38, 8,  '2026-05-07', 5000, 'Other', 'Paid'),
    (39, 9,  '2026-05-08', 3000, 'Other', 'Paid'),
    (40, 10, '2026-05-09', 4500, 'Other', 'Pending'),

    (41, 1,  '2026-05-15', 50000, 'Tuition', 'Paid'),
    (42, 2,  '2026-05-16', 50000, 'Tuition', 'Pending'),
    (43, 3,  '2026-05-17', 50000, 'Tuition', 'Paid'),
    (44, 4,  '2026-05-18', 50000, 'Tuition', 'Pending'),
    (45, 5,  '2026-05-19', 50000, 'Tuition', 'Paid'),

    (46, 6,  '2026-06-05', 45000, 'Tuition', 'Pending'),
    (47, 7,  '2026-06-06', 45000, 'Tuition', 'Paid'),
    (48, 8,  '2026-06-07', 45000, 'Tuition', 'Pending'),
    (49, 9,  '2026-06-08', 45000, 'Tuition', 'Paid'),
    (50, 10, '2026-06-09', 45000, 'Tuition', 'Pending');
    
INSERT INTO Timetable
    (TimetableID, CourseID, FacultyID, `Day`, TimeSlot, RoomNo)
VALUES
    (1,  101, 1,  'mon', '09:00-10:00', 101),
    (2,  102, 2,  'mon', '10:00-11:00', 102),
    (3,  103, 3,  'mon', '11:00-12:00', 201),
    (4,  104, 4,  'mon', '12:00-13:00', 202),

    (5,  105, 5,  'tue', '09:00-10:00', 301),
    (6,  106, 6,  'tue', '10:00-11:00', 302),
    (7,  107, 7,  'tue', '11:00-12:00', 401),
    (8,  108, 8,  'tue', '12:00-13:00', 402),

    (9,  109, 9,  'wed', '09:00-10:00', 501),
    (10, 110, 10, 'wed', '10:00-11:00', 502),
    (11, 111, 1,  'wed', '11:00-12:00', 103),
    (12, 112, 2,  'wed', '12:00-13:00', 104),

    (13, 113, 3,  'thu', '09:00-10:00', 203),
    (14, 114, 4,  'thu', '10:00-11:00', 204),
    (15, 115, 5,  'thu', '11:00-12:00', 303),
    (16, 116, 6,  'thu', '12:00-13:00', 304),

    (17, 117, 7,  'fri', '09:00-10:00', 403),
    (18, 118, 8,  'fri', '10:00-11:00', 404),
    (19, 119, 9,  'fri', '11:00-12:00', 503),
    (20, 120, 10, 'fri', '12:00-13:00', 504);

-- will show error of student assigned 2 hostles.
-- INSERT INTO HostelAllotment
--     (AllotmentID, HostelID, StudentID, RoomNo)
-- VALUES
--     (51, 2, 1, 206);


-- obtained marks is greater then max
-- INSERT INTO ExamResults
--     (ResultID, StudentID, ExamID, MarksObtained)
-- VALUES
--     (51, 1, 1, 105);

-- book is not available error
-- UPDATE LibraryBooks
-- SET CopiesAvailable = 0
-- WHERE BookID = 5;  -- set the book number 5 copies to 0 to get the error
-- INSERT INTO BookIssues
--     (IssueID, BookID, StudentID, IssueDate, ReturnDate)
-- VALUES
--     (31, 5, 1, '2026-08-23', NULL);

-- duplicate CourseFaculty assignment for the same faculty member, course, and semester.
-- INSERT INTO CourseFaculty
--     (CFID, FacultyID, CourseID, Semester)
-- VALUES
--     (31, 1, 1, 'Fall');

-- duplicate Attendance record for the same studen
-- INSERT INTO Attendance
--     (AttendanceID, StudentID, CourseID, `Date`, Status)
-- VALUES
--     (1, 1, 1, '2026-08-20', 'Present'); -- have to insert an data easy to identify the cause of error
-- INSERT INTO Attendance -- the error causing entry
--     (AttendanceID, StudentID, CourseID, `Date`, Status)
-- VALUES
--     (2, 1, 1, '2026-08-20', 'Absent');

-- double booking the same room
-- INSERT INTO Timetable -- insert a unique first,
--     (TimetableID, CourseID, FacultyID, `Day`, TimeSlot, RoomNo)
-- VALUES
--     (1, 1, 1, 'mon', '10:00-11:00', 101);
-- INSERT INTO Timetable  -- error causing entry
--     (TimetableID, CourseID, FacultyID, `Day`, TimeSlot, RoomNo)
-- VALUES
--     (2, 2, 2, 'mon', '10:00-11:00', 101);
-- -----------------------------------------------------------------------------------
-- Q3 -
-- get the name of all the students with pending names
-- SELECT s.StudentID, s.Name, p.PaymentID, p.Amount, p.PaymentType, p.`Date`
-- FROM Students s
-- JOIN Payments p ON s.StudentID = p.StudentID
-- WHERE p.Status = 'Pending';

-- faculty have more then 2 courses to teach
-- SELECT 
--     f.FacultyID,
--     f.Name,
--     COUNT(cf.CourseID) AS CourseCount
-- FROM Faculty f
-- JOIN CourseFaculty cf 
--     ON f.FacultyID = cf.FacultyID
-- GROUP BY f.FacultyID, f.Name
-- HAVING COUNT(cf.CourseID) > 2;

-- students that have borrowed more then 3 books 
-- SELECT 
--     s.StudentID,
--     s.Name,
--     COUNT(bi.BookID) AS BooksBorrowed
-- FROM Students s
-- JOIN BookIssues bi 
--     ON s.StudentID = bi.StudentID
-- GROUP BY s.StudentID, s.Name
-- HAVING COUNT(bi.BookID) > 3;


-- 15 queries
SELECT `Name`
FROM Faculty;

SELECT f.`Name`
FROM Faculty f
JOIN Departments d ON f.DeptID = d.DeptID
WHERE d.DeptName = 'Computer Science';

SELECT Title, CopiesAvailable
FROM LibraryBooks
WHERE CopiesAvailable < 3;

SELECT Title
FROM LibraryBooks
WHERE CopiesAvailable = 0; -- all book are available

SELECT `Name`, AdmissionYear
FROM Students
WHERE AdmissionYear > 2023;

SELECT `Name`
FROM Faculty
WHERE Designation = 'Professor';

SELECT CourseName
FROM Courses
WHERE Credits = 4;

SELECT s.`Name`
FROM Students s
JOIN Payments p ON s.StudentID = p.StudentID
WHERE p.Status = 'Pending';

SELECT DISTINCT s.`Name`
FROM Students s
JOIN BookIssues bi ON s.StudentID = bi.StudentID;

SELECT Title, YearPublished
FROM LibraryBooks
WHERE YearPublished > 2020;

SELECT f.`Name`
FROM Faculty f
JOIN CourseFaculty cf ON f.FacultyID = cf.FacultyID
GROUP BY f.FacultyID, f.`Name`
HAVING COUNT(cf.CourseID) > 2;

SELECT DISTINCT s.`Name`
FROM Students s
JOIN Attendance a ON s.StudentID = a.StudentID
WHERE a.Status = 'Absent';

SELECT CourseName
FROM Courses
WHERE SemesterOffered = 'Semester 2';

SELECT DISTINCT s.`Name`
FROM Students s
JOIN ExamResults er ON s.StudentID = er.StudentID
WHERE er.MarksObtained > 90;

SELECT 
    s.Name AS StudentName,
    lb.Title AS BookTitle
FROM Students s
JOIN BookIssues bi 
    ON s.StudentID = bi.StudentID
JOIN LibraryBooks lb 
    ON bi.BookID = lb.BookID;