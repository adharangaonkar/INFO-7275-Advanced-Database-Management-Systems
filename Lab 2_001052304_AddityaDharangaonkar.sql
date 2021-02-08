
-- Lab 2

-- Part 1

/*
Given two sets of data as defined below, build a
data pipeline using the SQL MERGE function
to synchronize the destination data set with the source data set.
Keep an audit log of what's changed in the destination data set 
using the SQL OUTPUT command.

Regarding the UPDATE command, the customer id, order id, 
order date, and item id will not change.
*/

-- Source Data Set

create table SaleOrder
(OrderID int identity primary key,
 OrderDate date,
 CustomerID int);


create table OrderItem
(ItemID int identity primary key,
 OrderID int references SaleOrder(OrderID),
 Quantity int,
 UnitPrice money,
 LastModified datetime default getdate());


-- Destination Data Set


create table ItemsReport
(CustomerID int,
 OrderDate date,
 OrderID int,
 ItemID int primary key,
 Quantity int,
 UnitPrice money,
 LastModified datetime);  



-- Audit Log


CREATE TABLE ItemsAudit
 (
  Audit_PK INT  IDENTITY(1,1) NOT NULL
  ,CustomerID int
  ,OrderDate date
  ,OrderID int
  ,ItemID int
  ,OldQuantity int
  ,NewQuantity int
  ,OldUnitPrice money
  ,NewUnitPrice money
  ,NewLastModified datetime
  ,OldLastModified datetime
  ,[Action] CHAR(6) NULL
  ,ActionTime DATETIME DEFAULT GETDATE()
 );


 --------Inserting Data into the Tables------------


INSERT INTO SaleOrder (OrderDate, CustomerID) 
VALUES ('2021-02-04', 1), 
	   ('2021-02-05', 2), 
	   ('2021-02-06', 3),
	   ('2021-02-07',4);

INSERT INTO OrderItem (OrderID, Quantity, UnitPrice) 
VALUES (1, 10, 5), 
	   (2, 20, 10), 
	   (3, 30, 15), 
       (2, 40, 20);

INSERT INTO ItemsReport (CustomerID, OrderDate, OrderID, ItemID, Quantity, UnitPrice, LastModified) 
VALUES (1, '2021-02-04', 1, 1, 10, 5, getdate()), 
	   (2, '2021-01-05', 2, 2, 20, 10, getdate()),
	   (4, '2021-01-07', 2, 4, 40, 20, getdate()),
	   (2, '2021-01-08', 3, 5, 50, 25, getdate()),
	   (1, '2021-01-09', 3, 6, 60, 30, getdate());


--------------------------------------------------



MERGE ItemsReport
USING (SELECT so.OrderID, so.OrderDate, so.CustomerID, oi.ItemID, oi.Quantity, oi.UnitPrice, 
oi.LastModified FROM SaleOrder so JOIN OrderItem oi ON so.OrderID = oi.OrderID) AS Source
ON Source.ItemID = ItemsReport.ItemID
WHEN MATCHED THEN update set Quantity = Source.Quantity, UnitPrice = Source.UnitPrice, 
LastModified = getdate()
WHEN NOT MATCHED BY SOURCE THEN delete
WHEN NOT MATCHED THEN INSERT (CustomerID, OrderDate, OrderID, ItemID, Quantity, UnitPrice, 
LastModified) VALUES (Source.CustomerID, Source.OrderDate, Source.OrderID, Source.ItemID, 
Source.Quantity, Source.UnitPrice, Source.LastModified)
OUTPUT $action,
ISNULL(Deleted.CustomerID, Inserted.CustomerID),
ISNULL(Deleted.OrderDate, Inserted.OrderDate),
ISNULL(Deleted.OrderID, Inserted.OrderID),
ISNULL(Deleted.ItemID, Inserted.ItemID),
Deleted.Quantity,
Inserted.Quantity,
Deleted.UnitPrice,
Inserted.UnitPrice,
Deleted.LastModified,
Inserted.LastModified
INTO ItemsAudit ([Action], CustomerID, OrderDate, OrderID, ItemID, OldQuantity, NewQuantity, 
OldUnitPrice, NewUnitPrice, NewLastModified, OldLastModified);

select * from [dbo].[SaleOrder];
select * from [dbo].[OrderItem];
select * from [dbo].[ItemsReport];
select * from [dbo].[ItemsAudit];


--------------------------------------------PART 2-----------------------------------------

