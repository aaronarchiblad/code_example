--create a data set with 6 data points to test if my code works
create table if not exists points(
pid int,
x int,
y float
);

insert into points(pid, x, y)
values(1,1,2), (2,2,4), (3,2,2), (4,15,18), (5,19,18),(6,20,19);
--drop table points;

select * from points;

-- define k--
create or replace function NumOfCentroids(NumOfCentroids int)
returns int as
$$
declare k int;
begin
 k := NumOfCentroids;
 return k;
end
$$Language plpgsql;
--select NumOfCentroids(2);

--define distance function--
create or replace function distance(x1 float, y1 float, x2 float, y2 float)
returns float as
$$
select sqrt(power((x1-x2),2)+power((y1-y2),2));
$$Language sql;



--drop function selectcentroids(k int);

--Initialization(randomly select k centroids)--
create or replace function selectcentroids(k int)
returns table(cid int, x float, y float) as
$$
begin
 drop table if exists centroids;
 create table if not exists centroids(x float, y float);
 insert into centroids(x,y)
 select p.x, p.y from points p order by random() limit k;
 alter table centroids
 add cid serial;
 return query select c.cid, c.x, c.y from centroids c;
end
$$language plpgsql;
--select selectcentroids(2);

--update centroids--
create or replace function updatecentroid()
returns table(cx float, cy float, cid int) as
$$
begin
 drop table if exists kmeans;
 drop table if exists D;
 
 create table D as
 (select p.pid, p.x as px, p.y as py, c.cid, c.x as cx, c.y as cy, distance(p.x,p.y,c.x,c.y)as dist 
 from centroids c, points p);

 create table kmeans as 
 (select d.pid, d.px, d.py, d.cid, d.cx, d.cy, d.dist 
 from D d inner join (select pid, min(dist) as dist from D group by pid) j on d.pid = j.pid and d.dist = j.dist
 order by d.cid);

 delete from centroids;
 insert into centroids(x,y,cid)
 select cast(avg(px) as float) as cx, cast(avg(py) as float) as cy, k.cid from kmeans k
 group by k.cid;
 return query select k.cx, k.cy, k.cid from kmeans k;
end;
$$language plpgsql;

--select updatecentroid()
--select * from centroids

--main function--
drop function main_q1()；

create or replace function main_q1()
returns 
--table(i float) as 
table(cid int, cx float, cy float) as
$$
declare
 i int;
begin
 perform from selectcentroids(numofcentroids(2));

 drop table if exists diff_kmeans;
 create table diff_kmeans(diff float);
 insert into diff_kmeans values(1000);

 i := 1;
 while i < 50 or (select dk.diff from diff_kmeans dk) > 1
 loop
  drop table if exists tempcentroids;
  create table tempcentroids as table centroids;
 
  perform from updatecentroid();
  
  delete from diff_kmeans;
  
  with
  C1 as (select power((c.x-tc.x),2) as dist_x, power((c.y-tc.y),2) as dist_y, c.cid as centroid 
	from centroids c, tempcentroids tc where c.cid = tc.cid)
  insert into diff_kmeans select sum(sqrt(dist_x + dist_y)) as dist from C1;

  
  i:= i + 1;
 end loop;
 return query (select c.cid, c.cx, c.cy from kmeans c);
 
end;
$$ language plpgsql;

--run the main function--
select main_q1();
select * from diff_kmeans;
select * from centroids;
select * from kmeans;
select * from tempcentroids;

select power((c.x-tc.x),2), power((c.y-tc.y),2) from centroids c, tempcentroids tc where c.cid = tc.cid;

 

 while i < iter or (select dk.diff from diff_kmeans dk) > epsilon
 loop
  perform from updatecentroid();

  delete from diff_kmeans;
  with
  C1 as (select power((c.x-tc.x),2) as dist_x, power((c.y-tc.y),2) as dist_y, c.cid as centroid 
	from centroids c, tempcentroids tc where c.cid = tc.cid)
  insert into diff_kmeans select sqrt(sum(dist_x + dist_y)) as dist from C1;

  i:= i + 1;
  
  end loop;

 return query select * from centroids;
end; 
$$language plpgsql;

drop table centroids
select main_q1(2, 2, 0.01)


--Question 2--
--create data points--
create table hits(a int, b int);
insert into hits values(1,2),(1,3),(1,1),(2,1),(2,3),(3,2);
select array_agg() from hits where rownum = 1;
select a, array_agg(b) from hits
group by a
order by a;
select ctid from hits;
select * from hits;

