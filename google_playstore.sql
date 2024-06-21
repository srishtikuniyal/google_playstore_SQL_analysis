select * from playstore;

/*1.You're working as a market analyst for a mobile app development company. Your task is to identify the most promising 
categories(TOP 5) for launching new free apps based on their average ratings.*/
select category, round(avg(rating),2) as avg_rating
from playstore where type='free'
group by category
order by avg_rating desc limit 5;

 /*2. As a business strategist for a mobile app company, your objective is to pinpoint the three categories that generate the most revenue from paid apps.
This calculation is based on the product of the app price and its number of installations.*/
select category, round(sum(rev),2) as rev from
(
select *, (installs*price) as rev
from playstore where type='paid'
)t
group by category
order by rev desc 
limit 3;

/*3. As a data analyst for a gaming company, you're tasked with calculating the percentage of games within each category. 
This information will help the company understand the distribution of gaming apps across different categories.*/
select *, (cnt/(select count(*) from playstore))*100 as percentage from 
(select category, count(category) as 'cnt' from playstore group by category)s;

/*As a data analyst at a mobile app-focused market research firm, you'll recommend whether 
the company should develop paid or free apps for each category based on the  ratings of that category.*/
with freeapp as 
( select category, round(avg(rating),2) as 'avg_rating_free' from playstore where type ='free'
group by category), 
paidapp as
( select category, round(avg(rating),2) as 'avg_rating_paid' from playstore where type = 'paid'
group by category)
select *, if (avg_rating_free>avg_rating_paid, 'develop free app', 'develop_paid_app') as 'development'
from
( select f.category,f.avg_rating_free, p.avg_rating_paid 
 from freeapp as f inner join paidapp  as p on f.category = p.category
)k;

/* Suppose you're a database administrator, your databases have been hacked  and hackers are changing price of certain apps on the database , its taking long for IT team to 
neutralize the hack , however you as a responsible manager  dont want your data to be changed , do some measure where the changes in price can be recorded as you cant 
stop hackers from making changes creating table.*/

# FOR THE TIME BEING LET US SUPPOSE THAT HACKER IS ONLY CHANGING THE RATING OF THE TABLE DO THAT COMPANY CANNOT REPLY TO THE CLIENT CORRECTLY
#TO WHICH APP TO DEVELOP.
create table rating_change(
		app VARCHAR(255),
        old_rating decimal(10,2),
        new_rating decimal(10,2),
        operation_type varchar(10),
        operation_time timestamp
        );
#current playstore table cannot be harm so make a copy of the table
create table play as 
select * from playstore        

# updates
DELIMITER //
create trigger rating_change_update
after update on play
for each row
begin
	  insert into rating_change (app, old_rating, new_rating, operation_type, operation_time)
      values (new.app, old.rating, new.rating, 'update', current_timestamp);
end;
delimiter //;

set sql_safe_updates = 0;
update play
set rating=0 
where app = 'Infinite Painter';
        
select * from play
where app = 'Infinite Painter';

/* 7. As a data person you are assigned the task to investigate the correlation between 
two numeric factors: app ratings and the quantity of reviews.*/
SET @x = (SELECT ROUND(AVG(rating), 2) FROM playstore);
SET @y = (SELECT ROUND(AVG(reviews), 2) FROM playstore);    

with t as 
(
select  *, round((rat*rat),2) as 'sqrt_x' , round((rev*rev),2) as 'sqrt_y' from
(
select  rating , @x, round((rating- @x),2) as 'rat' , reviews , @y, round((reviews-@y),2) as 'rev'from playstore
)a                                                                                                                        
)
-- select * from  t
select  @numerator := round(sum(rat*rev),2) , @deno_1 := round(sum(sqrt_x),2) , @deno_2:= round(sum(sqrt_y),2) from t ;
select round((@numerator)/(sqrt(@deno_1*@deno_2)),2) as corr_coeff








