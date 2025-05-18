DECLARE @SOR_SK INT;
SELECT @SOR_SK = SOR_SK FROM dbo.Dim_SOR WHERE StagingTableName = 'Staging_Raw_Region';

-- 1. Archive changed records into history table
INSERT INTO {db_dim}.{schema_dim}.DimRegion_History (
    RegionID_sk_pk,
    RegionID_nk,
    RegionDescription,
    RegionCategory,
    RegionImportance,
    ArchivedDate
)
SELECT
    c.RegionID_sk_pk,
    c.RegionID_nk,
    c.RegionDescription,
    c.RegionCategory,
    c.RegionImportance,
    GETDATE()
FROM {db_dim}.{schema_dim}.DimRegion c
INNER JOIN {db_rel}.{schema_rel}.Staging_Raw_Region s
    ON c.RegionID_nk = s.RegionID
WHERE
    ISNULL(c.RegionDescription, '') <> ISNULL(s.RegionDescription, '') OR
    ISNULL(c.RegionCategory, '')    <> ISNULL(s.RegionCategory, '') OR
    ISNULL(c.RegionImportance, '')  <> ISNULL(s.RegionImportance, '');

-- 2. Update current records
UPDATE c
SET
    c.RegionDescription = s.RegionDescription,
    c.RegionCategory    = s.RegionCategory,
    c.RegionImportance  = s.RegionImportance,
    c.sor_sk            = @SOR_SK
FROM {db_dim}.{schema_dim}.DimRegion c
INNER JOIN {db_rel}.{schema_rel}.Staging_Raw_Region s
    ON c.RegionID_nk = s.RegionID
WHERE
    ISNULL(c.RegionDescription, '') <> ISNULL(s.RegionDescription, '') OR
    ISNULL(c.RegionCategory, '')    <> ISNULL(s.RegionCategory, '') OR
    ISNULL(c.RegionImportance, '')  <> ISNULL(s.RegionImportance, '');

-- 3. Insert new records
INSERT INTO {db_dim}.{schema_dim}.DimRegion (
    RegionID_nk,
    RegionDescription,
    RegionCategory,
    RegionImportance,
    sor_sk
)
SELECT
    s.RegionID,
    s.RegionDescription,
    s.RegionCategory,
    s.RegionImportance,
    @SOR_SK
FROM {db_rel}.{schema_rel}.Staging_Raw_Region s
LEFT JOIN {db_dim}.{schema_dim}.DimRegion c
    ON s.RegionID = c.RegionID_nk
WHERE c.RegionID_nk IS NULL;
