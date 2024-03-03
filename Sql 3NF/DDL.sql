
drop database if exists BusBookingSystem 

go
Create Database BusBookingSystem

on
(Name='BusBookingSystem_Data_1',
FileName='C:\Program Files\Microsoft SQL Server\MSSQL13.SA\MSSQL\DATA\BusBookingSystem_Data_1.mdf',
Size=25mb,
Maxsize=80mb,
FileGrowth=5%
)
Log on
(Name='BusBookingSystem_Log_1', 
FileName='C:\Program Files\Microsoft SQL Server\MSSQL13.SA\MSSQL\DATA\BusBookingSystem_Log_1.ldf',
Size=10mb,
Maxsize=50mb,
FileGrowth=2%
)
GO
use BusBookingSystem;
---------------------------------Table Creation-------------------------------------
drop table if exists Bus
create table Bus
(
BusID int Primary key ,
BusName Varchar (30),
BusType Varchar (30),
SeatNo numeric(30)  
)
Go
PRINT('Successfully Created')
go

drop table if exists [Route]
create table [Route]
(
RouteID int primary key,
RouteName varchar(50),
StartPoint varchar (50),
LastPoint varchar (50)
)
go
PRINT('Successfully Created')

go
drop table if exists Schedule
create table Schedule
(
ScheduleID int primary key,
DepartureTime time,
ArriveTime time
)
Go
PRINT('Successfully Created')

go
drop table if exists BookingDetails
Create table BookingDetails
(
BookingDetailsID int primary key not null,
CustomerName varchar (50),
CustomerGender varchar (50),
CustomerMobile varchar (50)
)
Go
PRINT('Successfully Created')

go
drop table if exists ScheduleDetails
Create table ScheduleDetails
(
ScheduleDetailsID int primary key not null,
ScheduleType varchar (50)
)
PRINT('Successfully Created')

go
drop table if exists Relation 
Create Table Relation
(
BusID int references Bus(BusID),
RouteID int references Route(RouteID),
ScheduleID int references Schedule(ScheduleID),
BookingDetailsID int references BookingDetails(BookingDetailsID),
ScheduleDetailsID int references ScheduleDetails(ScheduleDetailsID))
PRINT('Successfully Created')
------------------Create NonClustered Index-------------
go
Create NonClustered Index indexs_Bus
on Bus(BusID)
EXECUTE sp_helpindex bus;

-----------------------------ALTER TABLE----------------------------------------------------
----------------ADD COLUMN----------------------
Alter Table Rout
Add BreakPoint Varchar(50)
----------------DROP COLUMN---------------------
Alter Table Rout
Drop BreakPoint 

----------------DROP TABLE----------------------
DROP TABLE Bus

                       ---------- store procedure ----------------

--------Insert-------------
Go
 Create Proc Sp_Bus_Insert
 @BusID Int,
 @BusName Varchar(20)

As
 Insert into Bus(BusID,BusName)
 values (@BusID,@BusName)
 Exec Sp_Bus_Insert 11,'uniq'
Go
--------Update-------------
Go
Create Proc Sp_Bus_Update
@BusID Int,
@BusName Varchar(50)
As
 Update Bus SET BusName = @BusName
 WHERE BusID=@BusID
Go
EXEC Sp_Bus_Update 11,'Tripti'
Go
--------Delete-------------
Create Proc Sp_Bus_Delete
@BusID Int
As
DELETE FROM Bus WHERE BusID=@BusID
Go
EXEC Sp_Bus_Delete 11

-- PROCEDURE Out PARAMETER
GO
create  proc SP_Output
(@BusId int output)
	as
	select COUNT(@BusId) as Newcolumn
	from Bus
Execute SP_Input 15
-- Procedure with return ------
go
create  proc SP_Returns
(@BusId INT)
AS
    select BusId,BusName 
	from Bus
    where BusID =@BusId
go
declare @return_value int
Execute @return_value = SP_Returns @BusId = 60
select  'Return Value' = @return_value;

 -------------------FUNCTION-------------------

             -----------------------Table valued Function-------------------------
 go
 create function Fn_Bus
 ()
 Returns Table 
 Return
 (
 Select * from Bus
 )
 go
 Select * from dbo.Fn_Bus()

            -------------- scalar value function  --------------------
 go
