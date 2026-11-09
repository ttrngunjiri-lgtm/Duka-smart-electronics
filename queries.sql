---Questions

--1.Retrieve all customer records.
select *from customers;

--2.Display customer names, cities, and segments.
select c.customer_name,c.city,c.customer_segment from customers c;

--3.Find customers living in Nairobi.
select*from customers c
where city = 'Nairobi';

--4.Find customers registered after January 1, 2025.
select * from customers c 
where customer_name >'2025-01-01';

--5.Display all unique customer cities.
select c.city from customers c ;

--6.Retrieve the 10 most recent orders.
select * from orders
order by order_date desc
limit 10;

--7.Find orders with unit prices above KSh 10,000.
select * from orders
where unit_price > 10000;

--8.Find customers whose names start with A.
select * from customers 
where customer_name = 'A'
--9.Retrieve orders with quantities between 2 and 5.

select* from orders
where quantity between 2 and 4;

--10.Find orders paid through M-Pesa.
select* from orders
where payment_method = 'M-Pesa';

--11.Count all customers.
select count(customer_name) as all_customers from customers;

--12.Count all orders.
select count(quantity) as all_orders from orders;

--13.Calculate completed-order revenue.
select sum(unit_price) as completed_orders from orders o
where order_status = 'Completed';


--14.Calculate the average completed-order value.
select avg(unit_price) as average_completed_orders from orders 
where order_status = 'Completed';

--15.Find the highest and lowest product prices.
select max(cost_price) from orders;
select min(cost_price) from orders;

--16.Calculate revenue by product category.
select product_category, sum(quantity*unit_price) as total_revunue
from orders
group by product_category
order by total_revunue;

--17.Count customers by city.
select city, count(customer_name)as total_customers from customers
group by city 
order by total_customers;

--18.Calculate quantity sold by product.
select product_name, sum(quantity) as total_quantity from orders 
group by product_name
order by total_quantity;

--19.Find categories generating more than KSh 100,000 in revenue.
select product_category, sum(quantity*unit_price) as total_revunue from orders
group by product_category
having sum(quantity*cost_price)>100000
order by total_revunue;


--20.Calculate the percentage of cancelled orders
select count(distinct order_status= 'Cancelled')*100.00
from orders;

--21.Display orders with customer names and cities.
select orders.order_id,customers.customer_name,customers.city 
from orders
inner join customers 
on orders.customer_id = customers.customer_id;

--22.Calculate total spending by customer.
select customers.customer_id, customers.customer_name, sum(quantity*unit_price) total_spending from customers
inner join orders
on customers.customer_id = orders.customer_id 
group by customers.customer_id;

--23.Identify customers who have never ordered.
select customer_id from customers
except
select customer_id from orders;

--24.Find the 10 highest-spending customers.
select customers.customer_id,customers.customer_name, sum(quantity *unit_price) total_spending from customers
inner join orders 
on customers.customer_id = orders.customer_id
group by customers.customer_id,customers.customer_name
order by customers.customer_name 
limit 10;

--25.Calculate revenue by customer city.
select customers.customer_id,customers.city,sum(quantity*unit_price)total_spending from customers
inner join orders 
on customers.customer_id = orders.customer_id
group by customers.customer_id;

--26.Identify customers with more than five orders.
select customers.customer_id, customers.customer_name,count(quantity) total_order from customers 
inner join orders
on customers.customer_id = orders.customer_id
group by customers.customer_id,customers.customer_name
having count(quantity)> 5
order by total_order;

--27.Calculate average customer spending by segment.
select customers.customer_id, customers.customer_name, customers.customer_segment, avg(quantity*unit_price) as average_spending from customers 
inner join orders 
on customers.customer_id = orders.customer_id
group by customers.customer_id,customers.customer_name,customers.customer_segment
order by average_spending;

--28.Identify the most popular category among VIP customers.
select customers.customer_id,orders.product_category,customers.customer_segment,count(quantity) total_quantity from customers 
inner join orders
on customers.customer_id =orders.customer_id
where customers.customer_segment = 'VIP'
group by customers.customer_id,orders.product_category
order by total_quantity desc;

--29.Find customers spending above the average total spending per purchasing customer.
select customers.customer_id,customers.customer_name,sum(quantity*unit_price) customer_spending from customers
inner join orders 
on customers.customer_id = orders.customer_id 
group by customers.customer_id,customers.customer_name
having sum(quantity*unit_price)> avg(quantity*unit_price)
order by customer_spending desc;

