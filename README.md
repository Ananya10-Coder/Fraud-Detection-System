# 🛡️ Fraud Detection Project
[![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/drive/1MtDu0b1mh_3ZUYxOBgUS6kPtIwlBz_Tc#scrollTo=fec06f5b)

## 🔍 Project Overview

This end-to-end fraud detection case study simulates a real-world data science and analytics pipeline. It demonstrates how structured data can be transformed into actionable insights through a blend of SQL-based data engineering, machine learning classification models, and business intelligence visualization.

The goal is to identify patterns of fraudulent behavior within a financial transactions dataset and build a foundation for proactive fraud prevention systems.

---

## 🗂️ Repository Structure

```
Fraud-Detection-System/
├── README.md                          # Project summary and usage
├── sql_eda/                           # SQL scripts for data loading, cleaning, and EDA
│   ├── FraudDetectionCleaning.sql     # Creates schema, cleans & loads data
│   ├── FraudDetectionEDA.sql          # SQL-based analysis of fraud trends
├── ml_notebook/                       # Machine learning classification logic
│   └── Fraud_Detection_Personalized_Modeling.ipynb
├── visualization/                    # Tableau dashboard & visual materials
│   ├── dashboard.twbx                # Tableau workbook or export
```

---

## 🔧 Part 1: SQL-Based EDA & Data Preparation

**Tools**: MySQL, SQL scripts

### ✅ Key Steps:

* Created and used a dedicated schema: `frauds`
* Defined transactional data schema including user details, transaction types, timestamps, and behavioral metadata
* Used `LOAD DATA LOCAL INFILE` to import a CSV dataset into a MySQL table
* Cleaned data by trimming whitespace, filling blanks, correcting types (e.g. converting decimal to integers)
* Built a staging table to isolate and standardize usable data for modeling
* Identified common fraud-inducing features like:

  * High-frequency users
  * Specific devices and locations
  * Time-of-day spikes
  * Past fraud history

### 📊 SQL EDA Highlights:

* Total transactions vs. fraudulent transactions
* Fraud rate by device, location, transaction type
* Patterns by hour of day and payment method
* Fraud risk distribution by previous behavior and account age
* High-risk user-location-device combinations

> 📂 See scripts: `sql_eda/FraudDetectionCleaning.sql` and `sql_eda/FraudDetectionEDA.sql`

---

## 📊 Part 2: Tableau Dashboard

**Tools**: Tableau Public / Desktop

### 🎨 Dashboards Include:

* Fraud percentage by device and payment method
* Heatmap of fraudulent transactions across hours
* User behavior dashboard with filters on previous fraud count
* Location-wise fraud concentration

### 🧠 Design Goals:

* Non-technical stakeholder readability
* Highlight red flags visually
* Enable drill-downs (e.g., by user, device, time)

📸 *Screenshots available in `/visualization/tableau_screenshots/`*

> You can open `dashboard.twb` using Tableau Desktop or Public.

---

## 🤖 Part 3: Machine Learning Classification

**Tools**: Python, Pandas, Scikit-learn, Matplotlib, Seaborn

### ⚙️ Steps Covered:

* Loaded the cleaned dataset into a pandas dataframe
* Feature engineered new predictors based on SQL insights:

  * Number of transactions in last 24H
  * Bucketed transaction amount
  * Device type and account age group
* Split data into training and test sets (80/20)
* Trained a **Logistic Regression** model as a baseline
* Evaluated performance using:

  * Confusion matrix
  * Classification report (precision, recall, F1-score)
  * Fraud detection recall: Key for minimizing false negatives
* Discussed potential improvements (Random Forests, SMOTE, etc.)

> 📓 Notebook: `ml_notebook/Fraud_Detection_Personalized_Modeling.ipynb`

---

## ✅ Results Summary

| Metric               | Value (Example Only) |
| -------------------- | -------------------- |
| Accuracy             | 92.3%                |
| Precision            | 84.7%                |
| Recall (Fraud Class) | 76.5%                |
| F1 Score             | 80.3%                |

*Note: Results depend on class balance and features. Custom thresholds can improve recall.*

---

## 📌 Dataset Source

The dataset was sourced from a public Kaggle competition:

> [https://www.kaggle.com](https://www.kaggle.com) (Anonymized financial fraud dataset)

It was cleaned and extended with SQL-based staging and standardized for analysis.

---

## 💡 Key Learnings & Reflection

* SQL is extremely powerful for preparing and understanding transactional data
* Tableau helps communicate fraud insights across business units
* Even simple ML models, when based on rich features, can perform well
* Structuring a project into modular, reusable parts improves maintainability and storytelling