with 
E1 AS (select distinct a.a, b.b from (select h.a from hits h) a, (select h.b from hits h) b order by a.a),
E2 AS (select h.a, h.b, count(h.a) as count from hits h group by (h.a, h.b) order by h.a)

--Adjacency matrix--
create or replace function matrix()
returns table(r int, c int, v int) as
$$
begin
 drop table if exists mat;
 create table mat(r int, c int, v int);
 insert into mat
 ((select distinct a.a, b.b, (select 1) as value from (select h.a from hits h) a, (select h.b from hits h) b where (a.a, b.b)
 in (select a, b from hits)))
 union
 ((select distinct a.a, b.b, (select 0) as value from (select h.a from hits h) a, (select h.b from hits h) b where (a.a, b.b)
 not in (select a, b from hits)))
 order by a,b;
end;
$$language plpgsql;

--initialize authority score--
drop function authorityscore(n int);
create or replace function authorityscore(n int)
returns table(r int, c int, v float) as
$$
declare
 i int;
begin
 i := 1;
 drop table if exists authority;
 create table authority(r int, c int, v float);
 for i in 1..n loop
  insert into authority values ((select i), (select 1), 1);
 end loop; 
return query select a.r, a.c, a.v from authority a;
end;
$$language plpgsql;

--normalize authority score--
create or replace function AuthorityNormalization()
returns table (r int, c int, v float) as
$$
begin
 drop table if exists normalizedauthority;
 create table normalizedauthority(r int, c int, v float);
 insert into normalizedauthority 
 select a.r, a.c, a.v/(select sqrt(sum(power(cast(aa.v as float),2))) from authority aa) as value from authority a;
end;
$$language plpgsql;

--initialize hub score--
create or replace function hubscore(n int)
returns table(r int, c int, v float) as
$$
declare
 i int;
begin
 i := 1;
 drop table if exists hub;
 create table hub(r int, c int, v float);
 for i in 1..n loop
  insert into hub values ((select i), (select 1), 1);
 end loop;
return query select * from hub;
end;
$$language plpgsql;

--Normalize hub score--
create or replace function HubNormalization()
returns table (r int, c int, v float) as
$$
begin
 drop table if exists normalizedhub;
 create table normalizedhub(r int, c int, v float);
 insert into normalizedhub
 select h.r, h.c, h.v/(select sqrt(sum(power(cast(hh.v as float),2))) from hub hh) as value from hub h;
end;
$$language plpgsql;

--transpose matrix--
create or replace function transpose()
returns table(r int, c int, v float) as
$$
begin
 drop table if exists tmat;
 create table tmat(r int, c int, v float);
 insert into tmat select m.c, m.r, m.v from mat m;
 return query select * from tmat;
end;
$$language plpgsql;

--update hub--
create or replace function updatehub()
returns table (r int, c int, v float) as
$$
begin
drop table if exists temp;
create table temp(r int, c int, v float);
 with 
 E1 as  (select rel.xr as r, rel.yc as c, sum(rel.value) as v from 
	(select distinct m.r as xr, m.c as xc, m.v as xv, t.r as yr,t.c as yc, t.v as yv, (m.v * t.v) as value 
	from mat m, tmat t where m.c = t.r) rel
	group by (rel.xr, rel.yc)
	order by rel.xr, rel.yc),
 E2 as (select e1.r as xr, e1.c as xc, e1.v as xv, h.r as yr, h.c as yc, h.v as yv, (e1.v * h.v) as sv
	from E1 e1, normalizedhub h where e1.c = h.r),
 E3 as	(select e2.xr as r, e2.yc as c, sum(e2.sv) from E2 e2 group by e2.xr, e2.yc order by e2.xr, e2.yc)
 insert into temp select * from E3;
 delete from hub; 
 insert into hub select * from temp;
 drop table if exists temp;
end
$$language plpgsql;

--update authority--
create or replace function updateauthority()
returns table (r int, c int, v float) as
$$
begin
drop table if exists temp;
create table temp(r int, c int, v float);
 with 
 E1 as  (select rel.xr as r, rel.yc as c, sum(rel.value) as v from 
	(select distinct t.r as xr, t.c as xc, t.v as xv, m.r as yr, m.c as yc, m.v as yv, (t.v * m.v) as value 
	from tmat t, mat m where t.c = m.r) rel
	group by (rel.xr, rel.yc)
	order by rel.xr, rel.yc),
 E2 as (select e1.r as xr, e1.c as xc, e1.v as xv, a.r as yr, a.c as yc, a.v as yv, (e1.v * a.v) as sv
	from E1 e1, normalizedauthority a where e1.c = a.r),
 E3 as	(select e2.xr as r, e2.yc as c, sum(e2.sv) from E2 e2 group by e2.xr, e2.yc order by e2.xr, e2.yc)
 insert into temp select * from E3;
 delete from authority; 
 insert into authority select * from temp;
 drop table if exists temp;
