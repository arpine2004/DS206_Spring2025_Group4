DECLARE @SOR_SK INT;
SELECT @SOR_SK = SOR_SK FROM dbo.Dim_SOR WHERE StagingTableName = 'Staging_Raw_Shippers';

MERGE {db_dim}.{schema_dim}.{table_dim} AS DST -- destination (DimShippers)
USING {db_staging}.{schema_staging}.{table_staging} AS SRC -- source (Staging_Raw_Shippers)
ON (SRC.ShipperID = DST.ShipperID_nk)

WHEN MATCHED AND (
    ISNULL(DST.CompanyName, '') <> ISNULL(SRC.CompanyName, '') OR
    ISNULL(DST.Phone, '') <> ISNULL(SRC.Phone, '')
)
THEN
    UPDATE SET
        DST.CompanyName = SRC.CompanyName,
        DST.Phone = SRC.Phone,
        DST.staging_raw_shipper_id = SRC.staging_raw_shipper_id_sk,
        DST.sor_sk = @SOR_SK

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (
        ShipperID_nk, CompanyName, Phone, staging_raw_shipper_id, sor_sk
    )
    VALUES (
        SRC.ShipperID, SRC.CompanyName, SRC.Phone, SRC.staging_raw_shipper_id_sk, @SOR_SK
    )

WHEN NOT MATCHED BY SOURCE
THEN
    DELETE;
