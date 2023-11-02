# OakNorth DBT Home Test

## The challenge
Task: https://github.com/oaknorthbank/dbt-home-test

## How to run
1. Install dbt and set up your dbt environment (use folder 'dbt_oaknorth')
2. Run the dbt project:
```bash
dbt seed # load source data into your database (configuration and tests are in file 'dbt_oaknorth/seeds/properties.yml')
dbt run  # generate the models
dbt test # test the models ('dbt_oaknorth/seeds/properties.yml' and 'test/transactions.sql')
```
## Model 1
[/dbt_oaknorth/models/mart__customers.sql](/dbt_oaknorth/models/mart__customers.sql)

Model that consolidates relevant customer information with their transactions:
- <ins>amount_total</ins>: total transactions made by each customer
- <ins>amount_average_month</ins>: their average monthly spending (number of months between first and last transaction; maybe this is a topic for discussion.)
- <ins>spending_interval_avg</ins>: the average customer spending interval, representing the average number of days it takes for the customer to perform a transaction

| customer_id| customer_name| customer_joined_date| amount_total| amount_average_month| months_payed| months_between_first_last_transaction| spending_interval_avg |
| --- | --- |  --- |  --- |  --- |  --- |  --- |  --- |
| CUST_001| John Doe| 2020-06-25| 567.7| 113.54| 5| 5| 23.6 |
| CUST_002| Jane Smith| 2019-12-10| 392.35| 98.09| 4| 4| 25.75 |
| CUST_003| Michael Johnson| 2022-02-14| 493.15| 164.38| 3| 3| 26.33 |
| CUST_004| Sarah Lee| 2021-05-30| 596.1| 119.22| 4| 5| 32.75 |
| CUST_005| Robert Williams| 2023-01-22| 395.5| 98.88| 3| 4| 33.33 |
| CUST_006| Emily Brown| null| 512.6| 102.52| 5| 5| 26.2 |
| CUST_007| William Jones| 2018-09-12| 321.05| 64.21| 4| 5| 34.0 |
| CUST_008| Olivia Garcia| 2017-07-05| 396.6| 99.15| 3| 4| 36.0 |
| CUST_009| Liam Martinez| 2019-03-28| 375.35| 93.84| 4| 4| 27.0 |
| CUST_010| Ava Rodriguez| 2022-09-17| 497| 124.25| 4| 4| 26.0 |

* CUST_011 is not calculated, because it is not in the source table 'customers' (inconsistent data). Maybe this is a topic for discussion.





## Model 2
dbt_oaknorth/models/mart__last_12_months.sql:

Model that calculates the total transaction amount for each month over the last 12 months
- <ins>percent_change_amount</ins>: the percentage change in transaction totals from one month to the next
- <ins>top_customer_id</ins>: calculate the top customer for each month by selecting the customer with the highest spending

| month | amount | amount_previous_month | percent_change_amount | top_customer_id | top_customer_name | top_customer_joined_date | top_customer_amount | 
| --- | --- |  --- |  --- |  --- |  --- |  --- |  --- |
| 2022-12 | 0 | null | null | null | null | null | null | 
| 2023-01 | 0 | null | null | null | null | null | null | 
| 2023-02 | 0 | null | null | null | null | null | null | 
| 2023-03 | 0 | null | null | null | null | null | null | 
| 2023-04 | 0 | null | null | null | null | null | null | 
| 2023-05 | 0 | null | null | null | null | null | null | 
| 2023-06 | 0 | null | null | null | null | null | null | 
| 2023-07 | 1319.1 | null | null | CUST_010 | Ava Rodriguez | 2022-09-17 | 300.5 | 
| 2023-08 | 1029.35 | 1319.1 | -28.15 | CUST_004 | Sarah Lee | 2021-05-30 | 225.8 | 
| 2023-09 | 758.95 | 1029.35 | -35.63 | CUST_008 | Olivia Garcia | 2017-07-05 | 150.6 | 
| 2023-10 | 1013.9 | 758.95 | 25.15 | CUST_003 | Michael Johnson | 2022-02-14 | 321.55 | 
| 2023-11 | 426.1 | 1013.9 | -137.95 | CUST_006 | Emily Brown | null | 220.8