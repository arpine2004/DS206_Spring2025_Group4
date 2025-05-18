DECLARE @SOR_SK INT;
SELECT @SOR_SK = SOR_SK FROM dbo.Dim_SOR WHERE StagingTableName = 'Staging_Raw_Categories';

MERGE {db_dim}.{schema_dim}.{table_dim} AS DST -- destination (dimension)
USING {db_staging}.{schema_staging}.{table_staging} AS SRC -- source (staging)
ON (DST.CategoryID_nk = SRC.CategoryID)

WHEN MATCHED AND (
    ISNULL(DST.CategoryName, '') <> ISNULL(SRC.CategoryName, '') OR
    ISNULL(DST.[Description], '') <> ISNULL(SRC.[Description], '')
)
THEN
    UPDATE SET
        DST.CategoryName = SRC.CategoryName,
        DST.[Description] = SRC.[Description],
        sor_sk = @SOR_SK,
        DST.staging_raw_category_id = SRC.staging_raw_category_id_sk

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (CategoryID_nk, CategoryName, [Description], sor_sk, staging_raw_category_id)
    VALUES (SRC.CategoryID, SRC.CategoryName, SRC.[Description], @SOR_SK, SRC.staging_raw_category_id_sk);
