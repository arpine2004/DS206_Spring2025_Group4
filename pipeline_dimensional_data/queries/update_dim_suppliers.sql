DECLARE @SOR_SK INT;
SELECT @SOR_SK = SOR_SK FROM dbo.Dim_SOR WHERE StagingTableName = 'Staging_Raw_Suppliers';

MERGE {db_dim}.{schema_dim}.DimSuppliers AS Target
USING {db_staging}.{schema_staging}.Staging_Raw_Suppliers AS Source
ON Target.SupplierID_nk = Source.SupplierID

WHEN MATCHED THEN
    UPDATE SET
        ContactTitle_Prior = CASE 
            WHEN ISNULL(Target.ContactTitle, '') <> ISNULL(Source.ContactTitle, '') THEN Target.ContactTitle
            ELSE ContactTitle_Prior
        END,
        ContactTitle = CASE
            WHEN ISNULL(Target.ContactTitle, '') <> ISNULL(Source.ContactTitle, '') THEN Source.ContactTitle
            ELSE Target.ContactTitle
        END,
        CompanyName = Source.CompanyName,
        ContactName = Source.ContactName,
        [Address] = Source.[Address],
        City = Source.City,
        Region = Source.Region,
        PostalCode = Source.PostalCode,
        Country = Source.Country,
        Phone = Source.Phone,
        Fax = Source.Fax,
        HomePage = Source.HomePage,
        sor_sk = @SOR_SK

WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        SupplierID_nk, CompanyName, ContactName, ContactTitle, ContactTitle_Prior,
        [Address], City, Region, PostalCode, Country, Phone, Fax, HomePage, sor_sk
    )
    VALUES (
        Source.SupplierID, Source.CompanyName, Source.ContactName, Source.ContactTitle, NULL,
        Source.[Address], Source.City, Source.Region, Source.PostalCode, Source.Country,
        Source.Phone, Source.Fax, Source.HomePage, @SOR_SK
    );
