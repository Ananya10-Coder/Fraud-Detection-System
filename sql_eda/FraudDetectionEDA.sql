USE frauds;
-- EXPLORATORY DATA ANALYSIS OF THE COMPLETE DATASET

-- SECTION 1: BASIC DATA UNDERSTANDING


-- Total number of transactions
SELECT COUNT(*) FROM transactions_staging;

-- Show structure of the table
DESCRIBE transactions_staging; 

-- Count of unique users
SELECT COUNT(DISTINCT User_ID) AS unique_users
FROM transactions_staging; 

-- Number of fraudulent transactions
SELECT COUNT(*) 
FROM transactions_staging 
WHERE Fraudulent = 1;

-- Number of non-fraudulent transactions
SELECT COUNT(*) 
FROM transactions_staging 
WHERE Fraudulent = 0;


-- SECTION 2: TRANSACTION AMOUNT ANALYSIS


-- Average transaction amount
SELECT ROUND(AVG(Transaction_Amount), 2) AS avg_amnt 
FROM transactions_staging; 

-- Maximum transaction amount
SELECT MAX(Transaction_Amount) 
FROM transactions_staging; 

-- Minimum transaction amount
SELECT MIN(Transaction_Amount) 
FROM transactions_staging; 

-- Total transaction amount
SELECT ROUND(SUM(Transaction_Amount), 2) AS total_amnt 
FROM transactions_staging; 

-- Total and Average transaction amount per transaction type
SELECT Transaction_Type, SUM(Transaction_Amount) AS Total_amnt , ROUND(AVG(Transaction_Amount), 2) AS Average_amnt 
FROM transactions_staging GROUP BY Transaction_Type;

-- Total and Average transaction amount grouped by fraud status
SELECT Fraudulent, SUM(Transaction_Amount) AS Total_amnt , ROUND(AVG(Transaction_Amount), 2) AS Average_amnt 
FROM transactions_staging 
GROUP BY Fraudulent;

-- Total and Average transaction amount by payment method
SELECT Payment_Method, SUM(Transaction_Amount) AS Total_amnt , ROUND(AVG(Transaction_Amount), 2) AS Average_amnt 
FROM transactions_staging 
GROUP BY Payment_Method;

-- Total and Average transaction amount per location
SELECT Location, SUM(Transaction_Amount) AS Total_amnt , ROUND(AVG(Transaction_Amount), 2) AS Average_amnt 
FROM transactions_staging 
GROUP BY Location;


-- SECTION 3: TRANSACTION TYPE AND DEVICE ANALYSIS


-- Count of each transaction type
SELECT Transaction_Type, COUNT(*) AS num_of_txn 
FROM transactions_staging 
GROUP BY Transaction_Type;

-- Fraud rate per transaction type
SELECT Transaction_Type, ROUND(SUM(Fraudulent) * 100.0 / COUNT(*), 2) AS fraud_rate 
FROM transactions_staging 
GROUP BY Transaction_Type;

-- Count of transactions by device used
SELECT Device_Used, COUNT(*) 
FROM transactions_staging 
GROUP BY Device_Used;

-- Fraud rate per device type
SELECT Device_Used, ROUND(SUM(Fraudulent) * 100.0 / COUNT(*), 2) AS fraud_rate 
FROM transactions_staging 
GROUP BY Device_Used;

-- Number of fraudulent transactions by payment method
SELECT Payment_Method, COUNT(*) AS fraud_count 
FROM transactions_staging 
WHERE Fraudulent = 1 
GROUP BY Payment_Method;

-- Count of transactions by location
SELECT Location, COUNT(*) AS transaction_count 
FROM transactions_staging 
GROUP BY Location 
ORDER BY transaction_count DESC LIMIT 10;

-- Most common device used in fraud
SELECT Device_Used, COUNT(*) AS freq 
FROM transactions_staging 
WHERE Fraudulent = 1 
GROUP BY Device_Used 
ORDER BY freq DESC LIMIT 5;

-- Locations with highest fraud cases
SELECT Location, COUNT(*) AS fraud_count 
FROM transactions_staging 
WHERE Fraudulent = 1 
GROUP BY Location 
ORDER BY fraud_count DESC LIMIT 10;

-- Average number of transactions in last 24H grouped by fraud
SELECT Fraudulent, ROUND(AVG(Number_of_Transactions_Last_24H), 2) 
FROM  transactions_staging 
GROUP BY Fraudulent;


