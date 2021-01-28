/* Lab 1 - Review of the Data Hierarchy, Data Aggregation and Horizontal Reporting */

-- Question 1 (3 points)

/* Use an AdventureWorks database */
/* The following code creates a shortlist report, as listed below. */


/*
Year	Top3Orders
2011	44518 Southeast 2011-10-01 142312.22, 43875 Southeast 2011-07-01 137343.29
2012	46616 Canada 2012-05-30 170512.67, 46981 France 2012-06-30 166537.08
2013	51131 Southwest 2013-05-30 187487.83, 55282 Southwest 2013-08-30 182018.63
2014	67305 Southwest 2014-03-01 130907.05, 69531 France 2014-03-31 126514.99
*/


-- Solution 1

with temp as
(select year(OrderDate) Year, Name, SalesOrderID, OrderDate, TotalDue,
	    rank() over (partition by year(OrderDate) order by TotalDue desc) Position
 from Sales.SalesOrderHeader sh
 join Sales.SalesTerritory st
 on sh.TerritoryID = st.TerritoryID)

SELECT	temp.Year,
		STRING_AGG(	cast(temp.SalesOrderID as varchar) 
					+ ' '
					+ Name
					+ ' '
					+ cast(cast(temp.OrderDate AS date) as varchar)
					+ ' '
					+ cast(cast(TotalDue as decimal(9, 2)) as varchar)
					, ',  ')	as Top2Orders
FROM temp 
WHERE Position IN (1, 2)
GROUP BY Year
ORDER BY Year;


-- Solution 2

with temp as
(select year(OrderDate) Year, Name, SalesOrderID, OrderDate, TotalDue,
	    rank() over (partition by year(OrderDate) order by TotalDue desc) Position
 from Sales.SalesOrderHeader sh
 join Sales.SalesTerritory st
 on sh.TerritoryID = st.TerritoryID)

select DISTINCT Year,
STUFF((SELECT  ', ' + cast(SalesOrderID as varchar(10))+ ' '+ Name, ' ' +
               cast(cast(OrderDate as date) as char(10))+ ' '+
			   cast(cast(TotalDue as decimal(9, 2)) as varchar)
       FROM temp t1
       WHERE t1.year = t.year and Position <=2
       FOR XML PATH('')) , 1, 2, '') AS Top3Orders
from temp t
order by Year;


with temp as
(select year(OrderDate) Year, Name, SalesOrderID, OrderDate, TotalDue,    
rank() over (partition by year(OrderDate) order by TotalDue desc) 
Position 
from Sales.SalesOrderHeader sh join Sales.SalesTerritory st on sh.TerritoryID = st.TerritoryID)
SELECT      temp.Year,
STRING_AGG( cast(temp.SalesOrderID as varchar)
+ ' '
+ Name
+ ' '
+ cast(cast(temp.OrderDate AS date) as varchar)
+ ' '
+ cast(cast(TotalDue as decimal(9, 2)) as varchar), ',  ')    as Top2Orders
FROM temp
WHERE Position IN (1,2)
GROUP BY Year
ORDER BY Year;


with temp as
(select year(OrderDate) Year, Name, SalesOrderID, OrderDate, TotalDue, 
	rank() over (partition by year(OrderDate) order by TotalDue desc) 
Position 
	from Sales.SalesOrderHeader sh 
	join Sales.SalesTerritory st 
	on sh.TerritoryID = st.TerritoryID)
select Year,
STUFF((SELECT  ', ' + cast(SalesOrderID as varchar(10))+ ' '+ Name, ' ' + 
cast(cast(OrderDate as date) as char(10))+ ' '+ 
cast(cast(TotalDue as decimal(9, 2)) as varchar)
       FROM temp t1      
	   WHERE t1.year = t.year and Position <=2     
	   FOR XML PATH('')) , 1, 2, '') AS Top3Orders
	   from temp t
	   order by Year;





--As we are using ranking over the whole data and it is partitioned by years it needs to be grouped by the years so that we can pick top two of the occurances in one row
--If we dont use distinct there would be multiple occrances of each year with the same row so there would be repeating occurances. 
--To get only tyhe distinct occurances and avoid redundant data we use Distinct


with temp as
(select year(OrderDate) Year, Name, SalesOrderID, OrderDate, TotalDue,
	    rank() over (partition by year(OrderDate) order by TotalDue desc) Position
 from Sales.SalesOrderHeader sh
 join Sales.SalesTerritory st
 on sh.TerritoryID = st.TerritoryID)

select Year,
STUFF((SELECT  ', ' + cast(SalesOrderID as varchar(10))+ ' '+ Name, ' ' +
               cast(cast(OrderDate as date) as char(10))+ ' '+
			   cast(cast(TotalDue as decimal(9, 2)) as varchar)
       FROM temp t1
       WHERE t1.year = t.year and Position <=2
       FOR XML PATH('')) , 1, 2, '') AS Top3Orders
from temp t
group by Year
order by Year
;



select st.TerritoryID, st.Name as TerritoryName, count(soh.SalesOrderID) as TotalOrderCount, 
max(TotalDue) as MaxSingleOrderValue, max(OrderQty) as MaxSingleOrderQuantity
from Sales.SalesOrderHeader soh 
join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID 
join Sales.SalesTerritory st on soh.TerritoryID = st.TerritoryID
group by st.TerritoryID, st.Name
order by st.TerritoryID;

