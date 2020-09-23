
DROP TABLE IF EXISTS sales;
CREATE TABLE sales(
  "OrderDate" DATE,
  "StockDate" DATE,
  "OrderNumber" VARCHAR(64),
  "ProductKey" INT,
  "CustomerKey" INT,
  "TerritoryKey" INT,
  "OrderLineItem" INT,
  "OrderQuantity" INT
);

DROP TABLE IF EXISTS products;
CREATE TABLE products(
   ProductKey INT,
   ProductSubcategoryKey INT,
   ProductSKU TEXT,
   ProductName TEXT,
   ModelName TEXT,
   ProductDescription TEXT,
   ProductColor TEXT,
   ProductSize TEXT,
   ProductStyle TEXT,
   ProductCost DECIMAL(38, 2),
   ProductPrice DECIMAL(38, 2)
);

.mode csv
.import C:/Sandbox/PoC/RecommendationEngine/data/AdventureWorks_Sales_2015.csv sales
.import C:/Sandbox/PoC/RecommendationEngine/data/AdventureWorks_Sales_2016.csv sales
.import C:/Sandbox/PoC/RecommendationEngine/data/AdventureWorks_Sales_2017.csv sales

.import C:/Sandbox/PoC/RecommendationEngine/data/AdventureWorks_Products.csv products

SELECT ProductKey, CustomerKey FROM sales GROUP BY 1,2;

SELECT COUNT(*) AS NumCustomers, ProductKey FROM (SELECT ProductKey, CustomerKey FROM sales GROUP BY 1,2) GROUP BY ProductKey;

DROP VIEW IF EXISTS customer_counts_per_product;
CREATE VIEW customer_counts_per_product AS
    SELECT COUNT(*) AS CountCustomers, 
           ProductKey 
      FROM (SELECT ProductKey, CustomerKey FROM sales GROUP BY 1,2) GROUP BY ProductKey;

DROP VIEW IF EXISTS combined_sales;
CREATE VIEW combined_sales AS
    SELECT t1.ProductKey AS ProductKey1,
           t2.ProductKey AS ProductKey2,
           COUNT(*) AS CountCombined
      FROM (SELECT ProductKey, CustomerKey FROM sales GROUP BY 1,2) AS t1
      JOIN (SELECT ProductKey, CustomerKey FROM sales GROUP BY 1,2) AS t2 ON t1.CustomerKey = t2.CustomerKey
     GROUP BY 1, 2;



DROP VIEW IF EXISTS combined_frequences_vw;
CREATE VIEW combined_frequences_vw AS
    SELECT t1.ProductKey1, 
           t1.ProductKey2,
           t1.CountCombined,
           t2.CountCustomers AS CountProduct,
           ROUND(CAST(t1.CountCombined AS DOUBLE)/t2.CountCustomers, 3) AS score
      FROM combined_sales t1
      JOIN customer_counts_per_product t2 ON t1.ProductKey1 = t2.ProductKey;


DROP TABLE IF EXISTS combined_frequences;
CREATE TABLE combined_frequences AS SELECT * FROM combined_frequences_vw WHERE ProductKey1 <> ProductKey2;

SELECT * FROM combined_frequences ORDER BY score DESC LIMIT 20;
SELECT f.*,
       p1.ProductName,
       p2.ProductName
  FROM combined_frequences f
  JOIN products p1 ON p1.ProductKey = f.ProductKey1
  JOIN products p2 ON p2.ProductKey = f.ProductKey2
  ORDER BY score DESC LIMIT 20;

SELECT f.*,
       p1.ProductName,
       p2.ProductName
  FROM combined_frequences f
  JOIN products p1 ON p1.ProductKey = f.ProductKey1
  JOIN products p2 ON p2.ProductKey = f.ProductKey2
 WHERE f.ProductKey1 = 479
  ORDER BY score DESC LIMIT 20;

  
SELECT 12/293;
SELECT CAST(12 AS DOUBLE)/293;
