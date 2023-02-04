# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# ORDERS DATA ANALYSIS  
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


# What are the total sales for each campaign?
SELECT Campaign_ID, ROUND(SUM(Total_Price)) AS 'Total Sales'
FROM orders_dataset
GROUP BY Campaign_ID;

# Sales for each state and marketing campaign?
SELECT State, Campaign_ID, ROUND(SUM(Total_Price), 2) AS Sales 
FROM orders_dataset
JOIN customer_dataset
ON orders_dataset.customer_ID = customer_dataset.customer_ID
GROUP BY State, Campaign_ID;

# For every dollar spent on advertising how much is gained in revenue? ROAS
WITH advertisement_spend AS (
  SELECT Campaign_ID, ROUND(SUM(Clicks * Cost_Per_Click)) AS Advertisement_Spend
  FROM landing_page_dataset
  GROUP BY Campaign_ID
)
SELECT 
  orders_dataset.Campaign_ID,
  advertisement_spend.Advertisement_Spend,
  ROUND(SUM(Total_Price)) AS Revenue,
  ROUND(SUM(Total_Price) / advertisement_spend.Advertisement_Spend,2) AS ROAS
FROM orders_dataset
JOIN advertisement_spend
ON orders_dataset.Campaign_ID = advertisement_spend.Campaign_ID
GROUP BY orders_dataset.Campaign_ID;

# What is the average purchase quantity?
SELECT ROUND(AVG(Quantity)) AS 'Average Purchase Quantity'
From orders_dataset;

# What are the top 5 customers that bought the most this year? 
SELECT First_Name, Last_Name, Email, orders_dataset.Customer_ID, COUNT(*) AS 'Number of Orders'
FROM orders_dataset
JOIN customer_dataset ON orders_dataset.Customer_ID = customer_dataset.Customer_ID
GROUP BY Customer_ID, First_Name, Last_Name, Email
ORDER BY COUNT(*) DESC
LIMIT 5;

# What are the sales by month?
SELECT MONTH(STR_TO_DATE(Dates, '%m/%d/%Y')) as Month, ROUND(SUM(Total_Price)) AS Sales
FROM orders_dataset
GROUP BY MONTH(STR_TO_DATE(Dates, '%m/%d/%Y'))
ORDER BY Month ASC;

# What are the daily sales?
SELECT Dates, ROUND(SUM(Total_Price)) AS Sales
FROM orders_dataset
GROUP BY DATES
ORDER BY DATES;

# What is incremental sales percentage for each month? How about per state?
WITH sales_by_month AS(
SELECT MONTH(STR_TO_DATE(Dates, '%m/%d/%Y')) as Month, ROUND(SUM(Total_Price)) AS Sales, State
FROM orders_dataset
JOIN customer_dataset
ON orders_dataset.customer_ID = customer_dataset.customer_ID
GROUP BY MONTH(STR_TO_DATE(Dates, '%m/%d/%Y')), State
ORDER BY MONTH ASC)
SELECT sbm.Month, sbm.State, sbm.Sales,
ROUND(( sbm.Sales - LAG(sbm.Sales) OVER (PARTITION BY State ORDER BY sbm.MONTH)) / LAG(sbm.Sales) OVER (PARTITION BY State ORDER BY sbm.Month) * 100, 2) as 'Incremental Sales Percentage'
FROM sales_by_month sbm
ORDER BY sbm.State, sbm.Month;

# What is the incremental sales percentage for each day? How about per state?
WITH sales_by_date AS (
    SELECT Campaign_ID, STR_TO_DATE(Dates, '%m/%d/%Y') AS Dates, ROUND(SUM(Total_Price)) AS Sales, State
    FROM orders_dataset
    JOIN customer_dataset
	ON orders_dataset.customer_ID = customer_dataset.customer_ID
    GROUP BY Dates, Campaign_ID, State
    ORDER BY Dates)
