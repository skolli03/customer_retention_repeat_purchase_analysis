# Customer Retention & Repeat Purchase Analysis

**Instacart Market Basket | SQL (MySQL) + Tableau Public**


![Customers dashboard](images/Customers.png)
![Products dashboard](images/Products.png)

---

## Overview

A business case study on repeat purchasing in online grocery delivery. SQL is used to analyze order behavior, and Tableau presents the findings in two interactive dashboards.

### Business Question

> Which products and customer segments drive repeat purchases, and how can a grocery delivery business retain customers?

---

## Dataset

- **Source:** Instacart Market Basket Analysis (Kaggle)
- **Tables used:** `orders`, `order_products__prior`, `products`, `aisles`, `departments`
- **Full dataset:** about 3.4M orders and 32M order-product rows
- **Scope:** US online grocery orders. The data has no prices or calendar dates, so the analysis focuses on behavior and timing, not revenue.

---

## Data Preparation

- **Sampling:** random 15% of users (seed 42 for reproducibility), done in Python (pandas) before loading into MySQL
- **Sampled by user, not by order,** so each customer's full order history stays intact
- **Prior orders only,** since those are the orders with product-level data
- **Result:** [X] orders, about [X]M order-product rows, 30,931 users
- **Chunked filtering:** the order-product file was filtered 1M rows at a time to keep memory use low
- **Blank values:** missing `days_since_prior_order` values (first orders) were loaded as `NULL`
- **Validation:** row counts checked against the source files, and orphan-row checks run on every join

### Schema


![Schema diagram](images/instacart_schema.png)

---

## Analysis (SQL)

1. **Reorder rate by department:** joins `order_products`, `products`, and `departments`. Metric is `AVG(reordered)`, shown with item volume.
2. **Top reordered products:** reorder rate per product, filtered with `HAVING` to products with more than 500 orders in the sample.
3. **Customer segments:** customers grouped by total orders in the sample, then compared on reorder rate, average basket size, and days between orders.
4. **Ordering rhythm:** order counts by day of week and hour of day.
5. **Basket behavior:** reorder rate by cart position (1-3, 4-10, 11+).

### Customer Segments

| Segment | Orders per customer | Customers |
|---|---|---|
| New | 3-7 | 12,765 |
| Regular | 8-20 | 10,926 |
| Loyal | 21+ | 7,240 |

- Built with CTEs.
- Average basket size is total items divided by distinct orders.
- Days between orders is calculated from the `orders` table only, so large baskets are not over-weighted.

---

## Dashboards (Tableau Public)

**Dashboard 1: Customers**
- Segment comparison with a metric selector (reorder rate, days between orders, basket size)
- Customers by segment
- Orders by day and hour (heatmap)
- Reorder rate by cart position

**Dashboard 2: Products**
- Reorder rate by department
- Top reordered products, with a Top N selector

---

## Key Findings

- Loyal customers reorder **69%** of their items vs. **30%** for New customers, and order every **7.5** days vs. **18.6** days.
- Loyal customers buy **10.2** items per order vs. **9.7** for New customers.
- Orders peak on **Monday** between hours **8 and 13**.
- Items added to the cart first are reordered **67%** of the time vs. **50%** for items added last.
- **Dairy Eggs** has the highest reorder rate (**67%**), and **Personal Care** has the lowest (**32%**).
- The top reordered products are everyday staples, such as **Organic Lactose Free Whole Milk**, **Organic Homogenized Whole Milk**, and **Organic Reduced Fat Omega-3 Milk**.

---

## Recommendations

1. **Protect high-reorder departments.** Prioritize stock, freshness, and delivery quality in departments like **Dairy Eggs**, since they keep customers coming back.
2. **Lead with past staples.** Show customers their previously bought items at the start of the shopping flow, because early cart items have the highest reorder rate.
3. **Move New customers toward Regular.** Use reminders or recommendations tied to a customer's first purchases.
4. **Test promotions where volume is high but reorder rate is low.** **Pantry** is the best candidate.
5. **Plan capacity around peak windows.** Staff and schedule deliveries around **Monday**, **hours 8-13**.

---

## Limitations & Assumptions

- Results come from a 15% random sample of users, not the full dataset.
- The dataset does not define which number is which day. Day 0 is assumed to be Sunday.
- There are no prices or calendar dates, so revenue and seasonality could not be analyzed.
- A customer's first order always has a reorder rate of 0, which lowers the rate for the New segment.
- Segment cutoffs (3-7, 8-20, 21+) are based on the sample's spread (an average of about 15 orders per user).
- Product rankings include only products with more than 500 orders in the sample.
- The "missing" and "other" departments were excluded from the department chart.

---

**Dashboards:** 
https://public.tableau.com/views/products_dashboard_17915738792620/Products?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link

https://public.tableau.com/views/customers_dashboard_17915738503890/Customers?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link

## Tools

- MySQL and MySQL Workbench (schema design, SQL analysis)
- Python / pandas (sampling only)
- Tableau Public (dashboards)


```

The raw Kaggle files and the sampled order files are not included because of file size.

---

## How to Reproduce

1. Download the Instacart Market Basket dataset from Kaggle.
2. Run `python/sample_data.py` (`random_state=42`) to create `orders_sample.csv` and `order_products_sample.csv`.
3. Create the MySQL tables, then load the sampled files plus `products`, `aisles`, and `departments` in full.
4. Add the foreign keys after loading.
5. Run the five queries in `sql/` and export each result as a CSV.
6. Connect each CSV as its own data source in Tableau.

