-- Retrieve the total number of orders placed.

select count(order_id) from orders;

-- Calculate the total revenue generated from pizza sales.

select round(sum((order_details.quantity * pizzas.price))) from order_details join pizzas
on order_details.pizza_id  = pizzas.pizza_id;

-- Identify the highest-priced pizza.

select pizza_types.name ,pizzas.price from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc
limit 1;


-- Identify the most common pizza size ordered.

select pizzas.size, count(order_details.order_details_id) as order_count from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id 
group by pizzas.size
order by order_count desc
limit 1;


-- List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name, sum(order_details.quantity) as quantities from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name
order by quantities desc
limit 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category, sum(order_details.quantity) from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category;


-- Determine the distribution of orders by hour of the day.

select hour(time), count(order_id) from orders
group by hour(time);


-- Join relevant tables to find the category-wise distribution of pizzas.

select pizza_types.category, count(name) from pizza_types
group by pizza_types.category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(total_quantity)) from 
(select orders.date, sum(order_details.quantity) as total_quantity from orders join order_details 
on orders.order_id = order_details.order_id 
group by orders.date) as order_per_day;


-- Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name, 
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by revenue desc
limit 3;



-- Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,
round(sum(order_details.quantity * pizzas.price) / (select round(sum((order_details.quantity * pizzas.price))) from order_details join pizzas
on order_details.pizza_id  = pizzas.pizza_id)* 100,2) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category
order by revenue desc;


-- Analyze the cumulative revenue generated over time.

select date, 
round(sum(revenue) over(order by date),2) as cum_revenue
from
(select orders.date, 
round(sum(order_details.quantity * pizzas.price),2) as revenue
from order_details join pizzas 
on order_details.pizza_id = pizzas.pizza_id 
join orders 
on orders.order_id = order_details.order_id 
group by orders.date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name, revenue, 
rank() over(partition by category order by revenue desc) as rnk
from
(select pizza_types.category, pizza_types.name, 
round(sum(order_details.quantity * pizzas.price),2) as revenue
from order_details join pizzas 
on order_details.pizza_id = pizzas.pizza_id 
join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.category, pizza_types.name
order by revenue desc) as a;


