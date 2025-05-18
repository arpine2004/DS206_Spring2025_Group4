USE ORDER_DDS;

-- Drop tables if they exist (to be safe)
DROP TABLE IF EXISTS dbo.OrderDetails;
DROP TABLE IF EXISTS dbo.FactOrders;
DROP TABLE IF EXISTS dbo.DimProducts;
DROP TABLE IF EXISTS dbo.DimSuppliers;
DROP TABLE IF EXISTS dbo.DimCategories;
DROP TABLE IF EXISTS dbo.DimCustomers;
DROP TABLE IF EXISTS dbo.DimEmployees;
DROP TABLE IF EXISTS dbo.DimTerritories;
DROP TABLE IF EXISTS dbo.DimShippers;
DROP TABLE IF EXISTS dbo.DimRegion;
DROP TABLE IF EXISTS dbo.DimRegion_History;
DROP TABLE IF EXISTS dbo.DimTerritories_History;
DROP TABLE IF EXISTS dbo.Dim_SOR;
DROP TABLE IF EXISTS dbo.FactError;

-- ====================================================
-- DimCategories (SCD1: overwrite on update, no history)
CREATE TABLE dbo.DimCategories (
    CategoriesID_sk_pk INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID_nk INT NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(MAX),
    sor_sk INT NULL,
    staging_raw_category_id INT NULL
);

-- ====================================================
-- DimCustomers (SCD2: keep history with ValidFrom, ValidTo, IsCurrent)
CREATE TABLE dbo.DimCustomers (
    CustomersID_sk_pk INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID_nk NVARCHAR(10) NOT NULL,
    CompanyName NVARCHAR(100) NOT NULL,
    ContactName NVARCHAR(100),
    ContactTitle NVARCHAR(50),
    [Address] NVARCHAR(200),
    City NVARCHAR(50),
    Region NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(50),
    Phone NVARCHAR(30),
    Fax NVARCHAR(30),
    ValidFrom DATETIME NOT NULL DEFAULT GETDATE(),
    ValidTo DATETIME NULL,
    IsCurrent BIT NOT NULL DEFAULT 1,
    sor_sk INT NULL,
    staging_raw_customer_id INT NULL
);

-- ====================================================
-- DimEmployees (SCD1 with delete)
CREATE TABLE dbo.DimEmployees (
    EmployeeID_sk_pk INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID_nk INT NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    Title NVARCHAR(50),
    TitleOfCourtesy NVARCHAR(50),
    BirthDate DATETIME,
    HireDate DATETIME,
    [Address] NVARCHAR(200),
    City NVARCHAR(50),
    Region NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(50),
    HomePhone NVARCHAR(30),
    Extension NVARCHAR(10),
    Notes NVARCHAR(MAX),
    ReportsTo INT NULL,
    PhotoPath NVARCHAR(200),
    sor_sk INT NULL,
    staging_raw_employee_id INT NULL
);

-- ====================================================
-- DimProducts (SCD1)
CREATE TABLE dbo.DimProducts (
    ProductID_sk_pk INT IDENTITY(1,1) PRIMARY KEY,
    ProductID_nk INT NOT NULL,
    ProductName NVARCHAR(100) NOT NULL,
    Supplier_sk_fk INT,
    Category_sk_fk INT NOT NULL,
    QuantityPerUnit NVARCHAR(50),
    UnitPrice DECIMAL(18,2),
    UnitsInStock SMALLINT,
    UnitsOnOrder SMALLINT,
    ReorderLevel SMALLINT,
    Discontinued BIT,
    sor_sk INT NULL,
    staging_raw_product_id INT NULL
);

-- ====================================================
-- DimRegion (SCD4: separate history table)
CREATE TABLE dbo.DimRegion (
    RegionID_sk_pk INT IDENTITY(1,1) PRIMARY KEY,
    RegionID_nk INT NOT NULL,
    RegionDescription NVARCHAR(100) NOT NULL,
    RegionCategory NVARCHAR(50),
    RegionImportance NVARCHAR(50),
    sor_sk INT NULL,
    staging_raw_region_id INT NULL
);

