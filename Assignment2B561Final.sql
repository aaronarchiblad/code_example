--(1)
CREATE TABLE Ax(
a VARCHAR(30)
);

INSERT INTO Ax(a)
VALUES(1);
INSERT INTO Ax(a)
VALUES(2);
INSERT INTO Ax(a)
VALUES(3);

CREATE TABLE Bx(
b VARCHAR(30)
);

INSERT INTO Bx(b)
VALUES(1);
INSERT INTO Bx(b)
VALUES(3);

--------------------------------------------------------

SELECT empty_a_minus_b AS empty_a_minus_b, empty_b_minus_a AS empty_b_minus_a, empty_a_intersection_b AS empty_a_intersection_b FROM 
(SELECT NOT EXISTS(SELECT a.a FROM Ax a EXCEPT SELECT b.b FROM Bx b) AS empty_a_minus_b) AS foo1,
(SELECT NOT EXISTS(SELECT b.b FROM Bx b EXCEPT SELECT a.a FROM Ax a) AS empty_b_minus_a) AS foo2,
(SELECT EXISTS (SELECT a.a FROM Ax a INTERSECT SELECT b.b FROM Bx b) AS empty_a_intersection_b) AS foo3;

--(2)
CREATE TABLE A(
X FLOAT
);

INSERT INTO A(X)
VALUES(1);
INSERT INTO A(X)
VALUES(2);
INSERT INTO A(X)
VALUES(3);
INSERT INTO A(X)
VALUES(4);
INSERT INTO A(X)
VALUES(5);

SELECT X, SQRT(X) AS squared_root_x, X^2 AS x_squared, 2^X AS two_to_the_power_x,  CAST(X AS bigint)! AS x_factorial, ln(x) AS logarithm_x FROM A;

--(3)
CREATE TABLE p(
p boolean
);

INSERT INTO p(p)
VALUES(TRUE);
INSERT INTO p(p)
VALUES(FALSE);
INSERT INTO p(p)
VALUES(NULL);

SELECT * FROM p;

CREATE TABLE q(
q boolean
);

INSERT INTO q(q)
VALUES(TRUE);
INSERT INTO q(q)
VALUES(FALSE);
INSERT INTO q(q)
VALUES(NULL);

SELECT * FROM q;

CREATE TABLE r(
r boolean
);

INSERT INTO r(r)
VALUES(TRUE);
INSERT INTO r(r)
VALUES(FALSE);
INSERT INTO r(r)
VALUES(NULL);

SELECT * FROM r;
------------------------------------

SELECT p.p, q.q, r.r, NOT(p AND NOT(q)) AND NOT(r) AS value FROM p p, q q, r r;

--(4)
CREATE TABLE A_four_a(
A int
);

INSERT INTO A_four_a(A)
VALUES(1);
INSERT INTO A_four_a(A)
VALUES(2);

SELECT * FROM A_four_a;

CREATE TABLE B_four_a(
B int
);

INSERT INTO B_four_a(B)
VALUES(1);
INSERT INTO B_four_a(B)
VALUES(4);
INSERT INTO B_four_a(B)
VALUES(5);

SELECT * FROM B_four_a;

----------------------------------------
--(a)
/*USE INTERSECTION*/
SELECT EXISTS(
SELECT A FROM A_four_a
INTERSECT
SELECT B FROM B_four_a);

/*NOT USE INTERSECTION*/
SELECT EXISTS(
SELECT A FROM A_four_a WHERE A IN (SELECT B FROM B_four_a));

--(b)
/*USE INTERSECTION*/
SELECT NOT EXISTS
(SELECT A FROM A_four_a
INTERSECT
SELECT B FROM B_four_a);

/*NOT USE INTERSECTION*/
SELECT NOT EXISTS
(SELECT A FROM A_four_a WHERE A IN (SELECT B FROM B_four_a));

--(c)
CREATE TABLE A_four_c(
A FLOAT
);

INSERT INTO A_four_c(A)
VALUES(2);

SELECT * FROM A_four_c;
----------------------------
CREATE TABLE B_four_c(
B FLOAT
);

INSERT INTO B_four_c(B)
VALUES(1);
INSERT INTO B_four_c(B)
VALUES(2);

