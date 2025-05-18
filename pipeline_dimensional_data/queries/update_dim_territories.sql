DECLARE @SOR_SK INT;
SELECT @SOR_SK = SOR_SK FROM dbo.Dim_SOR WHERE StagingTableName = 'Staging_Raw_Territories';

-- 1. Archive changed records into history table
INSERT INTO {db_dim}.{schema_dim}.DimTerritories_History (
    TerritoriesID_sk_pk,
    TerritoryID_nk,
    TerritoryDescription,
    TerritoryCode,
    Region_sk_fk,
    ArchivedDate
)
SELECT
    c.TerritoriesID_sk_pk,
    c.TerritoryID_nk,
    c.TerritoryDescription,
    c.TerritoryCode,
    c.Region_sk_fk,
    GETDATE()
FROM {db_dim}.{schema_dim}.DimTerritories c
INNER JOIN {db_rel}.{schema_rel}.Staging_Raw_Territories s
    ON c.TerritoryID_nk = s.TerritoryID
WHERE
    ISNULL(c.TerritoryDescription, '') <> ISNULL(s.TerritoryDescription, '') OR
    ISNULL(c.TerritoryCode, '') <> ISNULL(s.TerritoryCode, '') OR
    c.Region_sk_fk <> (
        SELECT RegionID_sk_pk FROM {db_dim}.{schema_dim}.DimRegion r WHERE r.RegionID_nk = s.RegionID
    );

-- 2. Update current records
UPDATE c
SET
    c.TerritoryDescription = s.TerritoryDescription,
    c.TerritoryCode = s.TerritoryCode,
    c.Region_sk_fk = r.RegionID_sk_pk,
    c.sor_sk = @SOR_SK
FROM {db_dim}.{schema_dim}.DimTerritories c
INNER JOIN {db_rel}.{schema_rel}.Staging_Raw_Territories s
    ON c.TerritoryID_nk = s.TerritoryID
INNER JOIN {db_dim}.{schema_dim}.DimRegion r
    ON r.RegionID_nk = s.RegionID
WHERE
    ISNULL(c.TerritoryDescription, '') <> ISNULL(s.TerritoryDescription, '') OR
    ISNULL(c.TerritoryCode, '') <> ISNULL(s.TerritoryCode, '') OR
    c.Region_sk_fk <> r.RegionID_sk_pk;

-- 3. Insert new records
INSERT INTO {db_dim}.{schema_dim}.DimTerritories (
    TerritoryID_nk,
    TerritoryDescription,
    TerritoryCode,
    Region_sk_fk,
    sor_sk
)
SELECT
    s.TerritoryID,
    s.TerritoryDescription,
    s.TerritoryCode,
    r.RegionID_sk_pk,
    @SOR_SK
FROM {db_rel}.{schema_rel}.Staging_Raw_Territories s
LEFT JOIN {db_dim}.{schema_dim}.DimTerritories c
    ON s.TerritoryID = c.TerritoryID_nk
INNER JOIN {db_dim}.{schema_dim}.DimRegion r
    ON r.RegionID_nk = s.RegionID
WHERE c.TerritoryID_nk IS NULL;
