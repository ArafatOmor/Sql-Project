use BusBookingSystem
 -----------------------INSERT-------------------------
insert into Bus (BusID,BusName,BusType,SeatNo)values
                      (1,'Nabil','Non Ac',40),
                      (2,'Hanif','Non AC',44),
	                  (3,'Ena','AC',40),
	                  (4,'Shamoli','Non Ac',48),
	                  (5,'Nabil','AC',42),
	                  (6,'Alhamra ','Non Ac',46),
	                  (7,'Dipzol Paribahan',' AC',40),
	                  (8,'Heritage','Slepper',16),
	                  (9,'Heritage','Ac',38),
	                  (10,'Heritage','Non Ac',46);
go
insert into [Route] (RouteID,RouteName,StartPoint,LastPoint) values
						  (1,'Panchagar','Gabtoli','Panchagar'),
                          (2,'Rangpur','Abdullahpur','Pirganj'),
	                      (3,'Nilphamary','Mohakhali','Dimla'),
	                      (4,'Tangail','Gabtoli','Sherpur'),
	                      (5,'Chittagong','Saidabad','Agrabad'),
	                      (6,'Sylhet','Mohakhali','Moulovibazar'),
	                      (7,'Chadpur','Jatrabari','Sadar Chadpur'),
	                      (8,'Jajira','Saydabad','Pirojpur'),
	                      (9,'Dinajpur','Abdullahpur','Kalitola'),
	                      (10,'Rangpur','Majar Road','Taraganj  ');
						
insert into Schedule(ScheduleID,DepartureTime,ArriveTime) values
                           (1,'7:30 PM','05:00 AM'),
                           (2,'08:00 PM','06:00 AM'),
	                       (3,'08:30 PM','07:30 AM'),
	                       (4,'09:00 PM','8:00 AM'),
	                       (5,'11:00 PM','09:00 AM'),
	                       (6,'08:00 AM','09:00 PM'),
	                       (7,'06:00 AM','11:00 AM'),
	                       (8,'07:00 AM','12:00 PM'),
	                       (9,'11:00 AM','02:00 PM'),
	                       (10,'11:00 AM','08:00 PM');
						   
insert into BookingDetails values
                                 (1,'Monir Hossen','Male','01747813670'),
                                 (2,'Abu Bakar','Male','01487519754'),
	                             (3,'Arman Ahmad ','Male','01587441244'),
	                             (4,'Md Rokon','Male','0175952188'),
	                             (5,'Tasfia Tamima','Female','01721662211'),
	                             (6,'Sakib Islam','Male','01744758122'),
	                             (7,'Trisha','Female','01687412487'),
	                             (8,'Fahim Saleh','Male','01812451471'),
	                             (9,'Tanvir Ahmad','Male','01544121746'),
	                             (10,'Siyam Aahmad','Male','01845522120');

 insert into ScheduleDetails(ScheduleDetailsID,ScheduleType) values
                                   (1,'Night'),
                                   (2,'Evening'),
	                               (3,'Morning'),
	                               (4,'Evening'),
	                               (5,'Morning'),
	                               (6,'Night'),
	                               (7,'Morning'),
	                               (8,'Morning'),
	                               (9,'Evening'),
	                               (10,'Morning')

 insert into  Relation (BusID,RouteID,ScheduleID,BookingDetailsID,ScheduleDetailsID) values
						   (1,1,1,1,1),
                           (4,3,5,10,6),
						   (2,6,7,4,4),
						   (3,4,3,6,2),
						   (5,2,4,3,5),
						   (6,5,2,5,2),
						   (7,9,6,7,7),
						   (8,7,9,4,8),
						   (9,10,8,2,10),
						   (10,8,10,8,9) 

select * from Bus;
select * from [Route];
select * from Schedule;
select * from BookingDetails;
select * from ScheduleDetails;
select * from Relation
				
				
				----------------Jonining Table-----------------------
Select Bus.BusID,BusType,SeatNo, [Route].RouteName,StartPoint,LastPoint,Schedule.DepartureTime,ArriveTime,
BookingDetails.CustomerName,CustomerGender,CustomerMobile,ScheduleDetails.ScheduleType
From Relation Join Bus on
Relation.BusID = Bus.BusID Join [Route] on
Relation.RouteID = [Route].RouteID Join Schedule on
Relation.ScheduleID = Schedule.ScheduleID Join BookingDetails on
Relation.BookingDetailsID = BookingDetails.BookingDetailsID join ScheduleDetails on 
Relation.ScheduleDetailsID = ScheduleDetails.ScheduleDetailsID
;
---------------Jonining Table With Having---------------
Select Count(BusType) as Available,Bu.BusName,Ro.RouteName,Bo.CustomerName
From Relation Re 
Join Bus Bu on Re.BusID = Bu.BusID 
Join [Route] Ro on Re.RouteID = Ro.RouteID
Join BookingDetails Bo on Re.BookingDetailsID = Bo.BookingDetailsID
group by Bu.BusName, Ro.RouteName,Bo.CustomerName
having Bo.CustomerName = 'Arman Ahmad';