SELECT * FROM B_four_c;

/*USE EXCEPT*/
SELECT NOT EXISTS(
SELECT A FROM A_four_c EXCEPT SELECT B FROM B_four_c);

/* NOT USE EXCEPT*/
SELECT NOT EXISTS
(SELECT A FROM A_four_c WHERE A NOT IN (SELECT B FROM B_four_c));

--(d)
------------------------
CREATE TABLE A_four_d(
A FLOAT
);

INSERT INTO A_four_d(A)
VALUES(2);

SELECT * FROM A_four_d;

CREATE TABLE B_four_d(
B FLOAT
);

INSERT INTO B_four_d(B)
VALUES(2);

SELECT * FROM B_four_d;
-------------------------
/*USE EXCEPT*/
SELECT NOT EXISTS
(SELECT A FROM A_four_d EXCEPT (SELECT B FROM B_four_d)
UNION
SELECT B FROM B_four_d EXCEPT (SELECT A FROM A_four_d));

/*Not USE EXCEPT*/
SELECT NOT EXISTS
(SELECT A FROM A_four_d WHERE A NOT IN (SELECT B FROM B_four_d)
UNION
SELECT B FROM B_four_d WHERE B NOT IN (SELECT A FROM A_four_d));

--(e)
/*USE EXCEPT*/
SELECT EXISTS
(SELECT A FROM A_four_d EXCEPT (SELECT B FROM B_four_d)
UNION
SELECT B FROM B_four_d EXCEPT (SELECT A FROM A_four_d));

/*NOT USE EXCEPT*/
SELECT EXISTS
(SELECT A FROM A_four_d WHERE A NOT IN (SELECT B FROM B_four_d)
UNION
SELECT B FROM B_four_d WHERE B NOT IN (SELECT A FROM A_four_d));

--(f)
CREATE TABLE A_four_f(
A FLOAT
);

INSERT INTO A_four_f(A)
VALUES(1);
INSERT INTO A_four_f(A)
VALUES(2);
INSERT INTO A_four_f(A)
VALUES(3);

SELECT * FROM A_four_f;

CREATE TABLE B_four_f(
B FLOAT
);

INSERT INTO B_four_f(B)
VALUES(1);
INSERT INTO B_four_f(B)
VALUES(2);
INSERT INTO B_four_f(B)
VALUES(3);

SELECT * FROM B_four_f;
--------------------------------

/*USE INTERSECT*/
CREATE OR REPLACE VIEW intersection AS 
(SELECT A FROM A_four_f
INTERSECT
SELECT B FROM B_four_f);

SELECT * FROM intersection;

SELECT EXISTS(
SELECT DISTINCT i1.A
FROM intersection i1, intersection i2
WHERE i1.A <> i2.A);

/*NOT USE INTERSECT*/

CREATE OR REPLACE VIEW AB AS
(SELECT a.A FROM A_four_f a WHERE a.A IN (SELECT b.B FROM B_four_f b));

SELECT EXISTS(
SELECT DISTINCT i1.A
FROM AB i1, AB i2, AB i3
WHERE i1.A <> i2.A AND i1.A <> i3.A AND i2.A <> i3.A);

--(g)
CREATE VIEW AB_g AS 
(SELECT A FROM A_four_a
INTERSECT
(SELECT B FROM B_four_a));

SELECT * FROM AB_g

SELECT EXISTS
(SELECT * FROM AB_g)
AND
(SELECT NOT EXISTS
(SELECT ab1.A FROM AB_g ab1, AB_g ab2
WHERE ab1.A <> ab2.A))

--(h)
CREATE TABLE A_four_h(
A FLOAT
);

INSERT INTO A_four_h(A)
VALUES(1);
INSERT INTO A_four_h(A)
VALUES(2);

SELECT * FROM A_four_h;

CREATE TABLE B_four_h(
B FLOAT
);

INSERT INTO B_four_h(B)
VALUES(3);
INSERT INTO B_four_h(B)
VALUES(4);

SELECT * FROM B_four_h;

CREATE TABLE C_four_h(
C FLOAT
);

