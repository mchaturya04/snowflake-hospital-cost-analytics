# 🏥 Hospital Cost Analytics — Medicare Billing Intelligence Platform

A production-style data engineering project built on **Snowflake + dbt**, analyzing
Medicare inpatient hospital billing data from the Centers for Medicare & Medicaid Services (CMS).

---

## Project Summary

Hospitals bill Medicare at wildly different rates — often 5–10x what Medicare actually pays.
This project builds a full analytical pipeline to quantify that gap across every hospital,
state, and diagnosis type in the United States using publicly available CMS data.

**Key finding:** Nationally, hospitals bill an average of **$96,366** per episode while
Medicare pays only **$15,782** — a billing-to-paid ratio of ~6x. Nevada hospitals are the
most aggressive billers at 11.4x; states vary by over 60%.

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| **Snowflake** | Cloud data warehouse — storage, compute, governance |
| **dbt Cloud** | Data transformation, testing, documentation, lineage |
| **CMS Open Data** | Source data (145,879 rows, 3,000+ US hospitals) |
| **GitHub** | Version control and portfolio showcase |

---

## Architecture

```
CMS Open Data (CSV)
       │
       ▼
┌─────────────────────────────┐
│  HOSPITAL_PROJECT.RAW       │  ← Raw layer: source data, never modified
│  RAW_HOSPITAL_CHARGES       │    Loaded via Snowflake Stage + COPY INTO
└─────────────────────────────┘
       │
       ▼  (dbt staging model)
┌─────────────────────────────┐
│  STAGING                    │  ← Clean column names, derived metrics,
│  stg_hospital__charges      │    data quality filters, NULL guards
└─────────────────────────────┘
       │
       ▼  (dbt mart models)
┌──────────────────────────────────────────────────────┐
│  MARTS                                               │
│  mart_hospital__state_summary    (by US state)       │
│  mart_hospital__provider_summary (by hospital)       │
│  mart_hospital__drg_summary      (by diagnosis type) │
└──────────────────────────────────────────────────────┘
```

---

## dbt Model Layers

### Staging (`models/staging/hospital/`)
| Model | Description |
|-------|-------------|
| `stg_hospital__charges` | Cleaned, renamed view of raw CMS data. Adds `billing_gap` and `billed_to_paid_ratio` derived metrics. |

### Marts (`models/marts/hospital/`)
| Model | Description |
|-------|-------------|
| `mart_hospital__state_summary` | One row per US state. Ranks states by billing aggressiveness. |
| `mart_hospital__provider_summary` | One row per hospital. Categorizes billing behavior (High Outlier / Above Average / Average / Below Average). |
| `mart_hospital__drg_summary` | One row per diagnosis type. Ranks by volume and cost nationally. |

---

## Key Metrics

| Metric | Definition |
|--------|-----------|
| `avg_billed_amount` | What the hospital submitted to Medicare |
| `avg_medicare_payment` | What Medicare actually paid |
| `billing_gap` | Billed − Paid (absolute dollar difference) |
| `billed_to_paid_ratio` | Billed ÷ Paid (how many times over cost the hospital bills) |

---

## Snowflake Features Demonstrated

- **Stages + COPY INTO** for repeatable, idempotent data loading
- **Resource Monitors** for credit spend governance
- **AUTO_SUSPEND warehouses** for cost optimization
- **Role-Based Access Control (RBAC)** — LOADER, TRANSFORMER, BI_READER roles
- **Dynamic Tables** for declarative, auto-refreshing transformation pipelines
- **Streams + Tasks** for CDC (Change Data Capture) pipeline patterns
- **ACCOUNT_USAGE** views for cost monitoring and query profiling

---

## Data Source

Centers for Medicare & Medicaid Services (CMS)
[Medicare Inpatient Hospitals by Provider and Service](https://data.cms.gov/provider-summary-by-type-of-service/medicare-inpatient-hospitals/medicare-inpatient-hospitals-by-provider-and-service)

- **145,879 rows** | **3,000+ hospitals** | **500+ DRG codes**
- Updated annually by CMS
- Publicly available, no license restrictions

---

## Project Setup

### Prerequisites
- Snowflake account (free trial works)
- dbt Cloud account (free Developer plan)
- GitHub account

### Steps
1. Download the CMS dataset CSV from the link above
2. In Snowflake: `CREATE DATABASE HOSPITAL_PROJECT; CREATE SCHEMA RAW;`
3. Load CSV into `HOSPITAL_PROJECT.RAW.RAW_HOSPITAL_CHARGES` via Snowsight UI
4. Connect dbt Cloud to Snowflake (account, warehouse, database, credentials)
5. Connect dbt Cloud to this GitHub repo
6. Run `dbt run` then `dbt test`

---

## Author
Built as a portfolio project to demonstrate core data engineering skills on Snowflake.
