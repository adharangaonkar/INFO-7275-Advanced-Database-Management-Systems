
-- Quiz 1

-- Last NUID Digit 4, 6, 7, 8, or 9
-- Please remember to include your NUID and name in all submitted files.

-- Your NUID:
-- Your Name:

/* Cassandra - 7 points */

/*
Patient appointments are stored in an appointment table by the appointment year
with the columns listed below.

PatientID
PatientLastName
PatientFirstName
AppointmentDate
AppointmentYear
DrLastNAme
DrFirstName
Clinic

The anticipated queries are:
Display a patient's appointments by doctor, then the most recent appointment date first.
Display a patient's appointments with the most recent appointment date displayed first.

Please:
1) Design and create table(s) according to the anticipated data usage pattern.
   Submit the table-creation CQL code. (4 points)

2) Write the two anticipated CQL queries based on your table design.
   Note: Assume we are writing the queries to get data for PatientID = 88888
   Submit the CQL queries and a screenshot of the execution results. (3 points)
*/








/* Cosmos DB SQL API - 8 points */

-- Part 1 (5 points)

/*
  Write a SQL query using "FOR JSON PATH" and AdventureWorks2017 to 
  get the sales data about sold products in red and black
  for each sales territory.

  Use UnitPrice*OrderQty for calculating the total sales amount.
  Both UnitPrice and OrderQty are in SaleOrderDetail table.
  
  Return the data in the format described below. 
  Please use the format just for formatting purposes. It
  doesn't include all required data. 
*/

/*
{"TerritoryID":1,
 "colors":[{"Color":"Black",
            "sales":[{"year":2011,"OrderCount":78,"TotalSale":895192},
			         {"year":2012,"OrderCount":252,"TotalSale":2153863},
					 {"year":2013,"OrderCount":761,"TotalSale":2089220},
					 {"year":2014,"OrderCount":599,"TotalSale":780498}]},
		   {"Color":"Red",
		    "sales":[{"year":2011,"OrderCount":159,"TotalSale":695445},
			         {"year":2012,"OrderCount":250,"TotalSale":1262185},
					 {"year":2013,"OrderCount":219,"TotalSale":302856},
					 {"year":2014,"OrderCount":176,"TotalSale":35388}]}]},
{"TerritoryID":2,
 "colors":[{"Color":"Black",
            "sales":[{"year":2011,"OrderCount":37,"TotalSale":112000},
			         {"year":2012,"OrderCount":109,"TotalSale":1252253},
					 {"year":2013,"OrderCount":102,"TotalSale":955593},
					 {"year":2014,"OrderCount":30,"TotalSale":185557}]},
		   {"Color":"Red",
		    "sales":[{"year":2011,"OrderCount":37,"TotalSale":488367},
			         {"year":2012,"OrderCount":84,"TotalSale":1014459},
					 {"year":2013,"OrderCount":55,"TotalSale":355436},
					 {"year":2014,"OrderCount":12,"TotalSale":22849}]}]}
*/




-- Part 2 (1 point)

/*
  Import the generated data into the Cosmos DB SQL API database.
  Submit a screenshot of importing results.
*/




-- Part 3 (2 points)

/*
  Write a SQL query for the Cosmos DB SQL API to get
  the total order count of sold products in black for 2013.
  Return the color, year, and the total order count columns.
  Submit the code and a screenshot of execution results.
*/



