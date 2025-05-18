DECLARE @SOR_SK INT;
SELECT @SOR_SK = SOR_SK FROM dbo.Dim_SOR WHERE StagingTableName = 'Staging_Raw_Employees';

MERGE {db_dim}.{schema_dim}.{table_dim} AS DST -- destination
USING {db_staging}.{schema_staging}.{table_staging} AS SRC -- source
ON (SRC.EmployeeID = DST.EmployeeID_nk)

WHEN MATCHED AND (
    ISNULL(DST.LastName, '')         <> ISNULL(SRC.LastName, '') OR
    ISNULL(DST.FirstName, '')        <> ISNULL(SRC.FirstName, '') OR
    ISNULL(DST.Title, '')            <> ISNULL(SRC.Title, '') OR
    ISNULL(DST.TitleOfCourtesy, '') <> ISNULL(SRC.TitleOfCourtesy, '') OR
    ISNULL(DST.BirthDate, '1900-01-01') <> ISNULL(SRC.BirthDate, '1900-01-01') OR
    ISNULL(DST.HireDate, '1900-01-01')  <> ISNULL(SRC.HireDate, '1900-01-01') OR
    ISNULL(DST.[Address], '')        <> ISNULL(SRC.[Address], '') OR
    ISNULL(DST.City, '')             <> ISNULL(SRC.City, '') OR
    ISNULL(DST.Region, '')           <> ISNULL(SRC.Region, '') OR
    ISNULL(DST.PostalCode, '')       <> ISNULL(SRC.PostalCode, '') OR
    ISNULL(DST.Country, '')          <> ISNULL(SRC.Country, '') OR
    ISNULL(DST.HomePhone, '')        <> ISNULL(SRC.HomePhone, '') OR
    ISNULL(DST.Extension, '')        <> ISNULL(SRC.Extension, '') OR
    ISNULL(DST.Notes, '')            <> ISNULL(SRC.Notes, '') OR
    ISNULL(DST.ReportsTo, -1)        <> ISNULL(SRC.ReportsTo, -1) OR
    ISNULL(DST.PhotoPath, '')        <> ISNULL(SRC.PhotoPath, '')
)
THEN
    UPDATE SET
        DST.LastName = SRC.LastName,
        DST.FirstName = SRC.FirstName,
        DST.Title = SRC.Title,
        DST.TitleOfCourtesy = SRC.TitleOfCourtesy,
        DST.BirthDate = SRC.BirthDate,
        DST.HireDate = SRC.HireDate,
        DST.[Address] = SRC.[Address],
        DST.City = SRC.City,
        DST.Region = SRC.Region,
        DST.PostalCode = SRC.PostalCode,
        DST.Country = SRC.Country,
        DST.HomePhone = SRC.HomePhone,
        DST.Extension = SRC.Extension,
        DST.Notes = SRC.Notes,
        DST.ReportsTo = SRC.ReportsTo,
        DST.PhotoPath = SRC.PhotoPath,
        DST.sor_sk = @SOR_SK  -- update sor_sk on change (optional)

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (
        EmployeeID_nk, LastName, FirstName, Title, TitleOfCourtesy,
        BirthDate, HireDate, [Address], City, Region, PostalCode,
        Country, HomePhone, Extension, Notes, ReportsTo, PhotoPath,
        sor_sk                      -- add sor_sk column here
    )
    VALUES (
        SRC.EmployeeID, SRC.LastName, SRC.FirstName, SRC.Title, SRC.TitleOfCourtesy,
        SRC.BirthDate, SRC.HireDate, SRC.[Address], SRC.City, SRC.Region, SRC.PostalCode,
        SRC.Country, SRC.HomePhone, SRC.Extension, SRC.Notes, SRC.ReportsTo, SRC.PhotoPath,
        @SOR_SK                     -- insert sor_sk value here
    )

WHEN NOT MATCHED BY SOURCE
THEN
    DELETE;