INSERT INTO C_four_h(C)
VALUES(1);
INSERT INTO C_four_h(C)
VALUES(3);
INSERT INTO C_four_h(C)
VALUES(4);

SELECT * FROM C_four_h;

---------------------------

CREATE OR REPLACE VIEW AB AS
(SELECT A FROM A_four_h
UNION
SELECT B FROM B_four_h);

SELECT a FROM AB;

SELECT NOT EXISTS
(SELECT c FROM C_four_h EXCEPT (SELECT a FROM AB));

--(i)
CREATE TABLE A_four_i(
A FLOAT
);

INSERT INTO A_four_i(A)
VALUES(1);
INSERT INTO A_four_i(A)
VALUES(2);
INSERT INTO A_four_i(A)
VALUES(3);

SELECT * FROM A_four_i;

CREATE TABLE B_four_i(
B FLOAT
);

INSERT INTO B_four_i(B)
VALUES(2);
INSERT INTO B_four_i(B)
VALUES(3);

SELECT * FROM B_four_i;

CREATE TABLE C_four_i(
C FLOAT
);

INSERT INTO C_four_i(C)
VALUES(2);

SELECT * FROM C_four_i;

--------------------------------
CREATE OR REPLACE VIEW A_B AS
(SELECT a.A FROM A_four_i a
EXCEPT
SELECT b.B FROM B_four_i b);

CREATE OR REPLACE VIEW BC_i AS
(SELECT a.B FROM B_four_i a
INTERSECT
SELECT c.C FROM C_four_i c
)



CREATE VIEW A_BAB AS
SELECT a.A FROM A_B a
UNION
SELECT bc.B FROM BC_i bc

SELECT * FROM A_BAB

SELECT EXISTS
(SELECT a.A FROM A_BAB a)

--there are something in there
SELECT EXISTS
(SELECT a.A FROM A_BAB a)
AND
--there are not more than 2 elements there
(SELECT NOT EXISTS
(SELECT DISTINCT a1.A FROM A_BAB a1, A_BAB a2, A_BAB a3 WHERE a1.A <> a2.A AND a1.A <> a3.A AND a2.A <> a3.A))
AND
--there are not 1 elements there
(SELECT NOT EXISTS
((SELECT a.A FROM A_BAB a)
EXCEPT
(SELECT DISTINCT a1.A FROM A_BAB a1, A_BAB a2 WHERE a1.A <> a2.A)))

--(5)
--(a)
CREATE TABLE Point(
pid INT,
x FLOAT,
y FLOAT
);

ALTER TABLE Point
ADD PRIMARY KEY(pid);

INSERT INTO Point(pid,x,y)
VALUES(1,0,0);
INSERT INTO Point(pid,x,y)
VALUES(2,0,1);
INSERT INTO Point(pid,x,y)
VALUES(3,2,0);
INSERT INTO Point(pid,x,y)
VALUES(4,2,3);

--DELETE FROM Point;
SELECT * FROM Point;
----------------------------------
CREATE OR REPLACE FUNCTION distance (x1 float, x2 float, y1 float, y2 float)
RETURNS FLOAT AS
$$
SELECT SQRT((x2-x1)^2 + (y2-y1)^2);
$$LANGUAGE SQL;

SELECT p1.pid, p2.pid FROM Point p1, Point p2
WHERE (distance(p1.x, p2.x, p1.y, p2.y) >= ALL (SELECT distance(p1.x, p2.x, p1.y, p2.y) FROM Point p1, Point p2)) 

--(6)--
CREATE TABLE W1(
A INT PRIMARY KEY,
B VARCHAR(5)
);

ALTER TABLE W1
ADD PRIMARY KEY(A);

INSERT INTO W1(A,B)
VALUES(1, 'John');
INSERT INTO W1(A,B)
VALUES(2, 'Ellen');
INSERT INTO W1(A,B)
VALUES(3, 'Ann');

SELECT * FROM W1;

CREATE TABLE W2(
A INT PRIMARY KEY,
B VARCHAR(5)
);
ALTER TABLE W2
DROP CONSTRAINT W2_pkey;

