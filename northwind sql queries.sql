-- JOINS
-- orders combined with the customer who placed them
select o.customer_id, c.company
from orders o
inner join customers c
on o.customer_id = c.id;

-- orders combined with the customer who placed them
select c.company
from customers c
left join orders o
on c.id = o.customer_id
where o.id is null;

-- products never ordered
select p.id, p.product_name
from products p
left join order_details od
on p.id = od.product_id
where od.order_id is null;

-- full order line detail
select c.company, p.product_name, round(od.quantity, 2) quantity, round((od.quantity * od.unit_price), 2) total_spent
from customers c
join orders o on o.customer_id = c.id
join order_details od on o.id = od.order_id
join products p on p.id = od.product_id
order by total_spent desc;


-- STRING FUNCTIONS
-- standardized full customer name
select upper(concat(first_name,' ', last_name)) customer_full_name
from customers;

-- two equivalent ways to extract the same 3-character substring from a phone number
select business_phone, substring(business_phone, 2, 3) area_code, right(left(business_phone, 4), 3) area_code_2
from customers;

-- standardize a text pattern within an address field
select address, replace(address, 'Street', 'St.') address_new
from customers
limit 10;

-- detect hidden leading/trailing whitespace
select company, length(company), length(trim(company))
from customers
where length(company) != length(trim(company));


-- DATETIME FUNCTIONS
-- days between order placed and order shipped
select order_date, shipped_date, datediff(shipped_date, order_date) days_between
from orders
where order_date is not null and
shipped_date is not null
order by days_between asc;

-- bucket orders by shipping speed
select order_date, shipped_date, datediff(shipped_date, order_date) shipping_days,
case
when datediff(shipped_date, order_date) < 3 then 'Fast'
when datediff(shipped_date, order_date) between 3 and 5 then 'Standard'
else 'Slow'
end as 'shipping_speed'
from orders
where order_date is not null and
shipped_date is not null
order by shipping_days asc;

-- order volume by period
select year(order_date) order_year, 
month(order_date) order_month,
count(id) total_orders
from orders
group by order_year, order_month
order by total_orders desc;

-- flag orders that went more than 3 days before shipping
select id, datediff (shipped_date, order_date) shipping_days,
case 
when (datediff (shipped_date, order_date)) > 3 then 'should ship within 3 days of order'
else null
end as 'shipping_delay_flag'
from orders
order by shipping_days asc;

select min(order_date), max(order_date) from orders;

select id, order_date, shipped_date, 
datediff (shipped_date, order_date) shipping_days, 
date_add(order_date, interval 3 day) as shipping_deadline,
case 
when shipped_date > date_add(order_date, interval 3 day) then 'Late shipment'
else 'On Time'
end as 'shipping_delay_flag'
from orders
where shipped_date is not null and order_date is not null
order by order_date asc;

-- WINDOW FUNCTIONS
-- rank products by total revenue within category
with product_totals as
(
select p.id, p.product_name, p.category, round(sum(od.quantity * od.unit_price), 2) revenue
from products p 
join order_details od on p.id = od.product_id
group by p.id, p.product_name, p.category
)
select product_name, category, revenue,
dense_rank() over(partition by category order by revenue desc) product_rank_within_category
from product_totals;

-- each customer's most recent order
with customer_info as (
select c.id customer_id, concat(c.first_name, ' ', c.last_name) full_name, p.product_name, o.order_date
from customers c
join orders o on o.customer_id = c.id
join order_details od on o.id = od.order_id
join products p on p.id = od.product_id
)
select *
from (
select full_name, product_name, order_date,
row_number() over(partition by customer_id order by order_date desc) order_recency_rank
from customer_info) ranked
where order_recency_rank = 1;

--  running revenue total by date
with daily_revenue as
(
select o.order_date, round(sum(od.quantity * od.unit_price), 2) daily_total
from orders o 
join order_details od on o.id = od.order_id
group by o.order_date
order by order_date asc
)
select order_date, daily_total, sum(daily_total) over(order by order_date) running_total
from daily_revenue;

-- month-over-month revenue growth
with monthly_totals as (
select year(order_date) order_year, month(order_date) order_month, round(sum((od.quantity*od.unit_price)), 2) monthly_revenue
from orders o
join order_details od
on o.id = od.order_id
where o.order_date is not null
group by order_year, order_month
)
select *, 
lag(monthly_revenue) over(order by order_year, order_month) prev_month_revenue,
round(((monthly_revenue - (lag(monthly_revenue) over(order by order_year, order_month))) / ((lag(monthly_revenue) over(order by order_year, order_month)))) * 100, 1) m_o_m_growth_pct
from monthly_totals;

-- customer spend quartiles, active buyers only
select c.id customer_id, concat(c.first_name, ' ', c.last_name) full_name, 
sum((od.quantity * od.unit_price)) total_spend,
ntile(4) over(order by sum((od.quantity * od.unit_price)) asc) spend_quartile
from customers c
join orders o on c.id = o.customer_id
join order_details od on o.id = od.order_id
group by customer_id, full_name;
;

-- customer spend quartiles, including zero-spend customers
select c.id customer_id, concat(c.first_name, ' ', c.last_name) full_name, 
coalesce(sum(od.quantity * od.unit_price), 0) total_spend,
ntile(4) over(order by coalesce(sum(od.quantity * od.unit_price), 0) asc) spend_quartile
from customers c
left join orders o on c.id = o.customer_id
left join order_details od on o.id = od.order_id
group by c.id, full_name;


-- SUBQUERIES
-- customers spending above the overall average
with customer_total_spend as (
select c.id customer_id, concat(c.first_name, ' ', c.last_name) full_name, 
round(sum((od.quantity * od.unit_price)), 2) total_spend
from customers c
join orders o on c.id = o.customer_id
join order_details od on o.id = od.order_id
group by customer_id, full_name
)
select customer_id, full_name, total_spend
from customer_total_spend
where total_spend > (select avg(total_spend) from customer_total_spend);

-- orders containing the single highest-priced product
select distinct od.order_id
from order_details od
where od.product_id in (
select od.product_id
from order_details od
where od.unit_price = (select max(unit_price) from order_details)
);

