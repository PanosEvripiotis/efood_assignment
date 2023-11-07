

-- Following are the SQL queries I used in Big Query to explore the dataset. Many of those things will be used in the dashboard and the presentation

-- I began the analysis by checking for null values in each column using the 'is null' function like the following

select vertical
from `efood2022-404016.main_assessment.orders` 
where user_id is null

-- In order not to flood the assignment with multiple same queries I will post only the one above, but I actually checked each column name by replacing the 'user_id' in the where clause.
-- As it seems there are no null values in any of the columns so no handling is required.
-- If I had to check more columns or more tables I would have used a different way.

-- Next I checked if there are duplicate orders in the table

select order_id, 
        count(*)
from `efood2022-404016.main_assessment.orders` 
group by 1
order by 2 desc

-- From the query above it is evident that there are no duplicate orders in the table therefore we can continue with the analysis

-- Although the analysis is required specifically for the 'Breakfast' cuisine, I will start with some exploration of the entire dataset (without local stores) to get a better understanding of the data. In a real work scenario that stage might not neccessary but good to do in case time allows. By the way some of the results of the queries below will be graphically visible in the dashboard and the presentation. From now on we will not bother with the local stores since it is an insignificant part of the business and also because we are focusing our analysis on restaurants

-- 1) we will start with the number of orders per different dimensions to understand the distribution

select  user_class_name,
        count(order_id) ttl_orders
from `efood2022-404016.main_assessment.orders`
where vertical <> 'Local Stores'
group by 1

select  city,
        count(order_id) ttl_orders
from `efood2022-404016.main_assessment.orders`
where vertical <> 'Local Stores'
group by 1

select  cuisine,
        count(order_id) ttl_orders
from `efood2022-404016.main_assessment.orders`
where vertical <> 'Local Stores'
group by 1

--As can be seen below and in the context of that assignment, device does not seem to hold any significant value to analyze further because the only significant difference is that quite a few more orders are placed from android devices in comparison to ios and that could simply be attributed to the fact that more people use android phones

select  device,
        count(order_id) ttl_orders
from `efood2022-404016.main_assessment.orders`
where vertical <> 'Local Stores'
group by 1


-- 2) Next we will see the order and amount evolution per day 

select  left(cast(order_timestamp as string), 10) as days,
        count(order_id) ttl_orders,
        round(sum(amount)) ttl_amount
from `efood2022-404016.main_assessment.orders`
where vertical <> 'Local Stores'
group by 1
order by 1 asc

-- 3) Another basic check is the correlation between the three metrics that we have. As we will see below the pearson coefficient is very close to 0 in all cases which does not suggest any clear correlation between the metrics

select corr(amount, delivery_cost), corr(amount, coupon_discount_amount), corr(delivery_cost, coupon_discount_amount)
from `efood2022-404016.main_assessment.orders`


-- 4) The next step is to check the average number of orders, the average amount per order, the total orders and the amount per user broken down by day, city and cuisine

select  user_class_name,
        count(distinct user_id) nr_of_uniq_users,
        round(count(order_id)/count(distinct user_id), 2) avg_orders_per_user,
        round(sum(amount)/count(order_id), 2) avg_amt_per_order,
        round(sum(amount)/count(distinct user_id), 2) avg_amt_per_user,
        count(order_id) ttl_orders,
        round(sum(amount)) as ttl_amount
from `efood2022-404016.main_assessment.orders`
where vertical <> 'Local Stores'
group by 1

select  left(cast(order_timestamp as string), 10) as days,
        count(distinct user_id) nr_of_uniq_users,
        round(count(order_id)/count(distinct user_id), 2) avg_orders_per_user,
        round(sum(amount)/count(order_id), 2) avg_amt_per_order,
        round(sum(amount)/count(distinct user_id), 2) avg_amt_per_user,
        count(order_id) ttl_orders,
        round(sum(amount)) as ttl_amount
from `efood2022-404016.main_assessment.orders`
where vertical <> 'Local Stores'
group by 1

select  city,
        count(distinct user_id) nr_of_uniq_users,
        round(count(order_id)/count(distinct user_id), 2) avg_orders_per_user,
        round(sum(amount)/count(order_id), 2) avg_amt_per_order,
        round(sum(amount)/count(distinct user_id), 2) avg_amt_per_user,
        count(order_id) ttl_orders,
        round(sum(amount)) as ttl_amount
from `efood2022-404016.main_assessment.orders`
where vertical <> 'Local Stores'
group by 1

select  cuisine,
        count(distinct user_id) nr_of_uniq_users,
        round(count(order_id)/count(distinct user_id), 2) avg_orders_per_user,
        round(sum(amount)/count(order_id), 2) avg_amt_per_order,
        round(sum(amount)/count(distinct user_id), 2) avg_amt_per_user,
        count(order_id) ttl_orders,
        round(sum(amount)) as ttl_amount
from `efood2022-404016.main_assessment.orders`
where vertical <> 'Local Stores'
group by 1


-- 5) Next we will check which user classes pay for delivery, use coupons or order with offers

select user_class_name,
        sum(case when delivery_cost > 0 then 1 else 0 end) as nr_of_orders_w_delivery_cost,
        sum(case when coupon_discount_amount > 0 then 1 else 0 end) as nr_of_orders_w_coupon,
        sum(case when order_contains_offer = true then 1 else 0 end) as nr_of_orders_w_offers,
        count(order_id) ttl_orders,
from `efood2022-404016.main_assessment.orders`
where vertical <> 'Local Stores'
group by 1


-- 6) Another important thing to check is the percent of returning customers per cusine and class

with v1 as (
        select user_id,
                'yes' as returning_cust_flag,
                count(*) as nr_of_appearances
        from `efood2022-404016.main_assessment.orders`
        where vertical <> 'Local Stores'
        group by 1        
)
select  user_class_name,
        count(distinct case when returning_cust_flag = 'yes' then a.user_id end) as nr_of_returning,
        count(distinct a.user_id)
from `efood2022-404016.main_assessment.orders` a
left join v1 b on a.user_id = b.user_id and b.nr_of_appearances > 1
where vertical <> 'Local Stores'
group by 1


-- 7) One last check that will help in our main question is to check which classes use coupons and offers

select  user_class_name,
        count(distinct user_id) nr_of_uniq_users,
        round(count(order_id)/count(distinct user_id), 2) avg_orders_per_user,
        round(sum(amount)/count(order_id), 2) avg_amt_per_order,
        round(sum(amount)/count(distinct user_id), 2) avg_amt_per_user,
        count(order_id) ttl_orders,
        sum(case when coupon_discount_amount > 0 then 1 else 0 end) as nr_of_orders_w_coupon,
        sum(case when order_contains_offer = true then 1 else 0 end) as nr_of_orders_w_offers,
        round(sum(amount)) as ttl_amount
from `efood2022-404016.main_assessment.orders`
where cuisine = 'Breakfast'
group by 1

-- We will explore the outcomes and importance of the above queries in the dashboard and the presentation