INSERT INTO W2(A,B)
VALUES(1,'John');
INSERT INTO W2(A,B)
VALUES(2,'Ellen');
INSERT INTO W2(A,B)
VALUES(2,'Linda');
INSERT INTO W2(A,B)
VALUES(3,'Ann');
INSERT INTO W2(A,B)
VALUES(4,'Ann');
INSERT INTO W2(A,B)
VALUES(4,'Nick');
INSERT INTO W2(A,B)
VALUES(4,'Vince');
INSERT INTO W2(A,B)
VALUES(4,'Lisa');
-------------------------
--A:
--NULL:
CREATE VIEW NUL AS(
(SELECT A
FROM W2
WHERE A = NULL));

--NOT UNIQUE
CREATE OR REPLACE VIEW UNI AS (
SELECT DISTINCT u.A1, u.B1 FROM
((SELECT w1.A AS A1, w1.B AS B1, w2.A AS A2, w2.B AS B2
FROM W2 w1, W2 w2
WHERE w1.A = w2.A)
EXCEPT
(SELECT w1.A, w1.B, w2.A, w2.B
FROM W2 w1, W2 w2
WHERE w1.A = w2.A AND w1.B = w2.B)) u);

CREATE VIEW A6 AS
(SELECT * FROM NUL
UNION
SELECT * FROM UNI)

SELECT w.A FROM W2 w WHERE NOT EXISTS (SELECT * FROM A6)
UNION
SELECT a.A FROM A6 a WHERE EXISTS (SELECT * FROM A6)

--Question 2--
CREATE TABLE Student
(Sid INT PRIMARY KEY,
Sname VARCHAR(15)
);
CREATE TABLE Major
(Sid INT,
Major VARCHAR(15),
PRIMARY KEY(Sid, Major)
);

ALTER TABLE Major
ADD FOREIGN KEY(Sid) REFERENCES Student(Sid);

CREATE TABLE Book
(BookNo INT PRIMARY KEY,
Title VARCHAR(30),
Price INT
);
CREATE TABLE Cites
(BookNo INT,
CitedBookNo INT,
PRIMARY KEY(BookNo,CitedBookNo)
);

ALTER TABLE Cites
ADD FOREIGN KEY(BookNo) REFERENCES Book(BookNo),
ADD FOREIGN KEY(CitedBookNo) REFERENCES Book(BookNo);

CREATE TABLE Buys
(Sid INT,
BookNo INT,
PRIMARY KEY(Sid,BookNo)
);

ALTER TABLE Buys
ADD FOREIGN KEY(Sid) REFERENCES Student(Sid),
ADD FOREIGN KEY(BookNo) REFERENCES Book(BookNo);

--GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO Student;
COPY Student FROM '/Users/Aaron/Downloads/student.csv' with (FORMAT CSV, DELIMITER E't');
COPY major FROM '/Users/Aaron/Downloads/major.csv' with (format csv,DELIMITER E'\t');
COPY cites FROM '/Users/Aaron/Downloads/cites.csv' WITH (FORMAT CSV, DELIMITER E'\t');
COPY Book FROM '/Users/Aaron/Downloads/book.csv' WITH ( FORMAT CSV, DELIMITER E'\t');
COPY buys FROM '/Users/Aaron/Downloads/buys.csv' WITH (FORMAT CSV, DELIMITER E'\t');


--(7)--
SELECT b.Title FROM Book b WHERE b.Price <= 40 AND b.PRICE >= 20; 

--(8)--
SELECT DISTINCT s.Sid, s.Sname
FROM Student s, 
(SELECT bs.Sid
FROM Buys bs
WHERE bs.BookNo IN 
(SELECT v.BookNo
FROM (SELECT u.BookNo, u.BookPrice, u.CitedBookNo, u.CitedBookPrice FROM
(SELECT b1.BookNo AS BookNo, b1.Price AS BookPrice, b2.BookNo AS CitedBookNo, b2.Price AS CitedBookPrice
FROM Book b1, Book b2
WHERE ((b1.BookNO, b2.BookNo) IN (SELECT c.BookNo, c.CitedBookNo FROM Cites c))) u
WHERE u.BookPrice > u.CitedBookPrice) v)) w
WHERE s.Sid = w.Sid;

