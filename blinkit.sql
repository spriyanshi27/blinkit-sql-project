-- View the entire dataset
SELECT * FROM blinkit_data;

-- -----------------------------------------
-- DATA CLEANING: Standardize Fat Content
-- -----------------------------------------
-- Normalize inconsistent values in Item_Fat_Content
UPDATE blinkit_data
SET Item_Fat_Content = 
    CASE 
        WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat'
        WHEN Item_Fat_Content = 'reg' THEN 'Regular'
        ELSE Item_Fat_Content
    END;

-- Check distinct values after cleaning
SELECT DISTINCT Item_Fat_Content FROM blinkit_data;


-- -----------------------
-- A. KPI ANALYSIS
-- -----------------------

-- 1. Total Sales (in millions)
SELECT CAST(SUM(Total_Sales) / 1000000.0 AS DECIMAL(10,2)) AS Total_Sales_Million
FROM blinkit_data;

-- 2. Average Revenue per Sale
SELECT CAST(AVG(Total_Sales) AS INT) AS Avg_Sales
FROM blinkit_data;

-- 3. Total Number of Items Sold
SELECT COUNT(*) AS No_of_Orders
FROM blinkit_data;

-- 4. Average Rating
SELECT CAST(AVG(Rating) AS DECIMAL(10,1)) AS Avg_Rating
FROM blinkit_data;


-- ----------------------------------------
-- B. Sales by Fat Content
-- ----------------------------------------
SELECT 
  Item_Fat_Content, 
  CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_data
GROUP BY Item_Fat_Content;


-- ----------------------------------------
-- C. Sales by Item Type
-- ----------------------------------------
SELECT 
  TOP 5 Item_Type, 
  CAST(SUM(Total_Sales) / 1000 AS DECIMAL(10,2)) AS Total_Sales_Thousands,
  CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Avg_Sales,
  COUNT(*) AS No_of_Items,
  CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM blinkit_data
GROUP BY Item_Type
ORDER BY Total_Sales_Thousands DESC;


-- ---------------------------------------------------
-- D. Fat Content Sales by Outlet Location (Pivoted)
-- ---------------------------------------------------
SELECT 
    Outlet_Location_Type,
    ISNULL([Low Fat], 0) AS Low_Fat,
    ISNULL([Regular], 0) AS Regular
FROM
(
    SELECT 
        Outlet_Location_Type, 
        Item_Fat_Content,
        CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
    FROM blinkit_data
    GROUP BY Outlet_Location_Type, Item_Fat_Content
) AS SourceTable
PIVOT
(
    SUM(Total_Sales)
    FOR Item_Fat_Content IN ([Low Fat], [Regular])
) AS PivotTable
ORDER BY Outlet_Location_Type;


-- --------------------------------------------------
-- E. Sales by Outlet Establishment Year
-- --------------------------------------------------
SELECT 
  Outlet_Establishment_Year, 
  CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_data
GROUP BY Outlet_Establishment_Year
ORDER BY Outlet_Establishment_Year ASC;


-- --------------------------------------------------
-- F. Percentage of Sales by Outlet Size
-- --------------------------------------------------
SELECT 
    Outlet_Size, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST(SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER (), DECIMAL(10,2)) AS Sales_Percentage
FROM blinkit_data
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;


-- --------------------------------------------------
-- G. Sales by Outlet Location Type
-- --------------------------------------------------
SELECT 
  Outlet_Location_Type, 
  CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Total_Sales DESC;


-- --------------------------------------------------
-- H. Comprehensive Metrics by Outlet Type
-- --------------------------------------------------
SELECT 
  Outlet_Type, 
  CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
  CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Avg_Sales,
  COUNT(*) AS No_Of_Items,
  CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating,
  CAST(AVG(Item_Visibility) AS DECIMAL(10,2)) AS Item_Visibility
FROM blinkit_data
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC;
