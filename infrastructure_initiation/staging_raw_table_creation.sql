USE ORDER_DDS;

-- Drop staging raw tables if they exist (in correct order not strictly required here)
DROP TABLE IF EXISTS dbo.Staging_Raw_Customers;
DROP TABLE IF EXISTS dbo.Staging_Raw_Employees;
DROP TABLE IF EXISTS dbo.Staging_Raw_OrderDetails;
DROP TABLE IF EXISTS dbo.Staging_Raw_Orders;
DROP TABLE IF EXISTS dbo.Staging_Raw_Products;
DROP TABLE IF EXISTS dbo.Staging_Raw_Region;
DROP TABLE IF EXISTS dbo.Staging_Raw_Shippers;
DROP TABLE IF EXISTS dbo.Staging_Raw_Suppliers;
DROP TABLE IF EXISTS dbo.Staging_Raw_Territories;
DROP TABLE IF EXISTS dbo.Staging_Raw_Categories;


-- Staging table for Categories
CREATE TABLE dbo.Staging_Raw_Categories (
    staging_raw_category_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT NULL,
    CategoryName NVARCHAR(100) NULL,
    [Description] NVARCHAR(MAX) NULL -- reserved keyword bracketed
);

-- Staging table for Customers
CREATE TABLE dbo.Staging_Raw_Customers (
    staging_raw_customer_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NVARCHAR(10) NULL,  -- adjust length as per source
    CompanyName NVARCHAR(100) NULL,
    ContactName NVARCHAR(100) NULL,
    ContactTitle NVARCHAR(50) NULL,
    [Address] NVARCHAR(200) NULL,
    City NVARCHAR(50) NULL,
    Region NVARCHAR(50) NULL,
    PostalCode NVARCHAR(20) NULL,
    Country NVARCHAR(50) NULL,
    Phone NVARCHAR(30) NULL,
    Fax NVARCHAR(30) NULL
);


-- Staging table for Employees
CREATE TABLE dbo.Staging_Raw_Employees (
    staging_raw_employee_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NULL,
    LastName NVARCHAR(50) NULL,
    FirstName NVARCHAR(50) NULL,
    Title NVARCHAR(50) NULL,
    TitleOfCourtesy NVARCHAR(50) NULL,
    BirthDate DATETIME NULL,
    HireDate DATETIME NULL,
    [Address] NVARCHAR(200) NULL,
    City NVARCHAR(50) NULL,
    Region NVARCHAR(50) NULL,
    PostalCode NVARCHAR(20) NULL,
    Country NVARCHAR(50) NULL,
    HomePhone NVARCHAR(30) NULL,
    Extension NVARCHAR(10) NULL,
    Notes NVARCHAR(MAX) NULL,
    ReportsTo INT NULL,
    PhotoPath NVARCHAR(200) NULL
);

-- Staging table for Order Details
CREATE TABLE dbo.Staging_Raw_OrderDetails (
    staging_raw_orderdetail_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NULL,
    ProductID INT NULL,
    UnitPrice DECIMAL(10,2) NULL,
    Quantity INT NULL,
    Discount DECIMAL(5,2) NULL
);

-- Staging table for Orders
CREATE TABLE dbo.Staging_Raw_Orders (
    staging_raw_order_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NULL,
    CustomerID NVARCHAR(255) NULL,  -- use NVARCHAR to be consistent
    EmployeeID INT NULL,
    OrderDate DATE NULL,
    RequiredDate DATE NULL,
    ShippedDate DATE NULL,
    ShipVia INT NULL,
    Freight NUMERIC(18,2) NULL,  -- added precision
    ShipName NVARCHAR(255) NULL,
    ShipAddress NVARCHAR(255) NULL,
    ShipCity NVARCHAR(255) NULL,
    ShipRegion NVARCHAR(255) NULL,
    ShipPostalCode NVARCHAR(255) NULL,
    ShipCountry NVARCHAR(255) NULL,
    TerritoryID INT NULL
);

-- Staging table for Products
CREATE TABLE dbo.Staging_Raw_Products (
    staging_raw_product_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NULL,
    ProductName NVARCHAR(100) NULL,
    SupplierID INT NULL,
    CategoryID INT NULL,
    QuantityPerUnit NVARCHAR(50) NULL,
    UnitPrice DECIMAL(10,2) NULL,
    UnitsInStock INT NULL,
    UnitsOnOrder INT NULL,
    ReorderLevel INT NULL,
    Discontinued BIT NULL
);

-- Staging table for Regions
CREATE TABLE dbo.Staging_Raw_Region (
    staging_raw_region_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    RegionID INT NULL,
    RegionDescription NVARCHAR(100) NULL,
    RegionCategory NVARCHAR(100) NULL,
    RegionImportance NVARCHAR(10) NULL
);

-- Staging table for Shippers
CREATE TABLE dbo.Staging_Raw_Shippers (
    staging_raw_shipper_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    ShipperID INT NULL,
    CompanyName NVARCHAR(100) NULL,
    Phone NVARCHAR(30) NULL
);

-- Staging table for Suppliers
CREATE TABLE dbo.Staging_Raw_Suppliers (
    staging_raw_supplier_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT NULL,
    CompanyName NVARCHAR(100) NULL,
    ContactName NVARCHAR(100) NULL,
    ContactTitle NVARCHAR(50) NULL,
    [Address] NVARCHAR(200) NULL,
    City NVARCHAR(50) NULL,
    Region NVARCHAR(50) NULL,
    PostalCode NVARCHAR(20) NULL,
    Country NVARCHAR(50) NULL,
    Phone NVARCHAR(30) NULL,
    Fax NVARCHAR(30) NULL,
    HomePage NVARCHAR(MAX) NULL
);

-- Staging table for Territories
CREATE TABLE dbo.Staging_Raw_Territories (
    staging_raw_territory_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    TerritoryID INT NULL,
    TerritoryDescription NVARCHAR(50) NULL,
    TerritoryCode NVARCHAR(20) NULL,
    RegionID INT NULL
);
