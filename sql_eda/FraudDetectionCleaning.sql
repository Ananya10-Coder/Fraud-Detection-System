-- creating database and table for the dataset

CREATE SCHEMA frauds;
USE frauds;

CREATE TABLE transactions (
    Transaction_ID VARCHAR(10),
    User_ID INT,
    Transaction_Amount DECIMAL(12,2) NULL,
    Transaction_Type VARCHAR(30),
    Time_of_Transaction DECIMAL(4,2) NULL,
    Device_Used VARCHAR(20),
    Location VARCHAR(50),
    Previous_Fraudulent_Transactions INT,
    Account_Age INT,
    Number_of_Transactions_Last_24H INT,
    Payment_Method VARCHAR(30),
    Fraudulent BOOLEAN
);

-- Loading the dataset into the table 

LOAD DATA LOCAL INFILE '/Users/ananya/Desktop/FraudDetectionDataset_15k.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
(Transaction_ID, User_ID, Transaction_Amount, Transaction_Type, Time_of_Transaction,
 Device_Used, Location, Previous_Fraudulent_Transactions, Account_Age,
 Number_of_Transactions_Last_24H, Payment_Method, Fraudulent);
 
-- Creating a trigger to ensure correct insertion of data

DELIMITER $$

CREATE TRIGGER check_unique_transaction_id
BEFORE INSERT ON transactions_staging
FOR EACH ROW
BEGIN
    IF NEW.Transaction_ID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transaction_ID cannot be NULL';
    END IF;

    IF EXISTS (
        SELECT 1 FROM transactions_staging WHERE Transaction_ID = NEW.Transaction_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transaction_ID must be unique';
    END IF;
END$$

DELIMITER ;

-- DATA CLEANING

WITH duplicate_cte as (
SELECT * , ROW_NUMBER() OVER (PARTITION BY Transaction_ID,
    User_ID,
    Transaction_Amount,
    Transaction_Type ,
    Time_of_Transaction ,
    Device_Used ,
    Location,
    Previous_Fraudulent_Transactions,
    Account_Age,
    Number_of_Transactions_Last_24H,
    Payment_Method,
    Fraudulent)
    AS row_num FROM transactions
)

SELECT * 
FROM duplicate_cte 
WHERE row_num > 1;  -- Checking if any duplicate rows exist(none do) 

-- creating a staging table

CREATE TABLE transactions_staging LIKE transactions;

INSERT transactions_staging
SELECT * FROM transactions;

 SELECT * FROM transactions_staging LIMIT 5;

-- starting the data cleaning process

SET SQL_SAFE_UPDATES = 0;

-- STANDARDIZING DATA: TRIMMING THE DATA VALUES IN COLUMNS TO REMOVE PRECEDING AND SUCCESSING SPACES 

UPDATE transactions_staging
SET Transaction_ID = TRIM(Transaction_ID),
    User_ID = TRIM(User_ID),
    Transaction_Amount = TRIM(Transaction_Amount),
    Transaction_Type = TRIM(Transaction_Type),
    Time_of_Transaction = TRIM(Time_of_Transaction),
    Device_Used = TRIM(Device_Used),
    Location = TRIM(Location),
    Previous_Fraudulent_Transactions = TRIM(Previous_Fraudulent_Transactions),
    Account_Age = TRIM(Account_Age),
    Number_of_Transactions_Last_24H = TRIM(Number_of_Transactions_Last_24H),
    Payment_Method = TRIM(Payment_Method),
    Fraudulent = TRIM(Fraudulent)
; 

-- STANDARDIZING DATA: MAKING DATA MORE CONSISTENT

-- Removing decimal parts of amount and changing data type to int
UPDATE transactions_staging
SET Transaction_Amount = FLOOR(Transaction_Amount);

ALTER TABLE transactions_staging
MODIFY COLUMN Transaction_Amount INT;

-- Checking Transaction type 

SELECT DISTINCT	Transaction_Type 
FROM Transactions_Staging; -- no inconsistent data

-- Changing the time column to int to be able to use it for calculations

ALTER TABLE Transactions_Staging
MODIFY COLUMN Time_of_Transaction INT;

-- Checking discrepancies in data of device_used column

SELECT DISTINCT Device_Used 
FROM transactions_staging 
ORDER BY Device_Used ASC;

 -- blanks and unknown device mean the same thing
 
UPDATE transactions_staging
SET Device_Used = "Unknown Device"
WHERE Device_Used LIKE "";

-- Checking discrepancies in data of Location column

SELECT DISTINCT Location 
FROM transactions_staging 
ORDER BY Location ASC; 

-- updating blanks as unknown location 

UPDATE transactions_staging
SET Location = "Unknown Location"
WHERE Location LIKE "";

-- Checking discrepancies in data of Payment_Method column

SELECT DISTINCT Payment_Method 
FROM transactions_staging 
ORDER BY Payment_Method ASC; 

-- updating blanks as unknown payement method 

UPDATE transactions_staging
SET Payment_Method = "Unknown Method"
WHERE Payment_Method LIKE "";

-- DONE WITH THE STANDARDIZING DATA. 


-- removing data which was of no use to the dataset

DELETE FROM transactions_staging 
WHERE Payment_Method = "Unknown Method" 
AND Location = "Unknown Location"
AND Fraudulent = 0;  

SELECT * FROM transactions_staging WHERE fraudulent = 1;
SELECT * FROM transactions_staging;

-- Creating a table view to better understand fraudulent data

CREATE VIEW TSview_fraudulent AS
SELECT * 
FROM transactions_staging 
WHERE fraudulent = 1;
    
SELECT * 
FROM TSview_fraudulent;



