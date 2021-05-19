IF OBJECT_ID('dbo.GetNums', 'IF') IS NOT NULL DROP FUNCTION dbo.GetNums;
GO
CREATE FUNCTION dbo.GetNums(@low AS BIGINT, @high AS BIGINT) RETURNS TABLE
AS
RETURN
WITH
L0 AS (SELECT c FROM (VALUES(1),(1)) AS D(c)),
L1 AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
L2 AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
L3 AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
L4 AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
L5 AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
FROM L5)
SELECT @low + rownum - 1 AS n
FROM Nums
ORDER BY rownum
OFFSET 0 ROWS FETCH FIRST @high - @low + 1 ROWS ONLY;
GO

-- dbo.Employees
insert into dbo.Employees (
	LastName
	,FirstName
	,Title
	,TitleOfCourtesy
	,BirthDate
	,HireDate
	,Address
	,City
	,Region
	,PostalCode
	,Country
	,HomePhone
	,Extension
	,Photo
	,Notes
	,ReportsTo
	,PhotoPath
)
select
	CONCAT(N'LastName_', n)
	,CONCAT(N'FN_', n)
	,CONCAT(N'Title_', n)
	,CONCAT(N'TitleOfCourtesy', n)
	,DATEADD(y, -1 * (18 + (n % 50)), GETDATE())
	,DATEADD(y, -1 * (n % 50), GETDATE())
	,CONCAT(N'Address_', n)
	,CONCAT(N'City_', n)
	,CONCAT(N'Region_', n)
	,CONCAT(N'PCode_', n)
	,CONCAT(N'Country_', n)
	,CONCAT(N'HomePhone_', n)
	,CAST(n as NVARCHAR(4))
	,CAST(NEWID() AS varbinary(16))
	,CAST(CAST(NEWID() AS nchar(36)) AS NVARCHAR(16))
	,CAST(NULL AS INT)
	,CONCAT(N'PhotoPath_', n)
from dbo.GetNums(0, 1000);
GO

-- dbo.Customers
insert into dbo.Customers (
	CustomerID
	,CompanyName
	,ContactName
	,ContactTitle
	,Address
	,City
	,Region
	,PostalCode
	,Country
	,Phone
	,Fax
)
select
	CAST(n as NVARCHAR(5))
	,CONCAT(N'CompanyName_', n)
	,CONCAT(N'ContactName_', n)
	,CONCAT(N'ContactTitle_', n)
	,CONCAT(N'Address_', n)
	,CONCAT(N'City_', n)
	,CONCAT(N'Rgn_', n)
	,CONCAT(N'PC_', n)
	,CONCAT(N'Cntr_', n)
	,CONCAT(N'HomePhone_', n)
	,CONCAT(N'Fax_', n)
from dbo.GetNums(0, 99999);
GO

-- dbo.Products
insert into dbo.Products (
	ProductName
	,SupplierID
	,CategoryID
	,QuantityPerUnit
	,UnitPrice
	,UnitsInStock
	,UnitsOnOrder
	,ReorderLevel
	,Discontinued
)
select
	CONCAT(N'ProductName_', n)
	,(SELECT TOP(1) SupplierID FROM dbo.Suppliers ORDER BY NEWID())
	,(SELECT TOP(1) CategoryID FROM dbo.Categories ORDER BY NEWID())
	,CAST(n AS NVARCHAR(20))
	,CAST(n as DECIMAL(19,4))
	,n
	,n
	,n
	,CAST(n % 2 AS BIT)
from dbo.GetNums(0, 1000);

-- dbo.Orders
insert into dbo.Orders (
	CustomerID
	,EmployeeID
	,OrderDate
	,RequiredDate
	,ShippedDate
	,ShipVia
	,Freight
	,ShipName
	,ShipAddress
	,ShipCity
	,ShipRegion
	,ShipPostalCode
	,ShipCountry
)
select
	(SELECT TOP(1) CustomerID FROM dbo.Customers ORDER BY NEWID())
	,(SELECT TOP(1) EmployeeID FROM dbo.Employees ORDER BY NEWID())
	,DATEFROMPARTS(
		1996 + (n % 3)
		,1 + (n % 12)
		,1 + (n % 28)
	)
	,DATEADD(
		m
		,1
		,DATEFROMPARTS(
			1996 + (n % 3)
			,1 + (n % 12)
			,1 + (n % 28)
		)
	)
	,DATEADD(
		d
		,5 + (n % 20)
		,DATEFROMPARTS(
			1996 + (n % 3)
			,1 + (n % 12)
			,1 + (n % 28)
		)
	)
	,1 + (n % 3)
	,RAND() * 1000000000
	,CONCAT(N'ShipName_', n)
	,CONCAT(N'ShipAddress_', n)
	,CONCAT(N'SCity_', n)
	,CONCAT(N'SR_', n)
	,CONCAT(N'PC_', n)
	,CONCAT(N'Scntr_',n)
from dbo.GetNums(0, 1000000);

-- dbo.[Order Details]
;with ids as (
	select
		ROW_NUMBER() OVER(ORDER BY OrderID) as rn
		,o.OrderID
		,pid.ProductID
	from dbo.Orders o
	cross apply (
		select top(3) ProductID
		from dbo.Products
		order by NEWID()
	) pid
)
insert into dbo.[Order Details] (
	OrderID
	,ProductID
	,UnitPrice
	,Quantity
	,Discount
)
select
	i.OrderID
	,i.ProductID
	,CAST(RAND() * 1000000000 AS DECIMAL(19, 4))
	,1 + (n % 32000)
	,(n % 100) * 0.01
from dbo.GetNums(1, 3000000) nums
inner join ids i on i.rn = nums.n;