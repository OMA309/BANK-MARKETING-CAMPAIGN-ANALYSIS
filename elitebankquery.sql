set SQL_SAFE_UPDATES=0;
-- ---------------------------------------------------------------------
-- check for duplicates
select * 
from bank
GROUP BY age, job,marital,education,balance,housing,loan,contact,day,month,duration,campaign,pdays,previous,poutcome,y
HAVING COUNT(*)>1;

-- -----------------------------------------------------------------------
alter table bank
add column age_group varchar(50) after age;
-- ------------------------------------------------------------------------
update bank
set age_group = 
case 
when age between 18 and 25 then '18-25'
when  age between 26 and 35 then '26-35'
when  age between 36 and 45 then '36-45'
when  age between 46 and 55 then '46-55'
when  age >55 then '60+'
else 'unknown'
end;

-- ------------------------------------------------------------------------
-- checking for missing or null values with store procedure

delimiter //
create procedure null_value_check()
begin
select count(*) `total row`,
sum(case when age is null then 1 else 0 end)age,
sum(case when job is null then 1 else 0 end)job,
sum(case when marital is null then 1 else 0 end)marital,
sum(case when education is null then 1 else 0 end)education,
sum(case when balance is null then 1 else 0 end)balance,
sum(case when housing is null then 1 else 0 end)housing,
sum(case when loan is null then 1 else 0 end)loan,
sum(case when contact is null then 1 else 0 end)contact,
sum(case when day is null then 1 else 0 end)day,
sum(case when month is null then 1 else 0 end)month,
sum(case when duration is null then 1 else 0 end)duration,
sum(case when campaign is null then 1 else 0 end)campaign,
sum(case when pdays is null then 1 else 0 end)pdays,
sum(case when previous is null then 1 else 0 end)previous,
sum(case when poutcome is null then 1 else 0 end)poutcome,
sum(case when y is null then 1 else 0 end)y
from bank;
end//
delimiter ;

call null_value_check(); -- indicate no null values
-- -----------------------------------------------------------------------------------
-- summary of contacts,y, avgcampaign
select contact,count(contact)contact_count, avg(campaign)avgcampaign,
concat(round(sum(case when y='yes' then 1 else 0 end)*100/count(*),2),'%')as subscription_rate
from bank
group by contact ;
-- --------------------------------------------------------------------------------------
-- monthly campaign trends
select month,
count(*)as total_contacts
from bank
group by month
order by field(month,'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec');
-- -------------------------------------------------------------------------------------
-- suscription rate by month
select month,
sum(case when y='yes' then 1 end)as total_subscription,
count(*) as total_contacts,
concat(round(sum(case when y='yes' then 1 else 0 end)*100/count(*),2),'%')as subscription_rate
from bank
group by month
order by 
field(month,'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec');
-- ------------------------------------------------------------------------------------
-- client demographics analysis
select job,
sum(case when y='yes' then 1 end)as total_subscription,
count(*) as total_contacts,
concat(round(sum(case when y='yes' then 1 end)*100/count(*),2),'%')as subscription_rate
from `elite bank group 3`
group by job
order by subscription_rate desc;
-- -----------------------------------------------------------------------------------
-- top 3 job performing categories

select job,
sum(case when y='yes' then 1 end)as total_subscription,
count(*) as total_contacts,
concat(round(sum(case when y='yes' then 1 end)*100/count(*),2),'%')as subscription_rate
from bank
group by job
order by subscription_rate desc
limit 3;

-- -------------------------------------------------------------------------------------

-- bottom 3 performing job categories 
select job,
sum(case when y='yes' then 1 end)as total_subscription,
count(*) as total_contacts,
concat(round(sum(case when y='yes' then 1 end)*100/count(*),2),'%')as subscription_rate
from bank
group by job
order by subscription_rate asc
limit 3;

-- contact duration analysis i.e how contact duration may influence a client's decision to subscribe to a term deposit
-- average contact duration  by suscription status(overrall diff in avg contact duration btw clients who suscribed and those who d

-- -----------------------------------------------------------------------------------------

-- subscription rate by contact duration ranges

select
   case 
       when duration between 0 and 200 
       then'0-200 seconds'
       when duration between 201 and 400 
       then'201-400 seconds'
       when duration between 401 and 600 
       then'401-600 seconds'
       when duration between 601 and 800 
       then'601-800 seconds'
       when duration between 801 and 1000 
       then'801-1000 seconds'
       else '1000+ seconds'
       end as duration_range,
count(*)as total_contacts,
sum(case when y = 'yes' then 1 else 0 end)as total_subscriptions,
concat(round(sum(case when y='yes' then 1 end)*100/count(*),2),'%')as subscription_rate
from bank
group by duration_range
order by duration_range;


-- categorizing job categories based on subscription rate
with job_sub as 
(select
job,count(case when y='yes' then 1 end) as total_subscriptions,
count(*) as total_contacts,
round(count(case when y='yes' then 1 end)*100/count(*), 2) as subscription_rate
from bank
group by job)
select job,total_contacts,
concat(subscription_rate,'%')as sub_rate,
case
when subscription_rate>= 60
then 'high performing'
when subscription_rate between 40 and 59.99
then 'moderately performing'
when subscription_rate between 20 and 39.99
then 'low performing'
else 'very low performing'
end as performance_category
from job_sub
order by subscription_rate desc;
-- ---------------------------------------------------all correct


-- subscrtion rate for age group and education level
select age_group,
education,
count(*)as total_contacts,
sum(case when y = 'yes' then 1 else 0 end)as total_subscriptions,
concat(round(sum(case when y='yes' then 1 end)*100/count(*),2),'%')as subscription_rate
from bank
group by age_group,education
order by age_group,subscription_rate desc;
-- ------------------------------------------------------------------------
-- segments compared to overall subscription rate
select Age_group,
concat(round(sum(case when y='yes' then 1 else 0 end)*100/(select count(*)all_contacts from bank where y = "yes"),2),'%')as subscription_rate
from bank
       group by  Age_group
       order by subscription_rate desc;
       
       
select education,
concat(round(sum(case when y='yes' then 1 else 0 end)*100/(select count(*)all_contacts from bank where y = "yes"),2),'%')as subscription_rate
from bank
       group by  education
       order by subscription_rate desc;
       
-- -------------------- create a view to check for the job nd campign performnce 
create view campaign_performance as 
select job,
count(*)number_contacts,
sum(case when y = 'yes' then 1 else 0 end ) number_subscription,
concat(round(sum(case when y = 'yes' then 1 else 0 end )*100/ count(*),2),'%') subscripton_rate
from bank
group by job;

-- -----------------------------------combining the campaign performance with the bank table-----------------
select b.*,c.number_subscription,c.subscripton_rate
from bank b
left join campaign_performance c 
on b.job = c.job;
-- --------------------------------------- this is the stored proceedure to check for ech job category------
create view get_camp_performance as 
				select count(*)num_job, b.*,c.number_subscription,c.subscripton_rate
                from bank b
                left join campaign_performance c 
                on b.job = c.job
                group by job,marital,education,age_group;
                
-- ----------------------------------------------------------

select
delimiter // 
create procedure get_campaign_status (in jobs text)
begin 
select * from get_camp_performance where job = jobs;
end//
delimiter ; 
-- ------------------calling for each job category--
call  get_campaign_status('unknown');
-- -----------------------------------------------------------
select * from get_camp_performance;

