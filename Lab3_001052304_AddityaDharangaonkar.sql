-- Lab 3

-- Question 1 (2 points)

/*
  Write a SQL query using "FOR JSON PATH" and AdventureWorks to 
  get a year's total sales. Return the data in the format described below.
  Use TotalDue in SalesOrderHeader for calculating the total sales.
*/


/*
[{"Year":2011,"TotalSales":14155700},
 {"Year":2012,"TotalSales":37675700},
 {"Year":2013,"TotalSales":48965888},
 {"Year":2014,"TotalSales":22419498}]
*/




/*
  Import the generated data into a Cosmos DB SQL API database.
*/

SELECT SUM(s.TotalSales) AS TotalSales, AVG(s.TotalSales) AS AvgSales FROM TotalSales s



/*
  Write a SQL query for the Cosmos DB SQL API to get
  the grand total sales for all years and the average annual sales.
*/



SELECT YEAR(OrderDate) AS [Year], CAST(SUM(TotalDue) AS INT) AS TotalSales FROM Sales.SalesOrderHeader 
GROUP BY YEAR(OrderDate) ORDER BY YEAR(OrderDate) FOR JSON PATH;



-- Question 2 (3 points)

/*
  Write a SQL query using "FOR JSON PATH" and AdventureWorks to 
  get the customers and their orders. Return the data
  in the format described below. Return data only for the customer id's
  in the range between 30000 and 30011. OrderValue is the TotalDue column
  in SalesOrderHeader.
*/


/*
{"CustomerID":30000,
 "Orders":[{"SalesOrderID":46645,"OrderValue":114198},
           {"SalesOrderID":51124,"OrderValue":87230},
		   {"SalesOrderID":55275,"OrderValue":72873},
		   {"SalesOrderID":67295,"OrderValue":70791},
		   {"SalesOrderID":47696,"OrderValue":68210},
		   {"SalesOrderID":49848,"OrderValue":66757},
		   {"SalesOrderID":61196,"OrderValue":31615},
		   {"SalesOrderID":48744,"OrderValue":21404}]},
{"CustomerID":30001,
 "Orders":[{"SalesOrderID":61176,"OrderValue":1631},
           {"SalesOrderID":55237,"OrderValue":82}]},
{"CustomerID":30002,
 "Orders":[{"SalesOrderID":51866,"OrderValue":1100},
           {"SalesOrderID":63274,"OrderValue":403},
		   {"SalesOrderID":69523,"OrderValue":403},
		   {"SalesOrderID":57117,"OrderValue":229}]}
*/



/*
  Import the generated data into a Cosmos DB SQL API database.
*/
/*
  Write a SQL query for the Cosmos DB SQL API to get
  the number of orders each customer has, a customer's total purchase,
  and a customer's average order value.
*/


SELECT s.CustomerID, COUNT(o.SalesOrderID) AS OrderCount, SUM(o.OrderValue) AS TotalOrderValue, 
AVG(o.OrderValue) AS AvgOrderValue FROM CustomerSales s JOIN o IN s.Orders GROUP BY s.CustomerID


SELECT CustomerID, (SELECT SalesOrderID, CAST(TotalDue AS INT) AS OrderValue 
FROM Sales.SalesOrderHeader s WHERE s.CustomerID = sh.CustomerID FOR JSON PATH) AS Orders 
FROM Sales.SalesOrderHeader sh WHERE CustomerID BETWEEN 30000 AND 30011 GROUP By CustomerID
ORDER BY CustomerID FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;




-------------------------------------------------------


-- Question 3 (3 points)

/*
  Write a SQL query using "FOR JSON PATH" and AdventureWorks to 
  get the salespersons in a sales territory and a salesperson's
  sales performance numbers. Return the data in the format described
  below. TotalOrderCount is the total sales order count of a salesperson.
  TotalOrderQuantity is the total product quantity for all sales orders
  of a salesperson. The product quantity of an order is stored in 
  SalesOrderDetail.
*/


/*
{"TerritoryID":1,
 "SalesPeople":[{"SalesPersonID":274,"TotalOrderCount":115,"TotalOrderQuantity":544},
                {"SalesPersonID":276,"TotalOrderCount":1078,"TotalOrderQuantity":4535},
				{"SalesPersonID":280,"TotalOrderCount":2064,"TotalOrderQuantity":7360},
				{"SalesPersonID":281,"TotalOrderCount":475,"TotalOrderQuantity":1522},
				{"SalesPersonID":283,"TotalOrderCount":2247,"TotalOrderQuantity":8172},
				{"SalesPersonID":284,"TotalOrderCount":1893,"TotalOrderQuantity":5650}]},
{"TerritoryID":2,
 "SalesPeople":[{"SalesPersonID":274,"TotalOrderCount":88,"TotalOrderQuantity":328},
                {"SalesPersonID":275,"TotalOrderCount":2249,"TotalOrderQuantity":7000},
				{"SalesPersonID":277,"TotalOrderCount":3472,"TotalOrderQuantity":12488}]}
*/
/*
  Import the generated data into a Cosmos DB SQL API database.
*/
/*
  Write a SQL query for the Cosmos DB SQL API to get
  the totals of TotalOrderCount and TotalOrderQuantity regardless of
  the sales territory for each salesperson.
*/


SELECT o.SalesPersonID, SUM(o.TotalOrderCount) AS TotalOrderCount, SUM(o.TotalOrderQuantity) 
AS TotalOrderQuantity FROM SalesPerson s JOIN o IN s.SalesPeople GROUP BY o.SalesPersonID

--------1---------------
SELECT TerritoryID, (SELECT SalesPersonID, COUNT(sh.SalesOrderID) AS TotalOrderCount, 
SUM(OrderQty) AS TotalOrderQuantity FROM Sales.SalesOrderHeader sh 
LEFT JOIN Sales.SalesOrderDetail sd ON sd.SalesOrderID = sh.SalesOrderID 
WHERE SalesPersonID IS NOT NULL AND sh.TerritoryID = s.TerritoryID GROUP BY SalesPersonID
FOR JSON PATH) AS SalesPeople FROM Sales.SalesOrderHeader s GROUP BY TerritoryID ORDER BY TerritoryID
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

-------2---------------
SELECT TerritoryID, (SELECT SalesPersonID, COUNT(DISTINCT sh.SalesOrderID) AS TotalOrderCount, 
SUM(OrderQty) AS TotalOrderQuantity FROM Sales.SalesOrderHeader sh 
LEFT JOIN Sales.SalesOrderDetail sd ON sd.SalesOrderID = sh.SalesOrderID 
WHERE SalesPersonID IS NOT NULL AND sh.TerritoryID = s.TerritoryID GROUP BY SalesPersonID
FOR JSON PATH) AS SalesPeople FROM Sales.SalesOrderHeader s GROUP BY TerritoryID ORDER BY TerritoryID
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;