Create Function fn_Scalarvalue()
RETURNS int
AS 
BEGIN
	declare @BusID int;
	set @BusID = (select count(re.BusID) As NumberOfBus
	from Relation re join Bus b on re.BusID = b.BusID
	where b.BusName = 'Heritage' group by re.BusID)
    RETURN @BusID;
END;
go
select  * from dbo.fn_Scalarvalue()GO
----------------Multi-State Function----------------------------------GOCREATE FUNCTION fn_Ptemp()RETURNS @OutTable TABLE(Busid VARCHAR(50),BusName VARCHAR(50), BusType VARCHAR(50) ,SeatNO numeric (30), UpdatedSeat numeric (30))BEGIN INSERT INTO @OutTable(Busid,BusName,BusType,SeatNO,UpdatedSeat)SELECT BusID,BusName,BusType,SeatNo,SeatNo-4FROM BusRETURNENDGO----------------Multi-State Function Testing------------------------------SELECT * FROM dbo.fn_Ptemp()GO
                                       --------Trigger-------------
-----BackTable----------
Create Table BusAudit
(
BookingDetailsID int primary key not null,
CustomerName varchar (50),
CustomerGender varchar (50),
CustomerMobile varchar (50),
UpdatedBy nvarchar (128),
UpdateOn datetime
)
go
--------After trigger Update----------
Create Trigger Tr_BusAudit
on Bookingdetails 
After Update,Insert
as
Begin
insert into BusAudit (BookingDetailsID,CustomerName,CustomerGender,CustomerMobile,B.UpdatedBy,UpdateOn)
select i.BookingDetailsID,i.CustomerName,i.CustomerGender,i.CustomerMobile,SUSER_NAME(),Getdate()
From Bookingdetails B
join Inserted i on B.BookingDetailsID=i.BookingDetailsID
End
Go
----------------AFTER TRIGGER TESTING---------------------------------
UPDATE BookingDetails
SET CustomerName='Tasfia'
WHERE BookingDetailsID=5
GO
SELECT * FROM BookingDetails
SELECT * FROM BusAudit
---------After TRIGGER  Update--------
Create Table DetailsLog
(
BookingDetailsID int primary key not null,
CustomerName varchar (50),
CustomerGender varchar (50),
CustomerMobile varchar (50)
)

go
Create Trigger Tr_Insert
on Bookingdetails 
After Insert, Update
as
Begin
insert into DetailsLog (BookingDetailsID,CustomerName,CustomerGender,CustomerMobile)
select i.BookingDetailsID,i.CustomerName,i.CustomerGender,i.CustomerMobile
From Bookingdetails B
join Inserted i on B.BookingDetailsID=i.BookingDetailsID
End
Go
---Test Trigger
insert into BookingDetails Values (12,'Shamim','Male',01721069911)
select * from BookingDetails
select * from DetailsLog


--------Insted of Trigger-------------
-----BackTable----------
Create Table  BackUpLog
(
BookingDetailsID int not null,
CustomerName varchar (50),
CustomerGender varchar (50),
CustomerMobile varchar (50),
Action varchar (50)
)
go
Create trigger BackUpLog
on bookingDetails
instead of Delete
As
Begin
Set nocount on
Declare @BookingDetailsId int
select BookingDetailsId=@BookingDetailsId 
From Deleted
If @BookingDetailsId=4
Begin 
Raiserror ('Record cannot be deleted',16,1)
Rollback
Insert into BackUpLog
Values (@BookingDetailsId,'Record cannot be deleted')
End
Else Begin 
Delete from BookingDetails 
Where BookingDetailsId=@BookingDetailsId
Insert into BackUpLog
Values (@BookingDetailsId,'Deleted')
End
End
go
----------------INSTEAD OF TRIGGER TESTING-----------------------------
DELETE BookingDetails
WHERE BookingDetailsID=4

Select * from BookingDetails
select * from BackUpLog

------------Create Merge------------------
create table BusMerge
(
BusID int Primary key not null,
BusName Varchar (30))


----------------------------------View------------------------
      --Schemabinding
go
Create VIew Vw_Sch
with schemabinding
as
select BookingDetailsID
from dbo.BookingDetails 
go
select * from Vw_Sch

--Encryption
go
Create VIew Vw_Enc
with Encryption
as
select BookingDetailsID
from dbo.BookingDetails 
go
select * from Vw_Enc

--Schemabinding And Encription Togather
go
create view Vw_Togather
with encryption,schemabinding
as
Select BookingDetailsID
from dbo.BookingDetails
go
Select * from Vw_Togather


