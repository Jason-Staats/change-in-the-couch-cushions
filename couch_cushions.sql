-- ============================================
-- CHANGE IN THE COUCH CUSHIONS
-- Physical Activity vs Healthcare Costs
-- Schema: exercise
-- ============================================


-- ============================================
-- STEP 1: CREATE DIMENSION TABLE
-- ============================================

CREATE TABLE dim_state (
    state_id    INT          AUTO_INCREMENT PRIMARY KEY,
    state_name  VARCHAR(50)  NOT NULL,
    state_abbr  CHAR(2)      NOT NULL
);


-- ============================================
-- STEP 2: CREATE FACT TABLES
-- ============================================

CREATE TABLE fact_physical_activity (
    record_id       INT           AUTO_INCREMENT PRIMARY KEY,
    state_id        INT           NOT NULL,
    state_abbr      CHAR(2)       NOT NULL,
    state_name      VARCHAR(50)   NOT NULL,
    year            YEAR          NOT NULL,
    question        VARCHAR(255)  NOT NULL,
    data_value      DECIMAL(5,2),
    stratification  VARCHAR(50),
    FOREIGN KEY (state_id) REFERENCES dim_state(state_id)
);

CREATE TABLE fact_healthcare_cost (
    record_id           INT           AUTO_INCREMENT PRIMARY KEY,
    state_id            INT           NOT NULL,
    state_abbr          CHAR(2)       NOT NULL,
    state_name          VARCHAR(50)   NOT NULL,
    year                YEAR          NOT NULL,
    item                VARCHAR(100)  NOT NULL,
    per_capita_spending DECIMAL(10,2),
    FOREIGN KEY (state_id) REFERENCES dim_state(state_id)
);


-- ============================================
-- STEP 3: CREATE STAGING TABLES
-- All columns TEXT to prevent import errors
-- ============================================

CREATE TABLE stg_cdc (
    YearStart                   TEXT, YearEnd                   TEXT,
    LocationAbbr                TEXT, LocationDesc               TEXT,
    Datasource                  TEXT, Class                      TEXT,
    Topic                       TEXT, Question                   TEXT,
    Data_Value_Unit             TEXT, Data_Value_Type            TEXT,
    Data_Value                  TEXT, Data_Value_Alt             TEXT,
    Data_Value_Footnote_Symbol  TEXT, Data_Value_Footnote        TEXT,
    Low_Confidence_Limit        TEXT, High_Confidence_Limit      TEXT,
    Sample_Size                 TEXT, Total                      TEXT,
    Age                         TEXT, Education                  TEXT,
    Sex                         TEXT, Income                     TEXT,
    Race_Ethnicity              TEXT, GeoLocation                TEXT,
    ClassID                     TEXT, TopicID                    TEXT,
    QuestionID                  TEXT, DataValueTypeID            TEXT,
    LocationID                  TEXT, StratificationCategory1    TEXT,
    Stratification1             TEXT, StratificationCategoryId1  TEXT,
    StratificationID1           TEXT
);

CREATE TABLE stg_cms (
    Code TEXT, Item TEXT, Group_Name TEXT,
    Region_Number TEXT, Region_Name TEXT, State_Name TEXT,
    Y1991 TEXT, Y1992 TEXT, Y1993 TEXT, Y1994 TEXT, Y1995 TEXT,
    Y1996 TEXT, Y1997 TEXT, Y1998 TEXT, Y1999 TEXT, Y2000 TEXT,
    Y2001 TEXT, Y2002 TEXT, Y2003 TEXT, Y2004 TEXT, Y2005 TEXT,
    Y2006 TEXT, Y2007 TEXT, Y2008 TEXT, Y2009 TEXT, Y2010 TEXT,
    Y2011 TEXT, Y2012 TEXT, Y2013 TEXT, Y2014 TEXT, Y2015 TEXT,
    Y2016 TEXT, Y2017 TEXT, Y2018 TEXT, Y2019 TEXT, Y2020 TEXT,
    Average_Annual_Percent_Growth TEXT
);

CREATE TABLE stg_cms_long (
    State_Name          VARCHAR(50),
    Item                VARCHAR(50),
    year                YEAR,
    per_capita_spending DECIMAL(10,2)
);

