# Olympics - Data Engineering Pipeline

## Project Overview

This project implements an end-to-end **Data Engineering pipeline** using the Olympic Games dataset (Kaggle).
The goal is to design and build a **Data Warehouse** that enables analytical queries on athletes, countries, events and medals.

The solution includes data ingestion, transformation and loading using **SQL Server Integration Services (SSIS)** and **SQL Server**.
To ensure traceability, data quality and reliable pipeline execution, auditing columns were added to all staging and warehouse tables.

---

## Objectives

* Transform raw CSV data into a structured analytical model
* Build a **Star Schema** with fact and dimension tables
* Implement an ETL pipeline with staging, transformations, and loading
* Ensure data quality, consistency, and reusability
* Enable analytical queries for insights (e.g., medals by country, athlete performance)

---

## Architecture

```
CSV (Kaggle Dataset)
        ↓
Staging Tables
        ↓
Data Transformation (SSIS)
        ↓
Data Warehouse (SQL Server)
        ↓
Analytical Queries
```

---

## Data Model

The project follows a **Star Schema** design:

### Fact Table

* **Fact_Olimpiadas**

  * ID_Atleta - Identification of each Athlete
  * NOC - National Olympic Committee
  * Games - Different sports and disciplines 
  * ID_Mod - Identification of Modality
  * Medal - Medal won (Bronze, Silver and Gold)

### Dimension Tables

* **Dim_Atleta** → Athlete details (Name, Sex, Age, Height, Weight, Team)
* **Dim_Comites** → Country/region (NOC, Region)
* **Dim_Olimpiadas** → Olympic editions (Year, Season, City)
* **Dim_Modalidades** → Sports and events

---

## Technologies Used

* SQL Server
* SSIS (SQL Server Integration Services)
* Visual Studio

---

## ETL Process

### 1. Extraction

* Data loaded from CSV (`athlete_events.csv`)

### 2. Staging

* Temporary staging tables used for:

  * Data validation
  * Type conversions
  * Pre-processing

### 3. Transformation

* Handling missing values (`NA`)
* Data type corrections (e.g., Height, Weight)
* Removing duplicates
* Creating surrogate keys (ID_Mod)

### 4. Load

* Incremental loading using **MERGE**
* Separation between dimension and fact loading

## Auditing & Metadata

### Audit Columns

- **DW_row_checksum** → Hash of the row used to detect changes between loads  
- **DW_run_id** → Identifier of the ETL execution  
- **DW_updated_on** → Timestamp of the last update  
- **DW_source_system** → Identifies the origin of the data  

### Auditing Strategy

- Each ETL execution generates a unique **RunId**
- Row-level changes are detected using checksum comparison
- Incremental loading is implemented using **MERGE + checksum**
- Audit information allows tracking:
  - Inserted rows  
  - Updated rows  
  - Data source origin  

This approach ensures:
- Idempotent ETL execution  
- Prevention of duplicate updates  
- Full traceability of data changes  
---

## Repository Structure

```
├── sql/            # SQL scripts (tables, merges, queries)
├── ssis/           # SSIS project and packages
├── docs/           # Architecture and data model diagrams
├── data_sample/    # Small sample of dataset (optional)
├── README.md
```

---

## Key Concepts Demonstrated

* Data Warehousing
* Star Schema (Fact & Dimensions)
* ETL Pipelines
* Data Cleaning & Transformation
* Incremental Load (MERGE)
* SSIS Data Flows

---
## License
This project is for educational purposes. Feel free to use and adapt the dataset for learning.
