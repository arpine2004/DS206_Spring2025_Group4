DECLARE @Today DATETIME = CAST(GETDATE() AS DATE);
DECLARE @Yesterday DATETIME = DATEADD(DAY, -1, @Today);

DECLARE @SOR_SK INT;
SELECT @SOR_SK = SOR_SK FROM dbo.Dim_SOR WHERE StagingTableName = 'Staging_Raw_Customers';

-- 1) Expire current records if changed in staging
UPDATE c
SET
    c.ValidTo = @Yesterday,
    c.IsCurrent = 0
FROM {db_dim}.{schema_dim}.{table_dim} c
INNER JOIN {db_rel}.{schema_rel}.{table_stg} s
    ON c.CustomerID_nk = s.CustomerID
WHERE c.IsCurrent = 1
AND (
    ISNULL(c.CompanyName, '') <> ISNULL(s.CompanyName, '') OR
    ISNULL(c.ContactName, '') <> ISNULL(s.ContactName, '') OR
    ISNULL(c.ContactTitle, '') <> ISNULL(s.ContactTitle, '') OR
    ISNULL(c.Address, '') <> ISNULL(s.Address, '') OR
    ISNULL(c.City, '') <> ISNULL(s.City, '') OR
    ISNULL(c.Region, '') <> ISNULL(s.Region, '') OR
    ISNULL(c.PostalCode, '') <> ISNULL(s.PostalCode, '') OR
    ISNULL(c.Country, '') <> ISNULL(s.Country, '') OR
    ISNULL(c.Phone, '') <> ISNULL(s.Phone, '') OR
    ISNULL(c.Fax, '') <> ISNULL(s.Fax, '')
);

-- 2) Insert new records for changes and new customers
INSERT INTO {db_dim}.{schema_dim}.{table_dim} (
    CustomerID_nk, CompanyName, ContactName, ContactTitle,
    Address, City, Region, PostalCode, Country, Phone, Fax,
    ValidFrom, ValidTo, IsCurrent,
    sor_sk
)
SELECT
    s.CustomerID,
    s.CompanyName,
    s.ContactName,
    s.ContactTitle,
    s.Address,
    s.City,
    s.Region,
    s.PostalCode,
    s.Country,
    s.Phone,
    s.Fax,
    @Today,
    NULL,
    1,
    @SOR_SK
FROM {db_rel}.{schema_rel}.{table_stg} s
LEFT JOIN {db_dim}.{schema_dim}.{table_dim} c
    ON s.CustomerID = c.CustomerID_nk AND c.IsCurrent = 1
WHERE
    c.CustomerID_nk IS NULL -- brand new customer
    OR (
        ISNULL(c.CompanyName, '') <> ISNULL(s.CompanyName, '') OR
        ISNULL(c.ContactName, '') <> ISNULL(s.ContactName, '') OR
        ISNULL(c.ContactTitle, '') <> ISNULL(s.ContactTitle, '') OR
        ISNULL(c.Address, '') <> ISNULL(s.Address, '') OR
        ISNULL(c.City, '') <> ISNULL(s.City, '') OR
        ISNULL(c.Region, '') <> ISNULL(s.Region, '') OR
        ISNULL(c.PostalCode, '') <> ISNULL(s.PostalCode, '') OR
        ISNULL(c.Country, '') <> ISNULL(s.Country, '') OR
        ISNULL(c.Phone, '') <> ISNULL(s.Phone, '') OR
        ISNULL(c.Fax, '') <> ISNULL(s.Fax, '')
    );
