CREATE TABLE Sailor
(
SId INT PRIMARY KEY,
Sname VARCHAR(20),
Rating INT,
Age INT
);

INSERT INTO Sailor VALUES
(22, 'Dustin', 7, 45
);

INSERT INTO Sailor VALUES
(29, 'Brutus', 1, 33
);

INSERT INTO Sailor VALUES
(31, 'Lubber', 8, 55
);

INSERT INTO Sailor VALUES
(32, 'Andy', 8, 55
);

INSERT INTO Sailor VALUES
(58, 'Rusty', 10, 35
);

INSERT INTO Sailor VALUES
(64, 'Horatio', 7, 35
);

INSERT INTO Sailor VALUES
(71, 'Zorba', 10, 16
);

INSERT INTO Sailor VALUES
(74, 'HOratio', 9, 35
);

UPDATE Sailor
SET Sname = 'Horatio' WHERE SId = 74;

INSERT INTO Sailor VALUES
(85, 'Art', 3, 25
);

INSERT INTO Sailor VALUES
(95, 'Bob', 3, 63
);

CREATE TABLE Boat
(
BId INT PRIMARY KEY,
Bname VARCHAR(15),
Colar VARCHAR(15)
);

ALTER TABLE Boat 
RENAME COLUMN colar TO color;

INSERT INTO Boat VALUES
(101, 'Interlake', 'blue'
);

INSERT INTO Boat VALUES
(102, 'Interlake', 'red'
);

INSERT INTO Boat VALUES
(103, 'Clipper', 'green'
);

INSERT INTO Boat VALUES
(104, 'Marine', 'red'
);

CREATE TABLE Reserve
(
SId INT REFERENCES Sailor (SId),
BId INT REFERENCES Boat(BId),
Day VARCHAR(10)
);

INSERT INTO Reserve VALUES
(22, 101, 'Monday'
);

INSERT INTO Reserve VALUES
(22, 102, 'Tuesday'
);

INSERT INTO Reserve VALUES
(22, 103, 'Wednesday'
);

INSERT INTO Reserve VALUES
(31, 102, 'Thursday'
);

INSERT INTO Reserve VALUES
(31, 103, 'Friday'
);

INSERT INTO Reserve VALUES
(31, 104, 'Saturday'
);

INSERT INTO Reserve VALUES
(64, 101, 'Sunday'
);

INSERT INTO Reserve VALUES
(64, 102, 'Monday'
);

INSERT INTO Reserve VALUES
(74, 103, 'Tuesday'
);

(a)
SELECT BId, Bname FROM Boat WHERE color = 'red';

(b)

SELECT Sailor.Sname FROM Sailor, Reserve WHERE Sailor.SId = Reserve.SId AND Reserve.BId = 103;

SELECT s.Sname FROM Sailor s, 
(SELECT s.SId FROM Sailor s, Reserve r WHERE s.SId = r.SId AND r.BID = 103) u 
WHERE s.SId = u.SId;

(c)
SELECT b.Bname FROM Boat b,
(SELECT DISTINCT b.BId FROM Boat b, Sailor s, Reserve r WHERE s.SId = r.SId AND b.BId = r.BId AND s.Rating < 8) u
WHERE b.BId = u.Bid;

(d)
SELECT s.Sname FROM Sailor s,
(SELECT DISTINCT s.SId FROM Sailor s, Boat b, Reserve r WHERE s.SId = r.SId AND b.BId = r.BId AND b.color = 'red' OR b.color = 'green') u
WHERE s.SId = u.SId;

(e)
SELECT s.Sname FROM Sailor s,
(SELECT s.SId FROM Sailor s, Boat b, Reserve r WHERE s.SId = r.SId AND b.BId = r.BId AND b.color = 'blue'
INTERSECT
SELECT s.SId FROM Sailor s, Boat b, Reserve r WHERE s.SId = r.SId AND b.BId = r.BId AND b.color = 'green') u
WHERE s.SId = u.SId;

(f)
SELECT s.Sname FROM Sailor s,
(SELECT r.SId FROM Reserve r GROUP BY r.SId HAVING COUNT(r.SID) >= 2) u
WHERE s.SId = u.SId;

(g)
SELECT s.Sname FROM Sailor s,
(SELECT s.SId FROM Sailor s WHERE s.SId NOT IN
(SELECT DISTINCT r.SId FROM Reserve r WHERE EXISTS(SELECT r.SId FROM Reserve r))) u
WHERE s.SId = u.SId;

