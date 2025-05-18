DECLARE @SOR_SK INT;
SELECT @SOR_SK = SOR_SK FROM dbo.Dim_SOR WHERE StagingTableName = 'Staging_Raw_Products';

MERGE {db_dim}.{schema_dim}.DimProducts AS Target
USING (
    SELECT
        p.ProductID,
        p.ProductName,
        s.SuppliersID_sk_pk AS Supplier_sk_fk,
        c.CategoriesID_sk_pk AS Category_sk_fk,
        p.QuantityPerUnit,
        p.UnitPrice,
        p.UnitsInStock,
        p.UnitsOnOrder,
        p.ReorderLevel,
        p.Discontinued
    FROM {db_staging}.{schema_staging}.Staging_Raw_Products p
    LEFT JOIN {db_dim}.{schema_dim}.DimSuppliers s
        ON p.SupplierID = s.SupplierID_nk
    LEFT JOIN {db_dim}.{schema_dim}.DimCategories c
        ON p.CategoryID = c.CategoryID_nk
) AS Source
ON Target.ProductID_nk = Source.ProductID

WHEN MATCHED THEN
    UPDATE SET
        ProductName = Source.ProductName,
        Supplier_sk_fk = Source.Supplier_sk_fk,
        Category_sk_fk = Source.Category_sk_fk,
        QuantityPerUnit = Source.QuantityPerUnit,
        UnitPrice = Source.UnitPrice,
        UnitsInStock = Source.UnitsInStock,
        UnitsOnOrder = Source.UnitsOnOrder,
        ReorderLevel = Source.ReorderLevel,
        Discontinued = Source.Discontinued,
        sor_sk = @SOR_SK

WHEN NOT MATCHED THEN
    INSERT (
        ProductID_nk,
        ProductName,
        Supplier_sk_fk,
        Category_sk_fk,
        QuantityPerUnit,
        UnitPrice,
        UnitsInStock,
        UnitsOnOrder,
        ReorderLevel,
        Discontinued,
        sor_sk
    )
    VALUES (
        Source.ProductID,
        Source.ProductName,
        Source.Supplier_sk_fk,
        Source.Category_sk_fk,
        Source.QuantityPerUnit,
        Source.UnitPrice,
        Source.UnitsInStock,
        Source.UnitsOnOrder,
        Source.ReorderLevel,
        Source.Discontinued,
        @SOR_SK
    );