-- SECTION 4: TIME AND BEHAVIOR ANALYSIS


-- Hourly count of transactions
SELECT Time_of_Transaction AS HOUR, COUNT(*) AS total 
FROM transactions_staging 
GROUP BY HOUR 
ORDER BY HOUR;

-- Hour with most fraudulent activity
SELECT Time_of_Transaction AS HOUR, COUNT(*) AS frauds 
FROM transactions_staging 
WHERE Fraudulent = 1 
GROUP BY HOUR 
ORDER BY frauds DESC;

-- Average transaction amount by hour
SELECT Time_of_Transaction AS HOUR, ROUND(AVG(Transaction_Amount), 2) AS avg_amnt 
FROM transactions_staging 
GROUP BY HOUR 
ORDER BY avg_amnt DESC;

-- Fraudulent transaction amount by hour
SELECT Time_of_Transaction AS HOUR, ROUND(SUM(Transaction_Amount), 2) AS fraud_amount 
FROM transactions_staging 
WHERE Fraudulent = 1 
GROUP BY HOUR 
ORDER BY fraud_amount DESC;

-- Number of users with > 3 previous fraudulent transactions
SELECT COUNT(*) 
FROM transactions_staging 
WHERE Previous_Fraudulent_Transactions > 3;

-- Fraud rate for users with previous fraud history
SELECT ROUND(SUM(Fraudulent) * 100.0 / COUNT(*), 2) AS fraud_rate 
FROM transactions_staging 
WHERE Previous_Fraudulent_Transactions > 0;

-- Compare fraud based on number of previous frauds
SELECT Previous_Fraudulent_Transactions, COUNT(*) AS total, SUM(Fraudulent) AS frauds 
FROM transactions_staging 
GROUP BY Previous_Fraudulent_Transactions;

-- Relationship between account age and fraud (avg grouped)
SELECT Account_Age, ROUND(AVG(Fraudulent), 2)*100 AS fraud_probability_percentage 
FROM transactions_staging 
GROUP BY Account_Age 
ORDER BY Account_Age;

-- SECTION 5: ADVANCED PATTERNS AND CORRELATIONS

-- Users with highest total transaction amounts
SELECT User_ID, ROUND(SUM(Transaction_Amount), 2) AS total_spent 
FROM transactions_staging 
GROUP BY User_ID 
ORDER BY total_spent DESC LIMIT 10;

-- Users with most fraudulent transactions
SELECT User_ID, COUNT(*) AS fraud_count 
FROM transactions_staging 
WHERE Fraudulent = 1 
GROUP BY User_ID 
ORDER BY fraud_count DESC LIMIT 10;

-- Payment methods with high fraud percentage
SELECT Payment_Method, ROUND(SUM(Fraudulent) * 100.0 / COUNT(*), 2) AS fraud_rate 
FROM transactions_staging 
GROUP BY Payment_Method 
ORDER BY fraud_rate DESC;

-- Most frequently used payment method
SELECT Payment_Method, COUNT(*) 
FROM transactions 
GROUP BY Payment_Method 
ORDER BY COUNT(*) DESC LIMIT 1;

-- Top 10 users with the highest fraud rate (minimum 5 transactions)
SELECT User_ID, ROUND(SUM(Fraudulent) * 100.0 / COUNT(*), 2) AS fraud_rate
FROM transactions_staging
GROUP BY User_ID
HAVING COUNT(*) > 5
ORDER BY fraud_rate DESC
LIMIT 10;

-- Average fraud rate grouped by payment method and device used
SELECT Payment_Method, Device_Used, ROUND(AVG(Fraudulent), 3) AS fraud_rate
FROM transactions_staging
GROUP BY Payment_Method, Device_Used
ORDER BY fraud_rate DESC;

-- Count of users based on number of previous fraudulent transactions
SELECT Previous_Fraudulent_Transactions, COUNT(DISTINCT User_ID) AS user_count
FROM transactions_staging
GROUP BY Previous_Fraudulent_Transactions;

-- Fraud rate by device used and hour of the day
SELECT Device_Used,Time_of_Transaction AS hour, ROUND(AVG(Fraudulent), 2) AS fraud_rate
FROM transactions_staging
GROUP BY Device_Used, hour
ORDER BY fraud_rate DESC
LIMIT 10;