CREATE TABLE dbo.DimRegion_History (
    RegionID_sk_pk INT PRIMARY KEY,
    RegionID_nk INT NOT NULL,
    RegionDescription NVARCHAR(100) NOT NULL,
    RegionCategory NVARCHAR(50),
    RegionImportance NVARCHAR(50),
    ArchivedDate DATETIME NOT NULL DEFAULT GETDATE()
);

-- ====================================================
-- DimShippers (SCD1 with delete)
CREATE TABLE dbo.DimShippers (
    ShippersID_sk_pk INT IDENTITY(1,1) PRIMARY KEY,
    ShipperID_nk INT NOT NULL,
    CompanyName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(30),
    sor_sk INT NULL,
    staging_raw_shipper_id INT NULL
);

-- ====================================================
-- DimSuppliers (SCD3: current and prior for one attribute)
CREATE TABLE dbo.DimSuppliers (
    SuppliersID_sk_pk INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID_nk INT NOT NULL,
    CompanyName NVARCHAR(100) NOT NULL,
    ContactName NVARCHAR(100),
    ContactTitle NVARCHAR(50),
    [Address] NVARCHAR(200),
    City NVARCHAR(50),
    Region NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(50),
    Phone NVARCHAR(30),
    Fax NVARCHAR(30),
    HomePage NVARCHAR(MAX),
    ContactTitle_Current NVARCHAR(50),
    ContactTitle_Prior NVARCHAR(50),
    sor_sk INT NULL,
    staging_raw_supplier_id INT NULL
);

-- ====================================================
-- DimTerritories (SCD4: separate history table)
CREATE TABLE dbo.DimTerritories (
    TerritoriesID_sk_pk INT IDENTITY(1,1) PRIMARY KEY,
    TerritoryID_nk INT NOT NULL,
    TerritoryDescription NVARCHAR(100),
    TerritoryCode NVARCHAR(20),
    Region_sk_fk INT NOT NULL,
    sor_sk INT NULL,
    staging_raw_territory_id INT NULL
);

CREATE TABLE dbo.DimTerritories_History (
    TerritoriesID_sk_pk INT PRIMARY KEY,
    TerritoryID_nk INT NOT NULL,
    TerritoryDescription NVARCHAR(100),
    TerritoryCode NVARCHAR(20),
    Region_sk_fk INT NOT NULL,
    ArchivedDate DATETIME NOT NULL DEFAULT GETDATE()
);



-- ====================================================
-- FactOrders table (INSERT only)
CREATE TABLE dbo.FactOrders (
    FactOrdersID_sk_pk INT IDENTITY(1,1) PRIMARY KEY,
    OrderID_nk INT NOT NULL,
    Customer_sk_fk INT NOT NULL,
    Employee_sk_fk INT NOT NULL,
    OrderDate DATETIME NOT NULL,
    RequiredDate DATETIME NULL,
    ShippedDate DATETIME NULL,
    ShipVia INT NOT NULL,
    Freight DECIMAL(18,2),
    ShipName NVARCHAR(100),
    ShipAddress NVARCHAR(200),
    ShipCity NVARCHAR(50),
    ShipRegion NVARCHAR(50),
    ShipPostalCode NVARCHAR(20),
    ShipCountry NVARCHAR(50),
    Territory_sk_fk INT NOT NULL,
    sor_sk INT NULL  -- surrogate key from Dim_SOR to track source of record
);

