# Change in the Couch Cushions

A state-level analysis of physical activity trends and per capita healthcare costs across all 50 US states and DC (2011-2020). Built with MySQL, Python, R, and Power BI. Regression analysis found no statistically significant relationship between activity metrics and spending. K-Means clustering revealed three distinct state profiles.

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
2. Load raw CDC and CMS data into staging tables via `LOAD DATA INFILE`
3. Insert into fact tables with filtering and casting
4. Export aggregated query from MySQL as CSV
5. Run Python K-Means clustering pipeline on aggregated data
6. Load cluster assignments back into MySQL as `dim_clusters`
7. Connect to Power BI via ODBC and build dashboard

---

## Key Findings

- National average per capita healthcare spending rose steadily from ~$7,500 in 2011 to ~$10,500 in 2020
- Muscle strengthening rates increased over the decade; no leisure activity rates fluctuated without a clear trend
- Neither activity metric significantly predicts healthcare spending (muscle strengthening: p = 0.455, R² = 0.011; no leisure activity: p = 0.305, R² = 0.021)
- The two activity metrics are strongly negatively correlated with each other (r = -0.81, p < 0.001), making it virtually impossible to differentiate their individual effects on spending
- K-Means clustering (k=3) identified three state profiles: Active but Expensive (8 states), National Norm (33 states), and Inactive but Not Expensive (10 states)

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
