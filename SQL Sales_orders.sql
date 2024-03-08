use Sales_order
select * from Orders
select * from People

select *,datediff(YY,convert(Date,'FormattedDate'),getdate()) as 'Exp' from Orders
/* 1.Find the top 5 customers with the highest lifetime value (LTV),
 where LTV is calculated as the sum of their profits divided by the number of years they have been customer */



SELECT TOP 5
    CustomerID , customername, 
	case when datediff(Year,min(OrderDate), max(orderdate)) = 0 then null 
else 
    SUM(Profit) / DATEDIFF(YEAR, min(OrderDate), max(orderdate)) END AS LTV 
FROM
    orders
GROUP BY
   CustomerID ,Customername 
ORDER BY
    LTV DESC; 




/* 2.Create a pivot table to show total sales by product category and sub-category.:*/

SELECT *
FROM (
    SELECT
        category,
        subcategory,
        sales
    FROM
        orders
) AS SourceTable
PIVOT
(
    SUM(sales)
    FOR subcategory IN (
        Furnishings, Chairs, Bookcases, Tables, Art, Paper, Appliances,
        Fasteners, Envelopes, Supplies, Labels, Binders, Storage,
        Machines, Copiers, Accessories, Phones
    )
) AS PivotTable;


/* 3-Find the customer who has made the maximum number of orders in each category */
WITH RankedOrders AS (
    SELECT CustomerName,
        CustomerID,
        Category,
        ROW_NUMBER() OVER (PARTITION BY Category ORDER BY COUNT(OrderID) DESC) AS OrderRank
    FROM
       orders
    GROUP BY
        CustomerID, Category, CustomerName
)
SELECT
    CustomerID,
    Category,CustomerName
FROM
    RankedOrders
WHERE
    OrderRank = 1;

 
/*4.Find the top 3 products in each category based on their sales */

WITH RankedProducts AS (
    SELECT
        Category,
        ProductName,
        ROW_NUMBER() OVER (PARTITION BY Category ORDER BY SUM(sales) DESC) AS ProductRank
    FROM
        orders
    GROUP BY
        Category, ProductName
)
SELECT
   Category,
    ProductName
FROM
    RankedProducts
WHERE
    ProductRank <= 3;



/* 5.	In the table Orders with columns OrderID, CustomerID, OrderDate, TotalAmount. 
You need to create a stored procedure Get_Customer_Orders that takes a CustomerID as input and returns a table with the following columns,
 you will need to create a function also that calculates the number of days between two dates.  
OrderDate
TotalAmount
TotalOrders: The total number of orders made by the customer.
AvgAmount: The average total amount of orders made by the customer.
LastOrderDate: The date of the customer's most recent order.
DaysSinceLastOrder: The number of days since the customer's most recent order. */


drop procedure Get_Customer_Orders

CREATE PROCEDURE Get_Customer_Orders
    @CustomerID as varchar(20)
AS
BEGIN
    SELECT
        OrderDate,
        SUM(sales) OVER (PARTITION BY @customerid) AS TotalAmount,
        COUNT(OrderID) OVER (PARTITION BY @customerid) AS TotalOrders,
        AVG(sales ) OVER (PARTITION BY @customerID) AS AvgAmount,
        MAX(OrderDate) OVER (PARTITION BY @customerID) AS LastOrderDate
        dbo.CalculateDaysBetweenDates(MAX(OrderDate) OVER (PARTITION BY @customerID), GETDATE()) AS DaysSinceLastOrder
    FROM
        Orders
    WHERE
        CustomerID = @CustomerID		;
END;

EXECUTE Get_Customer_Orders 'CG-12520';