-- Fraud rate by number of transactions in the last 24 hours
SELECT Number_of_Transactions_Last_24H, ROUND(AVG(Fraudulent), 2) AS fraud_rate
FROM transactions_staging
GROUP BY Number_of_Transactions_Last_24H;

-- Top 5 fraud-prone user and location combinations
SELECT User_ID, Location, COUNT(*) AS fraud_count
FROM transactions_staging
WHERE Fraudulent = 1
GROUP BY User_ID, Location
ORDER BY fraud_count DESC
LIMIT 5;

-- Fraud rate based on transaction amount ranges
SELECT
  CASE
    WHEN Transaction_Amount < 10000 THEN '0-10k'
    WHEN Transaction_Amount < 20000 THEN '10k-20k'
    WHEN Transaction_Amount < 30000 THEN '20k-30k'
    WHEN Transaction_Amount < 40000 THEN '30k-40k'
    ELSE '40k+'
  END AS amount_bucket,
  ROUND(AVG(Fraudulent), 3) AS fraud_rate
FROM transactions_staging
GROUP BY amount_bucket;

-- Devices with the most high-value fraudulent transactions
SELECT Device_Used, COUNT(*) AS high_value_frauds
FROM transactions_staging
WHERE Fraudulent = 1 AND Transaction_Amount > 30000
GROUP BY Device_Used
ORDER BY high_value_frauds DESC;

-- 70. Fraud rate by buckets of previous frauds
SELECT
  CASE
    WHEN Previous_Fraudulent_Transactions = 0 THEN '0'
    WHEN Previous_Fraudulent_Transactions <= 2 THEN '1-2'
    ELSE '3+'
  END AS fraud_bucket,
  ROUND(AVG(Fraudulent), 3) AS fraud_rate
FROM transactions_staging
GROUP BY fraud_bucket;

-- Users who committed more than 2 frauds
SELECT User_ID, COUNT(*) AS frauds
FROM transactions_staging
WHERE Fraudulent = 1
GROUP BY User_ID
HAVING frauds >2;

-- Top 10 device-location pairs with most frauds
SELECT Device_Used, Location, COUNT(*) AS frauds
FROM transactions_staging
WHERE Fraudulent = 1
GROUP BY Device_Used, Location
ORDER BY frauds DESC
LIMIT 10;

-- Correlation-style breakdown of fraud rate by account age and transaction type
SELECT Account_Age, Transaction_Type, ROUND(AVG(Fraudulent), 2) AS fraud_rate
FROM transactions_staging
GROUP BY Account_Age, Transaction_Type
ORDER BY fraud_rate DESC;

-- Location-wise user count vs fraud count
SELECT Location, COUNT(DISTINCT User_ID) AS user_count, SUM(Fraudulent) AS fraud_count
FROM transactions_staging
GROUP BY Location
ORDER BY fraud_count DESC;

-- Most used device by users with more than 3 previous frauds
SELECT Device_Used, COUNT(*) AS usage_count
FROM transactions_staging
WHERE Previous_Fraudulent_Transactions > 3
GROUP BY Device_Used
ORDER BY usage_count DESC;

-- User IDs that only performed fraudulent transactions
SELECT User_ID
FROM transactions_staging
GROUP BY User_ID
HAVING MIN(Fraudulent) = 1 AND MAX(Fraudulent) = 1;

-- Users with 0 previous frauds but made fraudulent transactions
SELECT DISTINCT User_ID
FROM transactions_staging
WHERE Fraudulent = 1 AND Previous_Fraudulent_Transactions = 0;

-- Fraudulent transaction percentage by device and account age group
SELECT Device_Used, Account_Age, ROUND(AVG(Fraudulent) * 100, 2) AS fraud_rate
FROM transactions_staging
GROUP BY Device_Used, Account_Age
ORDER BY fraud_rate DESC;

-- Top 5 locations with the most unique users involved in fraud
SELECT Location, COUNT(DISTINCT User_ID) AS fraud_users
FROM transactions_staging
WHERE Fraudulent = 1
GROUP BY Location
ORDER BY fraud_users DESC
LIMIT 5;

-- Summary stats: total transactions, frauds, fraud rate, unique users
SELECT
  COUNT(*) AS total_txns,
  SUM(Fraudulent) AS total_frauds,
  ROUND(SUM(Fraudulent) * 100.0 / COUNT(*), 2) AS fraud_rate_percent,
  COUNT(DISTINCT User_ID) AS unique_users
FROM transactions_staging;