--(9)--
SELECT b.BookNo
FROM Book b
WHERE b.BookNo IN (SELECT c.CitedBookNo FROM Cites c WHERE c.BookNo IN (SELECT c1.CitedBookNo FROM Cites c1));

--(10)--
SELECT b.BookNo FROM Book b WHERE b.BookNo NOT IN (SELECT c.CitedBookNo FROM cites c);

--(11)--
--student with more than 2 majors
CREATE OR REPLACE VIEW doublemajor AS
SELECT m1.Sid, m1.Major AS Major1, m2.Major AS Major2
FROM Major m1, major m2
WHERE m1.Major > m2.Major AND m1.Sid = m2.Sid;
SELECT * FROM doublemajor

--Books withoutciting
CREATE OR REPLACE VIEW bookwithoutcite AS
SELECT b.BookNo
FROM Book b
WHERE b.BookNo NOT IN (SELECT c.CitedBookNo FROM cites c);
SELECT * FROM bookwithoutcite

--Students that buy some books without citing
CREATE OR REPLACE VIEW studentbuybookwithoutcite AS
SELECT bs.Sid
FROM Buys bs
WHERE bs.BookNo IN (SELECT BookNo FROM bookwithoutcite);
SELECT DISTINCT * FROM studentbuybookwithoutcite

--students that don't buy any book without citing
CREATE OR REPLACE VIEW studentdontbuybookwithoutciting AS
SELECT s.Sid
FROM Student s
WHERE s.Sid NOT IN (SELECT Sid FROM studentbuybookwithoutcite);
SELECT * FROM studentdontbuybookwithoutciting

--Students with at least two major and only buy books that were cited. 
SELECT DISTINCT st.Sid 
FROM studentdontbuybookwithoutciting st
WHERE st.Sid IN (SELECT Sid FROM doublemajor)

SELECT s.Sid, s.Sname FROM Student s WHERE s.Sid IN (SELECT DISTINCT st.Sid 
FROM studentdontbuybookwithoutciting st
WHERE st.Sid IN (SELECT Sid FROM doublemajor))

--(12)--
(SELECT DISTINCT s.Sid FROM Student s ORDER BY s.Sid)
EXCEPT
(SELECT DISTINCT bs.Sid FROM Buys bs WHERE bs.BookNo IN
(SELECT b.BookNo FROM Book b WHERE b.Price < 30) ORDER BY bs.Sid);

--(13)--
CREATE OR REPLACE VIEW buybook AS
SELECT bs.Sid, bs.BookNo, b.Price
FROM Buys bs, Book b
WHERE bs.BookNo = b.BookNo

SELECT * FROM buybook ORDER BY Sid

SELECT bb1.Sid, bb1.BookNo
FROM buybook bb1
WHERE bb1.Price <= ALL(SELECT bb2.Price FROM buybook bb2 WHERE bb2.Sid = bb1.Sid) ORDER BY bb1.Sid

--(14)--
SELECT b.BookNo FROM Book b
EXCEPT
(SELECT b.BookNo FROM Book b WHERE b.Price > SOME (SELECT b.Price FROM Book b));

--(15)--
SELECT s1.Sid, s2.Sid, b.BookNo
FROM Student s1, Student s2, Book b
WHERE s1.Sid <> s2.Sid AND b.BookNo IN ((SELECT b1.BookNo FROM Book b1, Buys bs1 WHERE bs1.Sid = s1.Sid AND b1.BookNo = bs1.BookNo)
UNION (SELECT b2.BookNo FROM Book b2, Buys bs2 WHERE bs2.Sid = s2.Sid AND b2.BookNo = bs2.BookNo)) AND  
b.BookNo NOT IN ((SELECT b1.BookNo FROM Book b1, Buys bs1 WHERE bs1.Sid = s1.Sid AND b1.BookNo = bs1.BookNo) INTERSECT
(SELECT b2.BookNo FROM Book b2, Buys bs2 WHERE bs2.Sid = s2.Sid AND b2.BookNo = bs2.BookNo));