CREATE TABLE stg_clusters (
    state_abbr      CHAR(2),
    avg_muscle      DECIMAL(5,2),
    avg_no_leisure  DECIMAL(5,2),
    avg_spending    DECIMAL(10,2),
    cluster         INT
);


-- ============================================
-- STEP 4: CREATE dim_clusters
-- ============================================

CREATE TABLE dim_clusters (
    state_id        INT             PRIMARY KEY,
    state_abbr      CHAR(2)         NOT NULL,
    state_name      VARCHAR(50)     NOT NULL,
    avg_muscle      DECIMAL(5,2),
    avg_no_leisure  DECIMAL(5,2),
    avg_spending    DECIMAL(10,2),
    cluster         INT,
    FOREIGN KEY (state_id) REFERENCES dim_state(state_id)
);


-- ============================================
-- STEP 5: POPULATE dim_state
-- 50 states plus DC = 51 rows
-- ============================================

INSERT INTO dim_state (state_name, state_abbr) VALUES
('Alabama','AL'), ('Alaska','AK'), ('Arizona','AZ'), ('Arkansas','AR'),
('California','CA'), ('Colorado','CO'), ('Connecticut','CT'), ('Delaware','DE'),
('Florida','FL'), ('Georgia','GA'), ('Hawaii','HI'), ('Idaho','ID'),
('Illinois','IL'), ('Indiana','IN'), ('Iowa','IA'), ('Kansas','KS'),
('Kentucky','KY'), ('Louisiana','LA'), ('Maine','ME'), ('Maryland','MD'),
('Massachusetts','MA'), ('Michigan','MI'), ('Minnesota','MN'), ('Mississippi','MS'),
('Missouri','MO'), ('Montana','MT'), ('Nebraska','NE'), ('Nevada','NV'),
('New Hampshire','NH'), ('New Jersey','NJ'), ('New Mexico','NM'), ('New York','NY'),
('North Carolina','NC'), ('North Dakota','ND'), ('Ohio','OH'), ('Oklahoma','OK'),
('Oregon','OR'), ('Pennsylvania','PA'), ('Rhode Island','RI'), ('South Carolina','SC'),
('South Dakota','SD'), ('Tennessee','TN'), ('Texas','TX'), ('Utah','UT'),
('Vermont','VT'), ('Virginia','VA'), ('Washington','WA'), ('West Virginia','WV'),
('Wisconsin','WI'), ('Wyoming','WY'), ('District of Columbia','DC');


-- ============================================
-- STEP 6: LOAD RAW DATA INTO STAGING TABLES
-- Update file paths to match your environment
-- ============================================

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Nutrition,_Physical_Activity,_and_Obesity_-_Behavioral_Risk_Factor_Surveillance_System_20260322.csv'
INTO TABLE stg_cdc
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/US_PER_CAPITA20.CSV'
INTO TABLE stg_cms
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/US_PER_CAPITA20_long.csv'
INTO TABLE stg_cms_long
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/state_clusters.csv'
INTO TABLE stg_clusters
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================
-- STEP 7: POPULATE fact_physical_activity
-- Filters to OVR, 2011-2020, two questions
-- NULLIF handles empty strings before DECIMAL cast
-- ============================================

INSERT INTO fact_physical_activity
    (state_id, state_abbr, state_name, year, question, data_value, stratification)
SELECT
    d.state_id,
    d.state_abbr,
    d.state_name,
    CAST(s.YearStart AS UNSIGNED),
    s.Question,
    CAST(NULLIF(s.Data_Value, '') AS DECIMAL(5,2)),
    s.Stratification1
FROM stg_cdc s
JOIN dim_state d ON s.LocationAbbr = d.state_abbr
WHERE s.StratificationCategoryId1 = 'OVR'
  AND s.YearStart BETWEEN '2011' AND '2020'
  AND s.Question IN (
      'Percent of adults who engage in muscle-strengthening activities on 2 or more days a week',
      'Percent of adults who engage in no leisure-time physical activity'
  );


-- ============================================
-- STEP 8: POPULATE fact_healthcare_cost
-- ============================================