end
$$language plpgsql;


--drop function main_q2()
--main function--
create or replace function main_q2(iter int, epsilon float)
returns table (authority float, hub float) as
$$
declare
 n int;
 i int;
 
begin
 perform from matrix();
 n := (select max(m.r) from mat m);
 perform from transpose();
 perform from authorityscore(n);
 perform from hubscore(n);
 perform from authoritynormalization();
 perform from hubnormalization();

 i := 1;

 drop table if exists authoritydifference;
 create table authoritydifference(diff float);
 insert into authoritydifference values (1);

 drop table if exists hubdifference;
 create table hubdifference(diff float);
 insert into hubdifference values(1);
 
 
 while (i< iter and (select ad.diff from authoritydifference ad) > epsilon and (select hd.diff from hubdifference hd) > epsilon)
 loop
  drop table if exists tempauthority;
  create table tempauthority as table normalizedauthority;
  perform from updateauthority();
  perform from authoritynormalization();

  drop table if exists temphub;
  create table temphub as table normalizedhub;
  perform from updatehub();
  perform from hubnormalization();

  delete from authoritydifference;
  with 
  E1 as (select na.r, na.c, na.v as v1, t.v as v2 from normalizedauthority na, tempauthority t where na.r = t.r and na.c = t.c),
  E2 as (select abs(e1.v1 - e1.v2) as diff from E1 e1)
  insert into authoritydifference select sum(e2.diff) from E2 e2;

  delete from hubdifference;
  with
  H1 as (select nh.r, nh.c, nh.v as v1, t.v as v2 from normalizedhub nh, temphub t where nh.r = t.r and nh.c = t.c),
  H2 as (select abs(h1.v1 - h1.v2) as diff from H1 h1)
  insert into hubdifference select sum(h2.diff) from H2 h2;
  
  i := i + 1;
  end loop;

 drop table if exists AuthorityHubScore;
 create table AuthorityHubScore(Authority float, Hub float);
 insert into AuthorityHubScore select a.v, h.v from normalizedauthority a, normalizedhub h where a.r = h.r and a.c = h.c; 
 
 return query select * from AuthorityHubScore;
end;
$$language plpgsql;

--run main function--
select main_q2(10, 10e-10);
select * from authorityHubScore;

--Question 3--
create table if not exists subparts(pid int, sid int, quantity int);
insert into subparts values (1,2,4),(1,3,1),(3,4,1),(3,5,2);
select * from subparts;

create table parts(pid int, weight int);
insert into parts values (2,5),(4,50),(5,3);
select * from parts;

drop table subparts;
drop table parts;

create table if not exists subparts(pid int, sid int, quantity int);
insert into subparts values (1,3,2),(1,4,3),(3,2,1),(3,7,2),(4,2,3),(4,8,4),(2,5,3),(2,6,5),(8,9,2),(8,10,1),(9,11,2);

create table parts(pid int, weight int);
insert into parts values (7,30),(5,3),(6,15),(10,7),(11,10);

drop function weight()

create or replace function weight(part int)
returns table(totalweight float) as
--returns table (pid int, sid int, quantity int) as
$$
begin
 drop table if exists part_quantity;
 create table part_quantity as table subparts;

 drop table if exists part_weight;
 create table part_weight(id int, weight float);

 while exists (select pq1.pid, pq2.sid, (pq1.quantity*pq2.quantity) as quantity 
 from part_quantity pq1, part_quantity pq2 
 where pq1.sid = pq2.pid and (pq1.pid, pq2.sid) not in (select pq.pid, pq.sid from part_quantity pq))
 loop
  insert into part_quantity
  (select pq1.pid, pq2.sid, (pq1.quantity * pq2.quantity) as quantity 
   from part_quantity pq1, part_quantity pq2 
   where pq1.sid = pq2.pid and (pq1.pid, pq2.sid) not in (select pq.pid, pq.sid from part_quantity pq));
  end loop;

  with
  E1 as (select distinct pq.pid, pq.sid, pq.quantity, p.weight, (p.weight*pq.quantity) as TotalWeight
	from part_quantity pq, parts p where pq.sid = p.pid order by pq.pid),
  E2 as (select * from parts),
  E3 as (select e1.pid, sum(e1.totalweight) as totalweight from E1 group by e1.pid)
  insert into part_weight
  (select * from E3) union (select * from E2) order by pid;
  
 return query select pw.weight from part_weight pw where pw.id = part;  