--30.Find products priced above the overall average unit price.
select product_name, unit_price from orders 
where unit_price > (select avg(unit_price) from orders)
order by unit_price;

--31.Use a CTE to identify the three highest-revenue months.
with monthly_revenue as(select date_trunc('month',order_date)as month,sum(quantity*unit_price)as total_revenue from orders
group by date_trunc('month',order_date))
select month,total_revenue from monthly_revenue
order by total_revenue desc
limit 3;

--32.Find customers purchasing from at least three categories.
select customers.customer_id,customers.customer_name,count(distinct product_category)as category_count from customers
inner join orders 
on customers.customer_id = orders.customer_id
group by customers.customer_id, customers.customer_name
having count(distinct orders.product_category)>=3
order by category_count desc;


--33.Use a CTE to calculate category revenue, cost, profit, and profit margin.
with category_profitability as(select product_category,sum(quantity*unit_price )as total_revenue,sum(quantity*cost_price) as total_cost,sum(quantity*unit_price)-sum(quantity*cost_price) as total_profit
from orders
group by product_category)
select product_category,
total_revenue,
total_profit,
round((total_profit/nullif(total_revenue,0))*100,2)as profit_margin_percentage
from category_profitability
order by total_profit desc; 

--34.Find customers whose latest completed order is more than 90 days before the latest order date in the dataset.
with latest_dataset_order as(select max(order_date)as latest_order_date
from orders),
customer_latest_completed as(select customer_id,max(order_date)as latest_completed_order
from orders
where order_status = 'Completed'
group by customer_id)
select customers.customer_id, customers.customer_name,customer_latest_complete.latest_completed_order,
latest_dataset_orser.latest_order_date
from customer_latest_completed 
inner join customer_latest_completed
on customers.customer_id = customers_latest_completed.customer_id
cross join latest_dataset_order 
where customer_latest_completed.latest_completed_order < latest_dataset_order.latest_order_date - interval '90days'
order by customer_latest_completed.latest_completed_order;

--35.Rank customers by spending using RANK().
with customer_spending as (select customers.customer_id,customers.customer_name
,sum(orders.quantity*orders.cost_price) as total_spending
from customers
inner join orders
on customers.customer_id=orders.customer_id
group by customers.customer_id,customers.customer_name)
select customer_id,customer_name,total_spending,rank()over(order by total_spending desc) as spending_rank from customer_spending 
order by spending_rank;

--36Number each customer's orders by recency using ROW_NUMBER().
select customer_id,order_id,order_date,row_number() OVER(partition by customer_id
order by order_date desc)as order_recency from orders
order by customer_id, order_recency;

