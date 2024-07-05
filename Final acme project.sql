select *
from smartphone_cleaned_v2


--(1) DATA CLEANING

--Creating a copy of the table 
Select *
into Smartphone_new
from smartphone_cleaned_v2

--Checking for duplicates and Removing duplicates
With SmartPhoneCTE AS (
Select *,
ROW_NUMBER() OVER(
	PARTITION BY model
	ORDER BY 
	brand_name) row_num
from Smartphone_new 
)
SELECT *
from SmartPhoneCTE
where row_num > 1

--Checking for nulls

 1 --Identify null values
   --Count null values in each columns
SELECT
    SUM(CASE WHEN brand_name IS NULL THEN 1 ELSE 0 END) AS brand_name_nulls,
    SUM(CASE WHEN model IS NULL THEN 1 ELSE 0 END) AS model_nulls,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_nulls,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS rating_nulls,
    SUM(CASE WHEN processor_name IS NULL THEN 1 ELSE 0 END) AS processor_name_nulls,
    SUM(CASE WHEN processor_brand IS NULL THEN 1 ELSE 0 END) AS processor_brand_nulls,
    SUM(CASE WHEN num_cores IS NULL THEN 1 ELSE 0 END) AS num_cores_nulls,
    SUM(CASE WHEN processor_speed IS NULL THEN 1 ELSE 0 END) AS processor_speed_nulls,
    SUM(CASE WHEN battery_capacity IS NULL THEN 1 ELSE 0 END) AS battery_capacity_nulls,
    SUM(CASE WHEN fast_charging IS NULL THEN 1 ELSE 0 END) AS fast_charging_nulls,
    SUM(CASE WHEN ram_capacity IS NULL THEN 1 ELSE 0 END) AS ram_capacity_nulls,
    SUM(CASE WHEN internal_memory IS NULL THEN 1 ELSE 0 END) AS internal_memory_nulls,
    SUM(CASE WHEN refresh_rate IS NULL THEN 1 ELSE 0 END) AS refresh_rate_nulls,
    SUM(CASE WHEN resolution IS NULL THEN 1 ELSE 0 END) AS resolution_nulls,
    SUM(CASE WHEN num_rear_cameras IS NULL THEN 1 ELSE 0 END) AS num_rear_cameras_nulls,
    SUM(CASE WHEN num_front_cameras IS NULL THEN 1 ELSE 0 END) AS num_front_cameras_nulls,
    SUM(CASE WHEN os IS NULL THEN 1 ELSE 0 END) AS os_nulls,
    SUM(CASE WHEN primary_camera_rear IS NULL THEN 1 ELSE 0 END) AS primary_camera_rear_nulls,
    SUM(CASE WHEN primary_camera_front IS NULL THEN 1 ELSE 0 END) AS primary_camera_front_nulls,
    SUM(CASE WHEN extended_memory IS NULL THEN 1 ELSE 0 END) AS extended_memory_nulls,
	SUM(CASE WHEN Uses_5g is null THEN 1 ELSE 0 END) AS uses_5g_nulls,
	SUM(CASE WHEN Ir_blaster is null THEN 1 ELSE 0 END) AS ir_blasters_nulls,
	SUM(CASE WHEN Near_field_comm is null THEN 1 ELSE 0 END) AS nfc_nulls
FROM Smartphone_new

--Dealing with nulls

 --Dealing with nulls in OS columns
 select distinct(brand_name), os
from Smartphone_new
where os is null

--Filling the nulls in the OS column with thier respective Operating system
update Smartphone_new
set os = case when os is null and brand_name != 'apple' then 'android'
		else 'ios'
		end

update Smartphone_new
	set os = case when brand_name = 'apple' and os = 'ios' then 'ios'
	else 'android'
	end

select distinct(os)
from Smartphone_new

select *
from Smartphone_new

--rounding up processor_speed to 2 decimal.place
update Smartphone_new
set processor_speed = ROUND((processor_speed),2)

select *
from Smartphone_new

--Replacing nulls in the primary_front camera with 0 and also the nulls in the num_front_cameras to 0 (they have no front camera)

update Smartphone_new
set primary_camera_front = case when primary_camera_front is null then '0'
								else primary_camera_front
								end
update Smartphone_new
		set num_front_cameras = case when num_front_cameras is null then '0'
								else primary_camera_front
								end
			
---Converting the datatypes of the rear camera and the front camera from 'float' to 'int'
			
update Smartphone_new
set primary_camera_rear = CAST (primary_camera_rear as int)
from Smartphone_new
	
			
update Smartphone_new
set primary_camera_front = CAST (primary_camera_front as int)
from Smartphone_new

select *
from Smartphone_new


-- updating the nulls in the 'rating column' with the average of each brand name

--checking the brand names of the column that has nulls in their rating 
select distinct(brand_name), rating
from Smartphone_new
where rating is null

--finding the average of each brand_name
select distinct(brand_name), round(AVG(rating),0) as avg_rating
from Smartphone_new
group by brand_name

