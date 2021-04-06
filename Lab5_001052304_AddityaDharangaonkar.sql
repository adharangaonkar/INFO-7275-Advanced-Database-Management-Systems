/*Lab 5 Submission */

/* Part 1 - Use dynamic SQL for data management */ 

CREATE PROCEDURE archiveTable 
AS

   DECLARE @Struct_String NVARCHAR(MAX)
   DECLARE @Year NVARCHAR(MAX)
   SET @Year = DATENAME(year, getdate())
   DECLARE @Month NVARCHAR(MAX)
   SET @Month = DATENAME(month, getdate())
   DECLARE @Day NVARCHAR(MAX)
   SET @Day = DATENAME(day, getdate())
   DECLARE @TableName NVARCHAR(MAX) = 'OrderArchive' + @Month + @Year 

   SET @Struct_String = 'CREATE TABLE ' + @TableName + '( OrderID int primary key, 
   CustomerID int not null references Customer(CustomerID), 
   OrderDate date default getdate(), 
   Amount money )'
   EXEC (@Struct_String)

   EXEC ('INSERT INTO ' + @TableName + ' SELECT * FROM SaleOrder WHERE OrderDate < getdate() - 365')
   EXEC ('DELETE FROM SaleOrder WHERE OrderDate < getdate() - 365')
   GO


-- Part 2 

-- 1. Implement the "Employee Data" and"Work Relationship Graph" in a SQL database

CREATE TABLE [dbo].[Employee](
[EmployeeID] [int] NOT NULL,
[LastName] [nvarchar](20) NOT NULL,
[FirstName] [nvarchar](10) NOT NULL,
[Department] [varchar](20) NULL)
AS NODE;

INSERT [dbo].[Employee] ([EmployeeID], [LastName], [FirstName], [Department]) VALUES (2, N'Fuller', N'Andrew', NULL)
INSERT [dbo].[Employee] ([EmployeeID], [LastName], [FirstName], [Department]) VALUES (3, N'Leverling', N'Janet', N'IT')
INSERT [dbo].[Employee] ([EmployeeID], [LastName], [FirstName], [Department]) VALUES (5, N'Buchanan', N'Steven', N'Finance')
INSERT [dbo].[Employee] ([EmployeeID], [LastName], [FirstName], [Department]) VALUES (7, N'King', N'Robert', N'Finance')
INSERT [dbo].[Employee] ([EmployeeID], [LastName], [FirstName], [Department]) VALUES (12, N'Chang', N'Leslie', N'Finance')
INSERT [dbo].[Employee] ([EmployeeID], [LastName], [FirstName], [Department]) VALUES (14, N'Ng', N'Jordan', N'Finance')
INSERT [dbo].[Employee] ([EmployeeID], [LastName], [FirstName], [Department]) VALUES (15, N'Black', N'Lela', N'IT')
INSERT [dbo].[Employee] ([EmployeeID], [LastName], [FirstName], [Department]) VALUES (21, N'Thompson', N'Connie', N'IT')

Select * from dbo.Employee;


CREATE TABLE dbo.WorkFor AS EDGE;


INSERT INTO dbo.WorkFor 
VALUES
((SELECT $node_id FROM [dbo].[Employee] WHERE [EmployeeID] = 3),
(SELECT $node_id FROM [dbo].[Employee] WHERE [EmployeeID] = 2)),
((SELECT $node_id FROM [dbo].[Employee] WHERE [EmployeeID] = 7),
(SELECT $node_id FROM [dbo].[Employee] WHERE [EmployeeID] = 2)),
((SELECT $node_id FROM [dbo].[Employee] WHERE [EmployeeID] = 5),
(SELECT $node_id FROM [dbo].[Employee] WHERE [EmployeeID] = 2)),
((SELECT $node_id FROM [dbo].[Employee] WHERE [EmployeeID] = 15),
(SELECT $node_id FROM [dbo].[Employee] WHERE [EmployeeID] = 2)),
((SELECT $node_id FROM [dbo].[Employee] WHERE [EmployeeID] = 12),
(SELECT $node_id FROM [dbo].[Employee] WHERE [EmployeeID] = 7)),
((SELECT $node_id FROM [dbo].[Employee] WHERE [EmployeeID] = 14),
(SELECT $node_id FROM [dbo].[Employee] WHERE [EmployeeID] = 7)),
((SELECT $node_id FROM [dbo].[Employee] WHERE [EmployeeID] = 15),
(SELECT $node_id FROM [dbo].[Employee] WHERE [EmployeeID] = 7)),
((SELECT $node_id FROM [dbo].[Employee] WHERE [EmployeeID] = 21),
(SELECT $node_id FROM [dbo].[Employee] WHERE [EmployeeID] = 15));

select * from dbo.WorkFor 

-- 2. Write SQL codeto retrieve all employees who have EmpID2 as a skip 

SELECT Employee1.EmployeeID AS Members, Employee1.FirstName, Employee1.LastName, Employee1.Department 
FROM Employee Employee1, WorkFor Work1, Employee Employee2, WorkFor Work2, Employee Employee3
WHERE MATCH(Employee1-(Work1)->Employee2) 
AND 
MATCH(Employee2-(Work2)->Employee3) 
AND 
Employee3.EmployeeID = 2;