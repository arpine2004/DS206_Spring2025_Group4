DECLARE @SOR_SK INT;
SELECT @SOR_SK = SOR_SK
FROM dbo.Dim_SOR
WHERE StagingTableName = 'Staging_Raw_OrderDetails';

-- Declare parameters for ingestion window
DECLARE @start_date DATE = CAST('{start_date}' AS DATE);
DECLARE @end_date DATE = CAST('{end_date}' AS DATE);

INSERT INTO dbo.FactOrders (
    OrderID_nk,
    Customer_sk_fk,
    Employee_sk_fk,
    ShipVia,
    Territory_sk_fk,
    OrderDate,
    RequiredDate,
    ShippedDate,
    Freight,
    ShipName,
    ShipAddress,
    ShipCity,
    ShipRegion,
    ShipPostalCode,
    ShipCountry,
    sor_sk
)
SELECT
    o.OrderID,
    c.CustomersID_sk_pk,
    e.EmployeeID_sk_pk,
    shp.ShippersID_sk_pk,
    ter.TerritoriesID_sk_pk,
    o.OrderDate,
    o.RequiredDate,
    o.ShippedDate,
    o.Freight,
    o.ShipName,
    o.ShipAddress,
    o.ShipCity,
    o.ShipRegion,
    o.ShipPostalCode,
    o.ShipCountry,
    @SOR_SK
FROM dbo.Staging_Raw_Orders o
LEFT JOIN dbo.DimCustomers c ON o.CustomerID = c.CustomerID_nk AND c.IsCurrent = 1
LEFT JOIN dbo.DimEmployees e ON o.EmployeeID = e.EmployeeID_nk
LEFT JOIN dbo.DimShippers shp ON o.ShipVia = shp.ShipperID_nk
LEFT JOIN dbo.DimTerritories ter ON o.TerritoryID = ter.TerritoryID_nk
WHERE o.OrderDate BETWEEN @start_date AND @end_date
  AND o.OrderID IS NOT NULL;
