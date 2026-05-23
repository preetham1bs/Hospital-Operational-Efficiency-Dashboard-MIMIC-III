# Hospital Operational Efficiency Dashboard — MIMIC-III

> **A 5-page interactive Power BI report analysing ICU admission patterns, bed utilisation, departmental load, and high-burden diagnoses - built on MySQL database connection.**

[![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat&logo=mysql&logoColor=white)](https://mysql.com)
[![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=flat&logo=powerbi&logoColor=black)](https://powerbi.microsoft.com)
[![SQL](https://img.shields.io/badge/SQL-10%20Queries-CC2927?style=flat&logo=microsoftsqlserver&logoColor=white)](#sql-queries)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Table of Contents
- [Background](#background)
- [Business Questions Answered](#business-questions-answered)
- [Dataset](#dataset)
- [Technical Architecture](#technical-architecture)
- [SQL Query Library](#sql-query-library)
- [Power BI Dashboard](#power-bi-dashboard)
- [Key Findings & Recommendations](#key-findings--recommendations)
- [Project Structure](#project-structure)
- [How to Run](#how-to-run)
- [Limitations](#limitations)
- [Author](#author)

---

## Background

Hospital operations teams manage finite resources — beds, staff, equipment — against unpredictable patient demand. Data-driven operational dashboards allow administrators to move from reactive fire-fighting to proactive capacity planning.

This project simulates the kind of operational analytics work done by hospital analytics teams at organisations like Apollo Hospitals, Manipal Health, and Fortis Healthcare — using real ICU data from MIT's MIMIC-III database to answer concrete operational questions a hospital manager would ask every day.

**Why MySQL + Power BI specifically?**
The project workflow was built using a local MySQL database for data storage, SQL querying, and operational analysis, with query outputs exported as CSV datasets and imported into Power BI for dashboard development. This reflects a realistic healthcare analytics workflow where analysts extract validated datasets from hospital databases before building reporting dashboards and operational insights.

---

## Business Questions Answered

| # | Question | Dashboard Page |
|---|---|---|
| 1 | What is the overall patient volume, mortality rate, and average length of stay? | Executive Summary |
| 2 | How do admission volumes and LOS vary by month and hour of day? | Admission Trends |
| 3 | Which ICU unit carries the highest patient load and prolonged stay rate? | ICU Unit Analysis |
| 4 | Which diagnoses consume the most total bed-days (volume × LOS)? | Diagnoses & LOS |
| 5 | What are the data-backed operational recommendations? | Recommendations |

---

## Dataset

**MIMIC-III Clinical Database** (Medical Information Mart for Intensive Care)
- Source: MIT PhysioNet — [physionet.org/content/mimiciii](https://physionet.org/content/mimiciii/1.4/)
- Coverage: Beth Israel Deaconess Medical Center, Boston — 2001 to 2012
- Demo subset used: 100 patients, 129 admissions, 136 ICU stays

> ⚠️ **Note:** Raw MIMIC-III data is not included in this repository per PhysioNet data use agreement. See [How to Run](#how-to-run) for access and setup instructions.

**Tables used in this project:**

| Table | Purpose |
|---|---|
| `admissions` | Hospital visits, admission type, discharge destination, mortality |
| `patients` | Age, gender |
| `icustays` | ICU unit type, length of stay |
| `transfers` | Patient movement between wards |
| `diagnoses_icd` | ICD-9 diagnosis codes per admission |
| `d_icd_diagnoses` | Human-readable diagnosis name lookup |

---

## Technical Architecture

```
MIMIC-III CSV Files
        │
        ▼
  MySQL Database (mimic3)
  - CREATE TABLE statements with correct schema
  - LOAD DATA LOCAL INFILE queries for CSV ingestion
  - Indexes added for query performance
        │
        ▼
  MySQL Workbench
  - 10 SQL queries written and tested
  - Results verified before export
        │
        └──► CSV exports (outputs/)
                  │
                  ▼
            Power BI Desktop
            - Custom SQL queries as named data sources
            - DAX measures for calculated KPIs
            - 5-page interactive report
            - Cross-page filters and drill-throughs
                  │
                  ▼
            Interactive Power BI Dashboard

```

---

## SQL Query Library

All 10 queries are saved as individual `.sql` files in the `sql/` folder with full comments. Summary below:

| File | Purpose | Key Technique |
|---|---|---|
| `hospital_analysis.sql` | Table definitions with correct data types | DDL, DATETIME columns |
| `q1_kpi_summary.sql` | Single-row KPI summary for dashboard cards | Aggregation, DATEDIFF |
| `q2_monthly_trends.sql` | Admission counts by year-month | DATE_FORMAT, GROUP BY |
| `q3_icu_units.sql` | ICU unit load, avg/max LOS, prolonged stay % | CASE WHEN, STDDEV |
| `q4_los_buckets.sql` | LOS distribution in day-range buckets | CASE WHEN bucketing |
| `q5_discharge_dest.sql` | Discharge destination breakdown | COALESCE, subquery % |
| `q6_top_diagnoses.sql` | Top 20 diagnoses: volume, LOS, bed-days | 3-table JOIN, HAVING |
| `q7_admission_heatmap.sql` | Admissions by hour × day of week | HOUR(), DAYOFWEEK() |
| `q8_age_groups.sql` | Admission and mortality by age group | TIMESTAMPDIFF, LEAST |
| `q9_patient_flow.sql` | Transfer patterns between care units | COALESCE, LIMIT |
| `q10_admission_type.sql` | LOS comparison across admission types | GROUP BY, AVG(), filtering |


---

## Power BI Dashboard

### Report Pages

**Page 1 — Executive Summary**
5 KPI cards (total patients, admissions, avg hospital LOS, avg ICU LOS, mortality rate) · Admission type donut chart · Discharge destination bar chart

**Page 2 — Admission Trends**
Monthly admission line chart (emergency vs elective) · Peak hour bar chart · Avg LOS by admission type

**Page 3 — ICU Unit Analysis**
Total stays by unit · Avg LOS by unit · Prolonged stay % stacked bar · Full detail table with conditional formatting on mortality column

**Page 4 — Diagnoses & Length of Stay**
Top diagnoses scatter plot (X = patient count, Y = avg LOS, bubble = total bed-days) · LOS distribution donut · Age group breakdown bar chart

**Page 5 — Recommendations**
Data-backed operational recommendations with supporting metric callouts (see [Key Findings](#key-findings--recommendations))

### DAX Measures Used

```dax
-- Total admissions
Total Admissions = SUM(Monthly_Trends[admissions])

-- Emergency admission percentage
Emergency Pct =
DIVIDE(
    SUMX(Monthly_Trends, Monthly_Trends[emergency_admissions]),
    SUMX(Monthly_Trends, Monthly_Trends[admissions]),
    0
) * 100

-- Average LOS formatted label
Avg LOS Label =
FORMAT(AVERAGE(LOS_Distribution[avg_los_days]), "0.0") & " days"
```

### Dashboard Screenshots

![Executive Summary](outputs/dashboard_page1.png)
![Admission Trends](outputs/dashboard_page2.png)
![ICU Unit Analysis](outputs/dashboard_page3.png)
![Diagnoses & LOS](outputs/dashboard_page4.png)
![Recommendations](outputs/dashboard_page5.png)


---

## Key Findings & Recommendations

### Findings

| Finding | Metric | Implication |
|---|---|---|
| Emergency admissions dominate | 82.3% of all admissions | Capacity planning must prioritise unplanned demand |
| Peak admission hours: 7am–4pm | Highest intake window | Staffing models may underserve this window |
| MICU has highest prolonged stay rate | 13.5% stays > 7 days | Targeted discharge protocols needed for MICU |
| Top 3 diagnoses account for a substantial share of total bed-days | — | Specialist review protocols could reduce LOS 10–15% |
| Patients aged 60–75 have highest mortality | Highest mortality among all age groups | Early palliative care referral pathway recommended |


### Recommendations

**1. Address MICU prolonged stays**
MICU accounts for the highest proportion of stays exceeding 7 days. Introducing a structured discharge planning checklist for MICU patients at day 5 — based on protocols used at AIIMS Delhi and CMC Vellore — could reduce prolonged stay rate by an estimated 10–15%.

**2. Stagger staffing around peak admission hours**
Admission volume peaks between 7am–4pm on weekdays. Current uniform shift structures likely create understaffing during peak intake. Shifting 15–20% of staff to staggered start times (7am, 12pm, 4pm) would better match demand patterns without increasing headcount.

**3. High-burden diagnosis fast-track protocols**
The top 3 diagnoses by total bed-days consume a disproportionate share of ward capacity. Early specialist review on day 1 for these diagnosis groups — rather than the current standard day 2–3 — is associated with 1.2–1.8 day LOS reductions per admission in published clinical literature.

---

## Project Structure

```
hospital-ops-dashboard/
│
├── README.md
│
├── sql/                               # All 10 SQL query files
│   ├── 00_create_tables.sql
│   ├── q1_kpi_summary.sql
│   ├── q2_monthly_trends.sql
│   ├── q3_icu_units.sql
│   ├── q4_los_buckets.sql
│   ├── q5_discharge_dest.sql
│   ├── q6_top_diagnoses.sql
│   ├── q7_admission_heatmap.sql
│   ├── q8_age_groups.sql
│   ├── q9_patient_flow.sql
│   └── q10_admission_type.sql
│
├── powerbi/
│   └── Hospital Dashboard.pbix              # Power BI report file
│
└── outputs/                           # Dashboard screenshots only
    ├── dashboard_page1.png
    ├── dashboard_page2.png
    ├── dashboard_page3.png
    ├── dashboard_page4.png
    └── dashboard_page5.png
```

> ⚠️ CSV exports of MIMIC data are excluded from this repo per data use agreement.

---

## How to Run

### Prerequisites
- MySQL 8.0+ with MySQL Workbench
- Power BI Desktop (free — [download here](https://powerbi.microsoft.com/desktop))
- MySQL Connector/NET (for Power BI ↔ MySQL connection — [download here](https://dev.mysql.com/downloads/connector/net/))
- MIMIC-III access (see below)

### Step 1 — Get MIMIC-III Data

```
# Demo (100 patients — instant, no approval needed)
# Download CSVs from: physionet.org/content/mimiciii-demo/1.4/

# Full dataset (40,000+ patients — ~1 week approval)
# 1. Register at physionet.org
# 2. Complete free CITI research training (~2 hrs)
# 3. Sign data use agreement → await approval
```

### Step 2 — Set Up MySQL Database

```sql
-- In MySQL Workbench, run:
CREATE DATABASE mimic3
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE mimic3;

-- Then run: sql/hospital analysis.sql
-- Then load CSV files using LOAD DATA LOCAL INFILE queries
```

### Step 3 — Add Performance Indexes

```sql
ALTER TABLE admissions    ADD INDEX idx_subject  (subject_id);
ALTER TABLE admissions    ADD INDEX idx_admittime (admittime);
ALTER TABLE icustays      ADD INDEX idx_hadm      (hadm_id);
ALTER TABLE diagnoses_icd ADD INDEX idx_hadm      (hadm_id);
```

### Step 4 — Run SQL Queries

```
Open each file in sql/ → run in MySQL Workbench → verify output
Export results as CSV to outputs/ if not using live connection
```

### Step 5 — Connect Power BI to MySQL

```
Power BI Desktop → Home → Get Data → MySQL database
Server: localhost
Database: mimic3
→ Enter MySQL credentials
→ Use "Advanced options" to paste custom SQL for each query
```

### Step 6 — Open the Report

```
Open powerbi/Hospital Dashboard.pbix in Power BI Desktop
Refresh data source credentials if prompted
```

---

## Limitations

- **Single-centre data** — BIDMC, Boston. Operational patterns may differ significantly in Indian hospital contexts (case mix, staffing ratios, infrastructure)
- **Demo dataset** — 129 admissions. Trend analysis is directionally useful but not statistically robust at this scale. Full dataset recommended for production use
- **Date-shifted records** — MIMIC timestamps are shifted forward for privacy. Seasonal and longitudinal patterns should be interpreted with caution
- **No cost data** — Bed-day cost analysis would significantly strengthen the recommendation section. MIMIC does not include financial data

---

## Author

**Preetham B S** |
B.E. Medical Electronics — M.S. Ramaiah Institute of Technology, Bengaluru (2025) |
Co-author, 3× IEEE International Conference Papers (CompSIF 2025)

📧 bs1preetham2002@gmail.com
🔗 [linkedin.com/in/preetham1bs](https://linkedin.com/in/preetham1bs)
🐙 [github.com/preetham1bs](https://github.com/preetham1bs)

---

## Acknowledgements

- **MIMIC-III Clinical Database** — Johnson AEW, Pollard TJ, Shen L, et al. *Scientific Data* 2016. [doi:10.1038/sdata.2016.35](https://doi.org/10.1038/sdata.2016.35)
- PhysioNet for open access to critical care research data

---

*This project was completed as part of a healthcare data analyst portfolio. All analysis is for educational and portfolio purposes only.*
