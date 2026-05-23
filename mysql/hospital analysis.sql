CREATE DATABASE IF NOT EXISTS mimic3
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE mimic3;

SET SESSION sql_mode = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

SHOW VARIABLES LIKE 'local_infile';


USE mimic3;

CREATE TABLE IF NOT EXISTS patients (
    row_id      INT,
    subject_id  INT PRIMARY KEY,
    gender      VARCHAR(5),
    dob         DATETIME,
    dod         DATETIME,
    dod_hosp    DATETIME,
    dod_ssn     DATETIME,
    expire_flag INT
);

-- ADMISSIONS table
CREATE TABLE IF NOT EXISTS admissions (
    row_id                INT,
    subject_id            INT,
    hadm_id               INT PRIMARY KEY,
    admittime             DATETIME,
    dischtime             DATETIME,
    deathtime             DATETIME,
    admission_type        VARCHAR(50),
    admission_location    VARCHAR(100),
    discharge_location    VARCHAR(100),
    insurance             VARCHAR(50),
    language              VARCHAR(20),
    religion              VARCHAR(50),
    marital_status        VARCHAR(50),
    ethnicity             VARCHAR(100),
    edregtime             DATETIME,
    edouttime             DATETIME,
    diagnosis             VARCHAR(255),
    hospital_expire_flag  TINYINT,
    has_chartevents_data  TINYINT
);

-- ICUSTAYS table
CREATE TABLE IF NOT EXISTS icustays (
    row_id          INT,
    subject_id      INT,
    hadm_id         INT,
    icustay_id      INT PRIMARY KEY,
    dbsource        VARCHAR(20),
    first_careunit  VARCHAR(50),
    last_careunit   VARCHAR(50),
    first_wardid    INT,
    last_wardid     INT,
    intime          DATETIME,
    outtime         DATETIME,
    los             DECIMAL(10,4)
);

-- TRANSFERS table
CREATE TABLE IF NOT EXISTS transfers (
    row_id          INT PRIMARY KEY,
    subject_id      INT,
    hadm_id         INT,
    icustay_id      INT,
    dbsource        VARCHAR(20),
    eventtype       VARCHAR(20),
    prev_careunit   VARCHAR(50),
    curr_careunit   VARCHAR(50),
    prev_wardid     INT,
    curr_wardid     INT,
    intime          DATETIME,
    outtime         DATETIME,
    los             DECIMAL(10,4)
);

-- DIAGNOSES_ICD table
CREATE TABLE IF NOT EXISTS diagnoses_icd (
    row_id      INT PRIMARY KEY,
    subject_id  INT,
    hadm_id     INT,
    seq_num     INT,
    icd9_code   VARCHAR(10)
);

-- D_ICD_DIAGNOSES table
CREATE TABLE IF NOT EXISTS d_icd_diagnoses (
    row_id      INT PRIMARY KEY,
    icd9_code   VARCHAR(10),
    short_title VARCHAR(100),
    long_title  VARCHAR(255)
);






LOAD DATA LOCAL INFILE 'E:/MIMIC-3/PATIENTS.csv'
INTO TABLE patients
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
  row_id,
  subject_id,
  gender,
  @dob,
  @dod,
  @dod_hosp,
  @dod_ssn,
  expire_flag
)
SET
  dob      = NULLIF(@dob, ''),
  dod      = NULLIF(@dod, ''),
  dod_hosp = NULLIF(@dod_hosp, ''),
  dod_ssn  = NULLIF(@dod_ssn, '');
  

LOAD DATA LOCAL INFILE 'E:/MIMIC-3/ADMISSIONS.csv'
INTO TABLE admissions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
  row_id,
  subject_id,
  hadm_id,
  @admittime,
  @dischtime,
  @deathtime,
  admission_type,
  admission_location,
  discharge_location,
  insurance,
  language,
  religion,
  marital_status,
  ethnicity,
  @edregtime,
  @edouttime,
  diagnosis,
  hospital_expire_flag,
  has_chartevents_data
)
SET
  admittime = NULLIF(@admittime, ''),
  dischtime = NULLIF(@dischtime, ''),
  deathtime = NULLIF(@deathtime, ''),
  edregtime = NULLIF(@edregtime, ''),
  edouttime = NULLIF(@edouttime, '');
  
  
  LOAD DATA LOCAL INFILE 'E:/MIMIC-3/ICUSTAYS.csv'
INTO TABLE icustays
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
  row_id,
  subject_id,
  hadm_id,
  icustay_id,
  dbsource,
  first_careunit,
  last_careunit,
  first_wardid,
  last_wardid,
  @intime,
  @outtime,
  los
)
SET
  intime  = NULLIF(@intime, ''),
  outtime = NULLIF(@outtime, '');
  
SELECT COUNT(*) FROM icustays;

LOAD DATA LOCAL INFILE 'E:/MIMIC-3/TRANSFERS.csv'
INTO TABLE transfers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
  row_id,
  subject_id,
  hadm_id,
  @icustay_id,
  dbsource,
  eventtype,
  prev_careunit,
  curr_careunit,
  @prev_wardid,
  @curr_wardid,
  @intime,
  @outtime,
  @los
)
SET
  icustay_id = NULLIF(@icustay_id, ''),
  prev_wardid = NULLIF(@prev_wardid, ''),
  curr_wardid = NULLIF(@curr_wardid, ''),
  intime = NULLIF(@intime, ''),
  outtime = NULLIF(@outtime, ''),
  los = NULLIF(@los, '');
  
SELECT COUNT(*) FROM transfers;


LOAD DATA LOCAL INFILE 'E:/MIMIC-3/DIAGNOSES_ICD.csv'
INTO TABLE diagnoses_icd
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


LOAD DATA LOCAL INFILE 'E:/MIMIC-3/D_ICD_DIAGNOSES.csv'
INTO TABLE d_icd_diagnoses
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



USE mimic3;

-- for showing row counts
SELECT 'patients'      AS tbl, COUNT(*) AS n_row FROM patients
UNION ALL
SELECT 'admissions',            COUNT(*)         FROM admissions
UNION ALL
SELECT 'icustays',              COUNT(*)         FROM icustays
UNION ALL
SELECT 'transfers',             COUNT(*)         FROM transfers
UNION ALL
SELECT 'diagnoses_icd',         COUNT(*)         FROM diagnoses_icd
UNION ALL
SELECT 'd_icd_diagnoses',       COUNT(*)         FROM d_icd_diagnoses;