SELECT Campaign_ID ,sbd.Dates, sbd.Sales, State,
ROUND(( sbd.Sales - LAG(sbd.Sales) OVER (PARTITION BY State ORDER BY sbd.Dates)) / LAG(sbd.Sales) OVER (PARTITION BY State ORDER BY sbd.Dates) * 100, 2) as 'Incremental Sales Percentage'
FROM sales_by_date sbd
ORDER BY State;

# What are our most purchased product this year?
SELECT Product, SUM(Quantity) AS 'Total Quantity'
FROM orders_dataset
GROUP BY Product
ORDER BY SUM(Quantity) DESC;


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# DIGITAL MARKETING METRIC DATA ANALYSIS 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 


# Whats the average click through rate for each marketing campaign?
SELECT Campaign_ID, ROUND(AVG(clicks / Impressions),2) AS CTR
FROM landing_page_dataset
GROUP BY Campaign_ID
ORDER BY CTR DESC;

# Are there any correlations between the campaign CTR and a specific ad platform the advertisement was on?
SELECT Campaign_ID, Ad_platform, ROUND(AVG(clicks / Impressions),2) AS CTR
From landing_page_dataset
GROUP BY Campaign_ID, Ad_platform
ORDER BY Campaign_ID, CTR DESC;

# Whats the average bounce rate for each marketing campaign?
SELECT Campaign_ID, ROUND(AVG(Bounce_Rate),2) AS 'Average Bounce Rate'
FROM landing_page_dataset
GROUP BY Campaign_ID
ORDER BY Campaign_ID ASC;

# Is there a correlation between customer bounce rate and the ad format?
SELECT Campaign_ID, Ad_Format, ROUND(AVG(Bounce_Rate),2) AS 'Average Bounce Rate'
FROM landing_page_dataset
GROUP BY Campaign_ID, Ad_Format
ORDER BY Campaign_ID ASC;

# What is the advertisement spend for each campaign
SELECT Campaign_ID, ROUND(SUM(Clicks * Cost_Per_Click)) AS Advertisement_Spend
FROM landing_page_dataset
GROUP BY Campaign_ID;


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# CUSTOMER DATA ANALYSIS  
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


# What is the average age of customers
SELECT ROUND(AVG(Age)) AS 'Average Customer Age'
FROM customer_dataset;

# Customers Age Distribution
SELECT Age_Range, COUNT(*) as 'Customer Count' , State
FROM (
    SELECT State,
      CASE 
        WHEN Age BETWEEN 0 AND 10 THEN '0-10'
        WHEN Age BETWEEN 11 AND 20 THEN '11-20'
        WHEN Age BETWEEN 21 AND 30 THEN '21-30'
        WHEN Age BETWEEN 31 AND 40 THEN '31-40'
        WHEN Age BETWEEN 41 AND 50 THEN '41-50'
        WHEN Age BETWEEN 51 AND 60 THEN '51-60'
        WHEN Age BETWEEN 61 AND 70 THEN '61-70'
        WHEN Age BETWEEN 71 AND 80 THEN '71-80'
        WHEN Age BETWEEN 81 AND 90 THEN '81-90'
        ELSE '91+' 
      END as Age_Range
    FROM customer_dataset
    WHERE Age IS NOT NULL
) as subquery
GROUP BY Age_Range, State
ORDER BY Age_Range ASC;
 
# Whats the sex demographic per customer?
SELECT State, 'Male' as Gender, COUNT(sex) as Total
FROM customer_dataset
WHERE sex = 'Male' 
GROUP BY State
UNION
SELECT State, 'Female' as Gender, COUNT(sex) as Total
FROM customer_dataset 
WHERE sex = 'Female'
GROUP BY State
ORDER BY State ASC;

# Which states are most of our customers From?
SELECT State, Count(orders_dataset.Customer) AS 'Customer Count', ROUND(SUM(Total_Price)) AS Sales
FROM customer_dataset
JOIN orders_dataset ON customer_dataset.Customer_ID = orders_dataset.Customer_ID
GROUP BY State
ORDER BY State;