--37.Rank products within categories using DENSE_RANK().
with product_revenue as(
select product_name,product_category,sum(quantity*unit_price) as total_revenue from orders
group by product_name, product_category)
select(product_name,product_category,total_revenue,dense_rank()over(
partition by product_category
order by total_revenue desc)as product_rank 
from product_revenue
order by product category, product_rank;

--38.Calculate cumulative monthly revenue.
with monthly_revenue as (select date_trunc('month',order_date) as month,sum(quantity*unit_price) as total_revenue from orders
group by date_trunc('month',order_date))
select month,total_revenue,sum(total_revenue) over(order by month rows between unbounded preceding and current row) as cumulative_revenue
from monthly_revenue 
order by month;

--39.Compare monthly revenue using LAG().
with monthly_revenue as(
select date_trunc('month',order_date) as month,sum(quantity*unit_price) as total_revenue from orders
group by date_trunc('month',order_date))
select month,total_revenue,lag(total_revenue)over(order by month)as previous_month_revenue,
total_revenue - lag(total_revenue) over(order by month) as revenue_difference
from monthly_revenue
order by month; 

--40.Calculate month-over-month revenue growth (%).
with monthly_revenue as ( select date_trunc('month',order_date) as month,sum(quantity*unit_price)as total_revenue from orders
group by date_trunc('month',order_date)),
revenue_comparison as(select month,total_revenue,lag(total_revenue)over(order by month)as previous_month_revenue from monthly_revenue)
select month,total_revenue,previous_month_revenue,round(((total_revenue-previous_month_revenue)/nullif(previous_month_revenue,0))*100,2)as monthly_growth_percentage
from revenue_comparison 
order by month;

--41.Divide customers into four spending groups using NTILE(4).
with customer_spending as(select customers.customer_id,customers.customer_name,sum(quantity*cost_price)as total_spending from customers
inner join orders
on customers.customer_id = orders.customer_id
group by customers.customer_id,customers.customer_name)
select customer_id,customer_name,total_spending,ntile(4)over(order by total_spending desc)as spending_group
from customer_spending
order by spending_group,total_spending desc;


--42.Calculate each category's share of total revenue using window functions.
with category_revenue as(
select product_category,sum(quantity*unit_price)total_revenue
from orders 
group by product_category)
select product_category,total_revenue,round((total_revenue*100.0)/sum(total_revenue)over(),2)as revenue_share_percentage
from category_revenue 
order by revenue_share_percentage desc;

--43.Create a monthly_sales_summary view (month, orders, revenue, cost, profit), then select from it.
create view monthly_sales_summary as select date_trunc('month',order_date) as month,
count(distinct quantity)as orders,
sum(quantity*unit_price) as revenue,
sum(quantity*cost_price) as cost,
sum(quantity*unit_price)- sum(quantity*cost_price)as profit
from orders
group by date_trunc('month',order_date);

--44.Create a PL/pgSQL function that returns completed-order revenue for a supplied customer ID — show it for one customer and for an ID that does not exist (it must return 0).
create or replace function get_customer_revenue(p_customer_id int)
returns numeric
language plpgsql
as $$
declare customer_revenue numeric;
begin 
	select coalesce(sum(quantity*unit_price),0)
	into customer_revenue
	from orders
	where customer_id = p_customer_id
	and order_status ='Completed';
return customer_revenue;
end;
$$;

--45.Segment customers into High, Medium and Low Value, and explain why you chose your thresholds.
with customer_spending as(select customers.customer_id,customer_name,sum(quantity*unit_price)as total_spending
from customers  
inner join orders on customers.customer_id= orders.customer_id 
group by customers.customer_id, customers.customer_name),
customer_thresholds as(select*,(select percentile_cont(0.33) within group(order by total_spending) from customer_spending)as low_threshold,
(select percentile_cont(0.67) within group(order by total_spending) from customer_spending) as high_threshold from customer_spending)
select customer_id,customer_name,total_spending,
case
	when total_spending>= high_threshold then 'high value'
	when total_spending>= low_threshold then'medium value'
	else 'low value'
end
as customer_segment
from customer_thresholds
order by total_spending desc;

--This segments are based on customers spending based on %.


--46.Produce a management report: top five customers, top five products, the most profitable category, and the lowest-revenue month.
with customer_revenue as (
select customers.customer_id,customers.customer_name,sum(quantity*unit_price)as revenue
from customers
inner join orders
on customers.customer_id = orders.customer_id
group by customers.customer_id , customers.customer_name
),
top_customers as(select'top customer' as report_section, customer_name as item,revenue as amount from customer_revenue
order by revenue desc limit 5),
product_revenue as (select product_name, sum(quantity*unit_price) as revenue
from orders
group by product_name),
top_products as (select 'top product'as report_section,product_name as item,revenue as amount from product_revenue order by revenue desc limit 5),
category_profit as(select product_category,sum(quantity*unit_price) - sum(quantity*cost_price) as profit 
from orders
group by product_category),
most_profitable_category as(select 'most _profitable category'as report_section,product_category as item,profit as amount from category_profit order by profit desc limit 1),
lowest_revenue_month as(select'lowest revenue month' as report_section, month::text as item, revenue as amount from monthly_revenue
order by revenue asc limit 1 )
select* from top_customers
union all 
select* from top_products 
union all
select* from most_profitable_category
union all
select* from lowest_revenue_month
order by report_section,amount desc;


--Run EXPLAIN ANALYZE on your slowest query, add an index that helps, and show the before and after.
EXPLAIN ANALYZE
WITH latest_dataset_order AS (
    SELECT MAX(order_date) AS latest_order_date
    FROM orders
),
customer_latest_completed AS (
    SELECT
        customer_id,
        MAX(order_date) AS latest_completed_order
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    clc.latest_completed_order,
    ldo.latest_order_date
FROM customers c
JOIN customer_latest_completed clc
    ON c.customer_id = clc.customer_id
CROSS JOIN latest_dataset_order ldo
WHERE clc.latest_completed_order
    < ldo.latest_order_date - INTERVAL '90 days';
CREATE INDEX idx_completed_customer_date
ON orders (customer_id, order_date DESC)
WHERE order_status = 'Completed';