end;
$$language plpgsql;

select weight(1);
select * from part_quantity order by pid;


--Question 4--
--1:Alice, 2:Bob, 3:Carol, 4:Eve, 5:Dave, 7:Mary, 8:Frank.
--assume in the table, all the members come from same family tree.
--structure
--level4: 1,2
--level3: 3
--level2: 4 5
--level1: 7
--level0: 8
create table if not exists pc(ancestor int, descendant int);
insert into pc values (1,3),(2,3),(3,5),(5,7),(4,7),(7,8);
select * from pc;


create or replace function ancestor_descendant()
returns table (ancester int, descendant int, generation int) as
$$
declare
 i int;
begin

 i := 1;

 drop table if exists output;
 create table output(ancestor int, descendant int, generation int);
 insert into output
 select *, (select 1) from pc;


 while exists (select pc1.ancestor, pc2.descendant from output pc1, pc pc2 
 where pc1.descendant = pc2.ancestor and 
 (pc1.ancestor, pc2.descendant) not in (select o.ancestor, o.descendant from output o))
 loop
  i := i + 1;
  insert into output
  (select pc1.ancestor, pc2.descendant, (select i) from output pc1, pc pc2 
   where pc1.descendant = pc2.ancestor and 
  (pc1.ancestor, pc2.descendant) not in (select o.ancestor, o.descendant from output o));

 end loop;

 return query (select * from output);
end;
$$language plpgsql;

--main function--
select ancestor_descendant();
select distinct * from output order by generation;
(select o.ancestor, max(generation) as level from output o group by o.ancestor)
UNION
(select u.ancestor, (select 0) from ((select pc.ancestor from pc) union (select pc.descendant from pc)) u
 where u.ancestor not in (select o.ancestor from output o)) order by ancestor;


--Question 5--
drop table if exists G;
create table G(source int, target int, distance float);
insert into G(source, target, distance) 
values (0,1,2),(0,4,10),(1,2,3),(1,4,7),(2,3,4),(3,4,5),(4,2,6);

select * from G;

--drop function main_q5(source int);
create or replace function main_q5(sourceinput int)
returns table (target int, distance float) as 
--returns table (a int, b int, distance float) as
$$
begin
 drop table if exists distance;
 create table distance as table G;

 while exists(with 
	      E1 as (select d1.source, d2.target, (d1.distance + d2.distance) as distance 
              from distance d1, distance d2 where d1.target = d2.source 
              and (d1.source, d2.target, (d1.distance + d2.distance)) 
              not in (select d.source, d.target, d.distance from distance d)),
              E3 as ((select * from distance) union (select * from E1)),
              E4 as (select e3.source, e3.target, min(e3.distance) as distance from E3 e3 group by e3.source, e3.target
              order by e3.source, e3.target)
              (select * from E4) except (select * from distance))

 loop
   with 
    E1 as (select d1.source, d2.target, (d1.distance + d2.distance) as distance 
           from distance d1, distance d2 where d1.target = d2.source 
           and (d1.source, d2.target, (d1.distance + d2.distance)) 
           not in (select d.source, d.target, d.distance from distance d)),
    E3 as ((select * from distance) union (select * from E1)),
    E4 as (select e3.source, e3.target, min(e3.distance) as distance from E3 e3 group by e3.source, e3.target
           order by e3.source, e3.target),
    E5 as ((select * from E4) except (select * from distance))
    insert into distance
    select * from E5;
           
 end loop;
 drop table if exists fulloutput_q5;
 create table fulloutput_q5(source int, target int, distance float);
 insert into fulloutput_q5
 select d.source, d.target, min(d.distance) as distance from distance d group by d.source, d.target
 order by d.source, d.target;
 insert into fulloutput_q5
 select *, (select 0) from (select distinct f1.source, f2.source from fulloutput_q5 f1, fulloutput_q5 f2 
 where f1.source = f2.source order by f1.source, f2.source) u;

 drop table if exists output_q5;
 create table output_q5(target int, distance float);
 insert into output_q5
 select f.target, f.distance from fulloutput_q5 f where f.source = sourceinput;
 
 
 drop table if exists distance;
 
 return query select o.target, o.distance from output_q5 o order by o.target;
end;
$$language plpgsql;

--run the program--
select main_q5(0);
select * from output_q5 order by target;
select * from fulloutput_q5 order by source,target;


--Question 6--

drop table if exists q6;
create table q6(key varchar(5), value int[]);
insert into q6 values ('A',array[1,2,3,4,5]),('B', array[11,12,13,14,15]);
select * from q6;