/*
Given two data sets as defined below, build a
data pipeline using the SQL trigger
to synchronize the destination data set with the source data set.
Keep an audit log of what's changed in the destination data set.

Regarding the UPDATE command:
The customer id will not change.
*/


-- Source Data Set

CREATE TABLE Customer
(CustomerID INT IDENTITY PRIMARY KEY,
 LastName VARCHAR(50),
 FirstName VARCHAR(50),
 Email VARCHAR(50),
 Phone VARCHAR(20),
 TotalPurchase int,
 ModifiedDate DATETIME DEFAULT getdate());


-- Destination Data Set

CREATE TABLE CustomerReport
(CustomerID INT PRIMARY KEY,
 LastName VARCHAR(50),
 FirstName VARCHAR(50),
 Email VARCHAR(50),
 Phone VARCHAR(20),
 TotalPurchase int,
 ModifiedDate DATETIME DEFAULT getdate());


-- Audit Log

CREATE TABLE AuditCustomer
 (
  Audit_PK  INT  IDENTITY(1,1) NOT NULL
  ,CustomerID  INT  NOT NULL
  ,NewLastName VARCHAR(50)
  ,OldLastName VARCHAR(50)
  ,NewFirstName VARCHAR(50)
  ,OldFirstName VARCHAR(50)
  ,NewEmail VARCHAR(50)
  ,OldEmail VARCHAR(50)
  ,NewPhone VARCHAR(20)
  ,OldPhone VARCHAR(20)
  ,NewTotalPurchase int
  ,OldTotalPurchase int
  ,NewModifiedDate DATETIME
  ,OldModifiedDate DATETIME
  ,[Action] CHAR(6) NULL
  ,ActionTime DATETIME DEFAULT GETDATE()
 );


 ------------------TRIGGER---------------------

 GO
CREATE TRIGGER Customer_Trigger
ON Customer
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
    MERGE CustomerReport dest
    USING Customer Source
	ON Source.CustomerID = dest.CustomerID
    WHEN Matched THEN 
        UPDATE SET LastName = Source.LastName,
			FirstName = Source.FirstName,
			Email = Source.Email,
			Phone = Source.Phone,
			TotalPurchase = Source.TotalPurchase,
			ModifiedDate = Source.ModifiedDate
    WHEN NOT MATCHED BY SOURCE THEN
        DELETE
    WHEN NOT MATCHED THEN
        INSERT (CustomerID, LastName, FirstName, Email, Phone, TotalPurchase, ModifiedDate) 
		VALUES (Source.CustomerID, Source.LastName, Source.FirstName, Source.Email, Source.Phone, Source.TotalPurchase, Source.ModifiedDate)
OUTPUT $action,
		ISNULL (Deleted.CustomerID, Inserted.CustomerID),
        Deleted.FirstName, Inserted.FirstName,
		Deleted.LastName, Inserted.LastName,
		Deleted.Email, Inserted.Email,
		Deleted.Phone, Inserted.Phone,
		Deleted.TotalPurchase, Inserted.TotalPurchase,
		Deleted.ModifiedDate, Inserted.ModifiedDate
        INTO AuditCustomer(
		[action],
		CustomerID,
		OldFirstName,
		NewFirstName,
		OldLastName,
		NewLastName,
		OldEmail,
		NewEmail,
		OldPhone,
		NewPhone,
		OldTotalPurchase,
		NewTotalPurchase,
		OldModifiedDate,
		NewModifiedDate);
END;


-------------------Inserting Data into Tables------------------------

INSERT INTO Customer (LastName, FirstName, Email, Phone, TotalPurchase) 
VALUES ('Additya', 'Dharangaonkar', 'ad@gmail.com', '9422180648', 10), 
	   ('Andrew', 'Robertson', 'andrewrobertson@gmail.com', '9420497136', 15), 
	   ('Joe', 'Gomez', 'joegomez@gmail.com', '8889922119', 20),
	   ('Jordan', 'Henderson', 'jordanhendorson@gmail.com', '9922771097', 25);


---Testing Update
UPDATE Customer SET LastName = 'Dharangaonkar', FirstName = 'Additya', Email = 'adh@gmail.com', 
Phone = '9422180649', TotalPurchase = 20 WHERE CustomerID = 1;



--Testing Delete 
DELETE FROM CUSTOMER WHERE CustomerID = 4;



select * from [dbo].[Customer];
select * from [dbo].[CustomerReport];
select * from [dbo].[AuditCustomer];


-------------------------------------------------------------------