------------Sub Query------------------
Select b.CustomerName,b.CustomerGender,b.CustomerMobile,Schedule.ArriveTime
From BookingDetails b join Relation r
On b.BookingDetailsID = r.BookingDetailsID join 
Schedule on Schedule.ScheduleID = r.ScheduleID
Where CustomerName in (Select CustomerName from BookingDetails
Where BookingDetails.CustomerName = 'Abu Bakar')
go


Update Bus set BusName = 'Arafat' where BusID = 2;

----------------Delete Query------------------
delete Bus  where BusID = 2;

------------Cast---------------------
select cast('01-June-2023' AS date)

----------------Convert----------------
SELECT Datetime = CONVERT(datetime,'01-June-2023 10:00:10.00')
----------------searched case function-----------------
Select  CASE
    WHEN SeatNo <= 40 THEN 'Business Class'
    WHEN SeatNo >= 40 and SeatNo <=46  THEN 'Economy Class'
    
    ELSE  'Normal Class'
END AS ClassType
from Bus
go

------------------Insert Merge Value---------------
Insert into BusMerge
values (1, 'Nabil'),(2, 'Hanif'),(3, 'Ena'),(4,'Samoli')
go
-------------------Update Merge Value--------------
MERGE INTO dbo.Bus as B
USING dbo.BusMerge as M
        ON B.BusID = M.BusID
WHEN MATCHED THEN
    UPDATE SET
      B.BusName = M.BusName
      WHEN NOT MATCHED THEN 
      INSERT (BusID, BusName)
      VALUES (M.BusID, M.BusName);
go
select * from BusMerge;
---------------- CTE ----------------------
with Cte_TotalBus
(BusID,BusName) as (select Bus.BusID,count(BusName) as NumberOfBus
from Bus join Relation on Bus.BusID = Relation.BusID where BusName in (select BusName from Bus)
group by Bus.BusID)
select * from Cte_TotalBus;
Go
-------------------------------Fanctions -------------------------------
Select count(busname) as NumberOfBus from Bus
Select avg(SeatNo) as "Average Seat" from Bus;
Select Sum(SeatNo) as "Total Seat" from Bus;
Select max(SeatNo) as "Maximum Seat" from Bus;
Select min (SeatNo) as "Minimum Seat" from Bus;

Select BusName,count(BusID) as [ID]  from Bus
Group By Rollup (BusID,BusName);
-----------CUBE--------
select  BusID,BusName  from Bus GROUP BY CUBE(BusID,BusName) ORDER BY BusName;
--------Grouping sets---------
SELECT BusID,BusType FROM Bus GROUP BY grouping sets (BusID,BusType);

-------Over ------
SELECT BusID,BusName ,COUNT(*) OVER() as NoOfCount
 FROM  Bus ;
 Go
--iif ,choose function
select BusID,BusType,iif(BusType ='AC','Best','Good') as NewColumn from Bus
select BusID,BusName,Choose(BusID,'Non Ac','Good','Best') as NewColumn from Bus
--isnull,coalesce ---
select BusID,BusType,isnull(BusType,'Non Ac') as NewColumn from Bus
select BusID,BusType,coalesce(Bustype,'Non Ac') as NewColumn from Bus
--grouping
select BusID,BusName,grouping(BusName) from Bus
group by BusID,BusName
--ranking function 
select BookingDetailsID,row_number() over (partition by CustomerGender order by BookingDetailsID ) as Ranking from BookingDetails
select BookingDetailsID,rank() over (partition by CustomerGender order by BookingDetailsID ) as Ranking from BookingDetails
select BookingDetailsID,dense_rank() over (partition by CustomerGender order by BookingDetailsID) as NewColumn from BookingDetails
select BookingDetailsID,ntile(4)over (partition by price order by CustomerID) as NewColumn from BookingDetails
-- analytic function 
select BookingDetailsID,first_value(BookingDetailsID) over (partition by CustomerGender order by BookingDetailsID) as NewColumn from BookingDetails
select BookingDetailsID,last_value(BookingDetailsID) over (partition by CustomerGender order by BookingDetailsID) as NewColumn from BookingDetails
select BookingDetailsID,lag(BookingDetailsID) over (partition by CustomerGender order by BookingDetailsID) as NewColumn from BookingDetails
select BookingDetailsID,lead(BookingDetailsID) over (partition by CustomerGender order by BookingDetailsID) as NewColumn from BookingDetails
select BookingDetailsID,percent_rank()over (partition by CustomerGender order by BookingDetailsID) as NewColumn from BookingDetails
select BookingDetailsID,cume_dist()over (partition by CustomerGender order by BookingDetailsID) as NewColumn from BookingDetails
select BookingDetailsID,percentile_cont(0.5) within group (order by BookingDetailsID) over (partition by CustomerGender ) as NewColumn from BookingDetails
select BookingDetailsID,percentile_DISC(0.5) within group (order by BookingDetailsID) over (partition by CustomerGender ) as NewColumn from BookingDetails
 