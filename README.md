# Change in the Couch Cushions

A state-level analysis of physical activity trends and per capita healthcare costs across all 50 US states and DC (2011-2020). Built with MySQL, Python, R, and Power BI. Regression analysis found no statistically significant relationship between activity metrics and spending. K-Means clustering revealed three distinct state profiles.

---

🔗 **Interactive Dashboard:** [View here](https://app.powerbi.com/view?r=eyJrIjoiM2MzNjcyNzYtY2MwNC00ZDdjLWI1MGItYzYxYmMwMWQxZjVlIiwidCI6ImFjZmM5MDhlLTk0YWEtNDVkMi04OWE3LTcwMjg4MmYyMjc4MiJ9&pageName=62f58e62dba9893a6fde)

---

## Dashboard

Built in Power BI Desktop and published to Power BI Service. Four pages:

| Page | Title | Purpose |
|------|-------|---------|
| 1 | Overview | National snapshot: spending map, scatter plots, and KPI cards |
| 2 | Trends Over Time | Line charts showing spending and activity trends 2011-2020 |
| 3 | Unremarkable Results | Regression analysis and correlation findings |
| 4 | Regional Relationships | K-Means clustering of states by activity and spending profile |

---

## Data Sources

| Source | Dataset | Year Range |
|--------|---------|------------|
| CDC | Nutrition, Physical Activity, and Obesity - BRFSS | 2011-2020 |
| CMS | Health Expenditures by State of Residence (US_PER_CAPITA20.CSV) | 2011-2020 |

---

## Schema

Star schema in MySQL with two dimension tables and two fact tables.

- **dim_state** — bridge table resolving CDC abbreviations (AL) and CMS full state names (Alabama)
- **dim_clusters** — K-Means cluster assignments produced by the Python clustering pipeline
- **fact_physical_activity** — one row per state per year per question
- **fact_healthcare_cost** — one row per state per year

---

## Pipeline

1. Create MySQL schema and staging tables
2. Reshape the CMS spending data in Python from year columns into rows
3. Load the CDC source data and the reshaped CMS data into MySQL staging tables using LOAD DATA INFILE
4. Filter and cast the staged data, then populate the fact tables
5. Export the state-level spending and activity averages from MySQL as a CSV
6. Run K-means clustering in Python on the exported averages
7. Load the cluster assignments into stg_clusters, then populate dim_clusters
8. Connect Power BI to MySQL via ODBC and build the dashboard

---

## Key Findings

- Average per capita healthcare spending across the 50 states and D.C. rose from about $7,500 in 2011 to $10,500 in 2020, giving each jurisdiction equal weight and using nominal dollars
- Muscle-strengthening rates increased across the years surveyed. Rates of no leisure-time physical activity fluctuated without a clear trend
- Neither physical activity measure had a statistically significant association with average per capita healthcare spending in separate state-level regressions (muscle strengthening: p = 0.455, R² = 0.011; no leisure-time activity: p = 0.305, R² = 0.021)
- The two activity measures were strongly negatively correlated (r = −0.81, p < 0.001). The separate regressions did not estimate each measure’s association with spending while accounting for the other
- K-means clustering identified three profiles in the saved data: Active but Expensive (14 states and D.C.), National Norm (26 states), and Inactive but Not Expensive (10 states)

---

## Tools Used

| Tool | Purpose |
|------|---------|
| MySQL Workbench | Database design, staging imports, SQL transformation |
| Power BI Desktop | Dashboard development, DAX measures |
| Python (pandas) | Wide-to-long transformation |
| Python (scikit-learn) | K-Means clustering pipeline |
| Python (seaborn) | Cluster centers heatmap |
| R | Linear regression and Pearson correlation |
| PyCharm | Primary Python IDE |
| GitHub | Version control and portfolio hosting |

---

## Data Notes

- CMS data is expressed in nominal dollars and is not inflation adjusted
- The muscle-strengthening question was collected biennially — data exists for odd years only (2011, 2013, 2015, 2017, 2019)
- New Jersey has no reported values for either question in 2019, preserved as NULL
- CDC BRFSS rotating question sets may produce year-to-year variation independent of actual behavior change
