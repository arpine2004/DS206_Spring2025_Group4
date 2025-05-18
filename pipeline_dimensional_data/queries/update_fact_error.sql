DECLARE @SOR_SK INT;
SELECT @SOR_SK = SOR_SK
FROM dbo.Dim_SOR
WHERE StagingTableName = 'Staging_Raw_OrderDetails';

-- Declare parameters for ingestion window
DECLARE @start_date DATE = CAST('{start_date}' AS DATE);
DECLARE @end_date DATE = CAST('{end_date}' AS DATE);

INSERT INTO dbo.FactError (
    staging_raw_id,
    sor_sk,
    OrderID_nk,
    ProductID_nk,
    UnitPrice,
    Quantity,
    Discount,
    CustomerID_nk,
    EmployeeID_nk,
    OrderDate,
    RequiredDate,
    ShippedDate,
    ShipVia_nk,
    Freight,
    ShipName,
    ShipAddress,
    ShipCity,
    ShipRegion,
    ShipPostalCode,
    ShipCountry,
    TerritoryID_nk
)
SELECT
    od.staging_raw_orderdetail_id_sk,               -- staging_raw_id from OrderDetails
    @SOR_SK,                                        -- surrogate key for staging raw source
    o.OrderID,                                      -- natural keys from staging orders
    od.ProductID,
    od.UnitPrice,
    od.Quantity,
    od.Discount,
    o.CustomerID,
    o.EmployeeID,
    o.OrderDate,
    o.RequiredDate,
    o.ShippedDate,
    o.ShipVia,
    o.Freight,
    o.ShipName,
    o.ShipAddress,
    o.ShipCity,
    o.ShipRegion,
    o.ShipPostalCode,
    o.ShipCountry,
    o.TerritoryID
FROM dbo.Staging_Raw_Orders o
LEFT JOIN dbo.Staging_Raw_OrderDetails od ON o.OrderID = od.OrderID
LEFT JOIN dbo.DimCustomers dc ON o.CustomerID = dc.CustomerID_nk AND dc.IsCurrent = 1
LEFT JOIN dbo.DimProducts dp ON od.ProductID = dp.ProductID_nk
LEFT JOIN dbo.DimTerritories dt ON o.TerritoryID = dt.TerritoryID_nk
LEFT JOIN dbo.DimEmployees de ON o.EmployeeID = de.EmployeeID_nk
LEFT JOIN dbo.DimShippers ds ON o.ShipVia = ds.ShipperID_nk
WHERE (
      dc.CustomerID_nk IS NULL
   OR dp.ProductID_nk IS NULL
   OR dt.TerritoryID_nk IS NULL
   OR de.EmployeeID_nk IS NULL
   OR ds.ShipperID_nk IS NULL
)
AND o.OrderDate BETWEEN @start_date AND @end_date;