--(16)--
--Students that bought no book in common
CREATE OR REPLACE VIEW nocommon AS
SELECT s1.Sid AS Sid1, s2.Sid AS Sid2
FROM Student s1, Student s2
WHERE s1.Sid < s2.Sid AND 
NOT EXISTS ((SELECT b1.BookNo FROM Buys bs1, Book b1 WHERE bs1.BookNo = b1.BookNo AND bs1.Sid = s1.Sid AND b1.BookNo 
IN (SELECT b2.BookNo FROM Buys bs2, Book b2 WHERE bs2.Sid = s2.Sid AND bs2.BookNo = b2.BookNo)));


--Student that bought more than two books in common
CREATE OR REPLACE VIEW morethantwo AS
(SELECT s1.Sid AS Sid1, s2.Sid AS Sid2
FROM Student s1, Student s2
WHERE s1.Sid < s2.Sid AND EXISTS (SELECT b1.BookNo, b2.BookNo FROM Book b1, Book b2, Buys bs1, Buys bs2 WHERE 
b1.BookNo <> b2.BookNo AND b1.BookNo = bs1.BookNo AND b2.BookNo = bs2.BookNo AND bs1.Sid = s1.Sid AND bs2.Sid = s1.Sid AND
b1.BookNo IN (SELECT b3.BookNo FROM Book b3, Buys bs3 WHERE bs3.SID = s2.Sid AND b3.BookNo = bs3.BookNo) AND 
b2.BookNo IN (SELECT b3.BookNo FROM Book b3, Buys bs3 WHERE bs3.SID = s2.Sid AND b3.BookNo = bs3.BookNo)));

--exactly one
(SELECT s1.Sid, s2.Sid FROM Student s1, Student s2 WHERE s1.Sid < s2.Sid)
EXCEPT
(SELECT * FROM nocommon)
EXCEPT
(SELECT * FROM morethantwo)


--(17)--
SELECT b.BookNo
FROM Book b
WHERE NOT EXISTS (SELECT s.Sid FROM Student s, Major m WHERE m.Sid = s.Sid AND m.Major = 'Biology' 
AND s.Sid NOT IN (SELECT bs.Sid FROM Buys bs WHERE bs.BookNo = b.BookNo));


--(18)--
SELECT b.BookNo FROM Book b
EXCEPT
(SELECT DISTINCT bs.BookNo FROM Buys bs);

--(19)--
--Books that every student buys (there does not exist a book that is not bought by any student)
CREATE OR REPLACE VIEW allbuy AS
SELECT b.BookNo
FROM Book b
WHERE NOT EXISTS (SELECT s.Sid FROM Student s WHERE s.Sid NOT IN (SELECT bs.Sid FROM Buys bs WHERE bs.BookNo = b.BookNo))

--Books that at least two students do not buy it
CREATE OR REPLACE VIEW atleasttwo AS
SELECT DISTINCT b.BookNo
FROM Book b, Student s1, Student s2
WHERE s1.Sid < s2.Sid AND b.BookNo IN 
((SELECT b3.BookNo FROM Book b3) EXCEPT 
(SELECT b1.BookNo FROM Buys bs1, Book b1 WHERE bs1.BookNo = b1.BookNo AND bs1.SId = s1.SId))
AND b.BookNo IN
((SELECT b3.BookNo FROM Book b3) EXCEPT 
(SELECT b2.BookNo FROM Buys bs2, Book b2 WHERE bs2.BookNo = b2.BookNo AND bs2.SId = s2.SId))
ORDER BY b.BookNo

--Books that were bought by all students but one
((SELECT b.BookNo
FROM Book b)
EXCEPT
(SELECT *
FROM allbuy))
EXCEPT
(SELECT *
FROM atleasttwo)

--(20)
SELECT s1.Sid, s2.Sid
FROM Student s1, Student s2
WHERE s1.Sid <> s2.Sid AND NOT EXISTS 
(SELECT b1.BookNo FROM Buys bs1, Book b1 WHERE bs1.Sid = s1.Sid AND bs1.BookNo = b1.BookNo AND b1.BookNo
NOT IN (SELECT b2.BookNo FROM Buys bs2, Book b2 WHERE bs2.Sid = s2.Sid AND bs2.BookNo = b2.BookNo)) ORDER BY s1.Sid