--mapper--
create or replace function mapper_q6(key varchar(5), value int[])
returns table (key int, value int) as
$$
select u.value, u.value from (select unnest(value) as value) u
$$language sql;

--preprocess the data--
drop table if exists input_map_q6;
select q.key, q.value into input_map_q6 from q6 q where q.key = 'A';
select * from input_map_q6;

--run the mapper function--
drop table if exists key_value_map_q6;
select u.key, u.value into key_value_map_q6 from input_map_q6 i, lateral(select t.key, t.value from mapper_q6(i.key, i.value) t) u;
select * from key_value_map_q6;

--group function--
--in this example, group does just output the same as the input.
drop function if exists group_q6(key int, value int);
create or replace function group_q6(key int, value int)
returns table (key int, value int) as
$$
select key, value
$$language sql;

drop table if exists input_reducer_q6;
select u.key, u.value into input_reducer_q6 from key_value_map_q6 k6, lateral(select t.key, t.value from group_q6(k6.key,k6.value) t) u;
select * from input_reducer_q6;

--reduce function--
--in this case, the reduece function also output the same as the input.
drop function if exists reducer_q6(key int, value int);
create function reducer_q6(key int, value int)
returns table (key int, value int) as
$$
select key, value
$$language sql;

select u.key, u.value from input_reducer_q6 i6, lateral(select t.key, t.value from reducer_q6(i6.key, i6.value) t) u;

--Question 7--
drop table if exists q7_R;
create table q7_R(A int);
insert into q7_R values (1),(2),(3);
select * from q7_R;

drop table if exists q7_S;
create table q7_S(A int);
insert into q7_S values (1),(2),(5);
select * from q7_S;

drop table if exists q7;
create table q7(doc_id text, value text[]);
insert into q7 values('R',array[1,2,3]),('S', array[1,2,5]);
select * from q7;

--mapper--
create or replace function mapper_q7(key varchar(5), bag_of_value text[])
returns table(key varchar(5), value varchar(5)) as
$$
select key, u.value
from (select unnest (bag_of_value) as value) as u;
$$language sql;

drop table if exists map_q7;
select u.key, u.value into map_q7
from q7 q, lateral(select t.key, t.value from mapper_q7(q.doc_id, q.value) t) u;
select * from map_q7;

--grouper--
drop table if exists input_reducer_q7;
select distinct m7.value as key, 
(select array(select m7_1.key from map_q7 m7_1 where m7.value = m7_1.value)) as value
into input_reducer_q7 from map_q7 m7;
select * from input_reducer_q7 order by key;

--reducer--
create or replace function reducer_q7(key varchar(5), value varchar(5)[])
returns table (key varchar(5), value varchar(5)[]) as
$$
select key, value
where cardinality(value) = 1 and cast(value as text[]) = array['R'];
$$language sql;

select u.key, u.value
from input_reducer_q7 i7, lateral(select t.key, t.value from reducer_q7(i7.key, i7.value) t) u;

--Question 8--
drop table if exists q8;
create table q8(key text, value int[]);
insert into q8 values ('R',array[11,1]), ('R',array[12,1]), ('R',array[13,2]), ('R',array[1,5]), ('R',array[2,5]), ('S',array[1,100]), 
('S',array[2,101]), ('S',array[7,1]);
select * from q8;

drop table if exists mapper;
select u.val2 as key, array[u.key, cast(val1 as text)] as value 
from (select key, value[1] as val1, value[2] as val2 from q8 where key = 'R') u
union
(select u.val1 as key, array[u.key, cast(val2 as text)] as value 
from (select key, value[1] as val1, value[2] as val2 from q8 where key = 'S') u)
order by key, value;


--map function--
drop function mapper_q8(key text, value int[])
create or replace function mapper_q8(key text, value int[])
returns table(key text, value text[]) as
$$
select cast (value[2] as text) as key, array[key, cast(value[1] as text) ] as value where key = 'R'
union
select cast (value[1] as text) as key, array[key, cast(value[2] as text) ] as value where key = 'S';
$$language sql;

drop table if exists input_group_q8;
select u.key, u.value into input_group_q8
from q8 q, lateral(select t.key, t.value from mapper_q8(q.key, q.value) t) u order by u.key, u.value;
select * from input_group_q8;

--group function output the same as input--
select * from input_group_q8;

--reduce function--
--input--
select * from input_group_q8;

with
E as (select key, value[1] as val1, value[2] as val2 from input_group_q8)
select e1.val2 as value1, e2.val2 as value2 from E e1, E e2 where e1.key = e2.key and e1.val1 = 'R' and e2.val1 = 'S';