-- Creating a temporary table to store the average of every brand names and updating the table			  
WITH CTE_AVG_RATING AS (
    SELECT 
        brand_name, 
        AVG(rating) AS avg_rating
    FROM 
        Smartphone_new
    WHERE 
        rating is not null
    GROUP BY 
        brand_name
)
UPDATE Smartphone_new
SET rating = CASE 
                WHEN rating IS NULL THEN CTE.avg_rating
                ELSE rating
             END
FROM Smartphone_new AS smart
JOIN CTE_AVG_RATING AS CTE
ON smart.brand_name = CTE.brand_name

select *
from Smartphone_new

--filling the nulls in the 'processor_brand and Processor_name' with 'unknown' and the 'processor_speed with '0'
update Smartphone_new
set processor_brand = case when processor_brand is null then 'unknown'
						else processor_brand
						end,
	 processor_name = case when processor_brand is null then 'unknown'
					else processor_name
					end,
	processor_speed = case when processor_speed is null then '0'
					else processor_speed
					end,
	num_cores = case when num_cores is null then 'unknown'
				else num_cores
				end,
	battery_capacity = case when battery_capacity is null then ' '
						else battery_capacity
						end,
	internal_memory = case when internal_memory is null then ' '
					else internal_memory
					end,
	rating = case when rating is null then ' '
			else rating
			end

--replacing the '1' and '0' in the 'has 5g', 'has_nfc', and 'has_ir_blaster' columns to 'Y' and 'N' respectively

--Adding new columns to the table to effect the change

Alter table Smartphone_new
add Uses_5g varchar,
	Ir_blaster varchar,
	Near_field_comm varchar

update Smartphone_new
set Uses_5g = case when has_5g = '1' then 'Y'
			else 'N'
			end,
		Ir_blaster = case when has_ir_blaster = '1' then 'Y'
					else 'N'
					end,
		Near_field_comm = case when has_nfc = '1' then 'Y'
						else 'N'
						end


--Deleting old columns that contained '0' and '1'

alter table Smartphone_new
drop column has_5g,
			has_ir_blaster,
			has_nfc

select MAX(fast_charging) as max_charging, 
		MIN(fast_charging) as min_charging
from Smartphone_new


					--ANALYSIS

--(1). Top 10 brand_names by average rating

Select top 10 (brand_name), round(AVG(rating),0) as AverageRating
from Smartphone_new
group by brand_name
order by AverageRating desc

--(2) Top 20 Average price of phones for each brand

Select top 20 (brand_name), AVG(price) as AveragePrice
from  Smartphone_new
group by brand_name
order by AveragePrice desc

--(3) Top 10 Brand names with the highest number of phones with 5g properties

select top 10 (brand_name), count(Uses_5g) as count_of_5g
from Smartphone_new
where Uses_5g = 'Y'
group by brand_name
order by count_of_5g desc

--(4) What is the most common processor brand

Select top 1(processor_brand), COUNT(*) AS count_of_brand
from Smartphone_new
group by processor_brand
order by count_of_brand DESC

--(5) How many mobile phones runs on android 

Select count(model) as count_of_phones, os
from Smartphone_new
where os = 'android'
group by os

--(6) Find smartphones with a refresh rate of at least 120 Hz and a ram capacity of 8 GB or more.

Select model, refresh_rate, ram_capacity
From Smartphone_new
Where refresh_rate >= 120 AND ram_capacity >= 8;

-- (7) Total number of smartphones per brand

select brand_name, COUNT(model) AS num_of_models
from Smartphone_new
group by brand_name
order by num_of_models desc

--(8) The phone with the fastest processor_speed

Select model, processor_speed 
From Smartphone_new
order by processor_speed desc

--(9) Brands that have the highest number of phones with rear camera greater than 3

Select brand_name, count(model) as count_of_model
from Smartphone_new
where num_rear_cameras > 3
group by brand_name
order by count_of_model desc

--(10) Brands with the highest number of mobile phones that does not have Ir blaster but has Near field communication property

Select brand_name, count(brand_name) as num_of_brand
from Smartphone_new
where Ir_blaster = 'N' and Near_field_comm = 'Y'
group by brand_name
order by num_of_brand desc

-- (11) Checking to see the top 5 brands with the fastest charging rate

select top 5 brand_name, MAX(fast_charging) as Fastest_charging_brand
from Smartphone_new
group by brand_name
order by Fastest_charging_brand desc

--(12) checking for processor brand that supports extended memory up to 1TB and has processor_speed greater than or equal to 2.5

select processor_brand, count(processor_brand) as num_of_pro_brands
from Smartphone_new
where processor_speed > 2.5 and extended_memory >= '1TB'
group by processor_brand
order by num_of_pro_brands desc

--(13) Checking for brands with battery capacity greater than '5500' and has fast charging < '200'

select brand_name, count(battery_capacity) as count_of_brands
from Smartphone_new
where fast_charging < 200 and battery_capacity > 5500
group by brand_name
order by count_of_brands desc