-- ====================================================
-- Fact Error table 
CREATE TABLE dbo.FactError (
    FactErrorID_sk_pk INT IDENTITY(1,1) PRIMARY KEY,
    staging_raw_id INT NOT NULL,
    sor_sk INT NULL,  -- surrogate key for staging source
    OrderID_nk INT NULL,
    ProductID_nk INT NULL,
    UnitPrice DECIMAL(18,2) NULL,
    Quantity INT NULL,
    Discount DECIMAL(5,2) NULL,
    CustomerID_nk NVARCHAR(10) NULL,
    EmployeeID_nk INT NULL,
    OrderDate DATE NULL,
    RequiredDate DATE NULL,
    ShippedDate DATE NULL,
    ShipVia_nk INT NULL,
    Freight DECIMAL(18,2) NULL,
    ShipName NVARCHAR(100) NULL,
    ShipAddress NVARCHAR(200) NULL,
    ShipCity NVARCHAR(50) NULL,
    ShipRegion NVARCHAR(50) NULL,
    ShipPostalCode NVARCHAR(20) NULL,
    ShipCountry NVARCHAR(50) NULL,
    TerritoryID_nk INT NULL
);


-- ====================================================
-- OrderDetails table
CREATE TABLE dbo.OrderDetails (
    OrderDetailsID_sk_pk INT IDENTITY(1,1) PRIMARY KEY,
    Order_sk_fk INT NOT NULL,
    Product_sk_fk INT NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,
    Quantity INT NOT NULL,
    Discount DECIMAL(5,2)
);

-- ====================================================
-- Dim_SOR table to track source of record loads
CREATE TABLE dbo.Dim_SOR (
    SOR_SK INT IDENTITY(1,1) PRIMARY KEY,
    StagingTableName NVARCHAR(100) NOT NULL,
    StagingRawID INT NOT NULL,
    LoadDateTime DATETIME DEFAULT GETDATE(),
    UNIQUE (StagingTableName, StagingRawID)
);


-- ====================================================
-- Add Foreign Key constraints (adjust if needed)
-- Examples:
ALTER TABLE dbo.DimEmployees
    ADD CONSTRAINT FK_DimEmployees_ReportsTo
    FOREIGN KEY (ReportsTo) REFERENCES dbo.DimEmployees(EmployeeID_sk_pk)
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE dbo.DimTerritories
    ADD CONSTRAINT FK_DimTerritories_DimRegion
    FOREIGN KEY (Region_sk_fk) REFERENCES dbo.DimRegion(RegionID_sk_pk)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE dbo.DimProducts
    ADD CONSTRAINT FK_DimProducts_DimSuppliers
    FOREIGN KEY (Supplier_sk_fk) REFERENCES dbo.DimSuppliers(SuppliersID_sk_pk)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE dbo.DimProducts
    ADD CONSTRAINT FK_DimProducts_DimCategories
    FOREIGN KEY (Category_sk_fk) REFERENCES dbo.DimCategories(CategoriesID_sk_pk)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE dbo.FactOrders
    ADD CONSTRAINT FK_FactOrders_DimCustomers
    FOREIGN KEY (Customer_sk_fk) REFERENCES dbo.DimCustomers(CustomersID_sk_pk)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE dbo.FactOrders
    ADD CONSTRAINT FK_FactOrders_DimEmployees
    FOREIGN KEY (Employee_sk_fk) REFERENCES dbo.DimEmployees(EmployeeID_sk_pk)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE dbo.FactOrders
    ADD CONSTRAINT FK_FactOrders_DimShippers
    FOREIGN KEY (ShipVia) REFERENCES dbo.DimShippers(ShippersID_sk_pk)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE dbo.FactOrders
    ADD CONSTRAINT FK_FactOrders_DimTerritories
    FOREIGN KEY (Territory_sk_fk) REFERENCES dbo.DimTerritories(TerritoriesID_sk_pk)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE dbo.OrderDetails
    ADD CONSTRAINT FK_OrderDetails_FactOrders
    FOREIGN KEY (Order_sk_fk) REFERENCES dbo.FactOrders(FactOrdersID_sk_pk)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE dbo.OrderDetails
    ADD CONSTRAINT FK_OrderDetails_DimProducts
    FOREIGN KEY (Product_sk_fk) REFERENCES dbo.DimProducts(ProductID_sk_pk)
    ON DELETE CASCADE ON UPDATE CASCADE;