INSERT INTO fact_healthcare_cost
    (state_id, state_abbr, state_name, year, item, per_capita_spending)
SELECT
    d.state_id,
    d.state_abbr,
    d.state_name,
    s.year,
    s.Item,
    s.per_capita_spending
FROM stg_cms_long s
INNER JOIN dim_state d ON d.state_name = s.State_Name
ORDER BY s.year, d.state_id;


-- ============================================
-- STEP 9: CLUSTERING AGGREGATION QUERY
-- Export result as activity_healthcare_agg.csv
-- for use in Python clustering pipeline
-- ============================================

SELECT
    p.state_id,
    p.state_abbr,
    h.year,
    p.question,
    p.data_value,
    h.per_capita_spending
FROM fact_physical_activity p
LEFT JOIN fact_healthcare_cost h
ON p.state_abbr = h.state_abbr AND p.year = h.year;


-- ============================================
-- STEP 10: POPULATE dim_clusters
-- Run after Python clustering pipeline
-- and state_clusters.csv is loaded into stg_clusters
-- ============================================

INSERT INTO dim_clusters
    (state_id, state_abbr, state_name, avg_muscle, avg_no_leisure, avg_spending, cluster)
SELECT
    d.state_id,
    d.state_abbr,
    d.state_name,
    s.avg_muscle,
    s.avg_no_leisure,
    s.avg_spending,
    s.cluster
FROM stg_clusters s
JOIN dim_state d ON s.state_abbr = d.state_abbr;


-- ============================================
-- STEP 11: ADD cluster_name TO dim_clusters
-- ============================================

ALTER TABLE dim_clusters ADD COLUMN cluster_name VARCHAR(50);

UPDATE dim_clusters
SET cluster_name = CASE
    WHEN cluster = 0 THEN 'Active but Expensive'
    WHEN cluster = 1 THEN 'National Norm'
    WHEN cluster = 2 THEN 'Inactive but Not Expensive'
END
WHERE state_id > 0;


-- ============================================
-- VALIDATION QUERIES
-- ============================================

-- Row counts
SELECT 'dim_state' AS table_name, COUNT(*) AS row_count FROM dim_state
UNION ALL
SELECT 'fact_physical_activity', COUNT(*) FROM fact_physical_activity
UNION ALL
SELECT 'fact_healthcare_cost', COUNT(*) FROM fact_healthcare_cost
UNION ALL
SELECT 'dim_clusters', COUNT(*) FROM dim_clusters;

-- Distinct states (expect 51)
SELECT 'fact_physical_activity' AS table_name, COUNT(DISTINCT state_id) AS state_count FROM fact_physical_activity
UNION ALL
SELECT 'fact_healthcare_cost', COUNT(DISTINCT state_id) FROM fact_healthcare_cost
UNION ALL
SELECT 'dim_clusters', COUNT(DISTINCT state_id) FROM dim_clusters;

-- Year range (expect 2011-2020)
SELECT 'fact_physical_activity' AS table_name, MIN(year) AS min_year, MAX(year) AS max_year FROM fact_physical_activity
UNION ALL
SELECT 'fact_healthcare_cost', MIN(year), MAX(year) FROM fact_healthcare_cost;

-- NULL checks
SELECT COUNT(*) AS null_data_values FROM fact_physical_activity WHERE data_value IS NULL;
SELECT COUNT(*) AS null_spending_values FROM fact_healthcare_cost WHERE per_capita_spending IS NULL;

-- Identify NULL records
SELECT state_abbr, year, question, data_value
FROM fact_physical_activity
WHERE data_value IS NULL;

-- Distinct questions (expect 2)
SELECT question, COUNT(*) AS row_count FROM fact_physical_activity GROUP BY question;

-- Cluster distribution (expect 3 clusters, 51 states)
SELECT cluster, cluster_name, COUNT(*) AS state_count
FROM dim_clusters
GROUP BY cluster, cluster_name
ORDER BY cluster;

-- state_abbr consistency check (expect 0 rows)
SELECT d.state_name, d.state_abbr, f.state_abbr AS fact_abbr
FROM dim_state d
JOIN fact_healthcare_cost f ON d.state_id = f.state_id
WHERE d.state_abbr != f.state_abbr;
