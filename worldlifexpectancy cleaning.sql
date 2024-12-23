SELECT *
FROM world_life_expectancy
;

# I want to check the data for any duplicate values. I am going to use a combination of the "Country" & "Year" columns to make unique values and then use a "count" function on the new unique values I created.
# If there are no duplicate values, the count of each unique value should be 1.

# Creating the unique value column

SELECT Country, Year, concat(Country, Year)
FROM world_life_expectancy
;

# Adding a count to each unique value to ensure there are no duplicates in the data. I have to use a Group By function due to using an aggregation in the select statement

SELECT Country, Year, concat(Country, Year), count(concat(Country, Year)) as value_count
FROM world_life_expectancy
GROUP BY Country, Year, concat(Country, Year)
;

# Now that a number has been assigned to each value, I can filter on any value that has a count greater than 1. This will reveal the duplicated rows in the dataset.

SELECT Country, Year, concat(Country, Year), count(concat(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, concat(Country, Year)
HAVING count(concat(Country, Year)) > 1
;

# Next, I have to remove the duplicates from the data. The dataset has a column called "Row_id" which I can use to filter on the rows that contain duplicate values only.

SELECT *
FROM (
    SELECT Row_ID,
	concat(Country, Year),
	ROW_NUMBER() OVER( PARTITION BY concat(Country, Year) ORDER BY concat(Country, Year)) AS Row_Num
	FROM world_life_expectancy
	) as x
WHERE Row_Num > 1
;

#Now that I have identified the row id's where the duplicate values are located, I will use the "DELETE FROM" Function to remove only the row id's with a Row_Num that is greater than 1

DELETE FROM world_life_expectancy
WHERE
	Row_ID IN (
    SELECT Row_ID
FROM (
    SELECT Row_ID,
	concat(Country, Year),
	ROW_NUMBER() OVER( PARTITION BY concat(Country, Year) ORDER BY concat(Country, Year)) AS Row_Num
	FROM world_life_expectancy
	) as x
WHERE Row_Num > 1
)
;

# Now that the duplicate values have been removed, I want to check to see if there are any missing values that can be intuitively filled in.

SELECT *
FROM world_life_expectancy
;

# I noticed that the "Status" column has missing values in some rows for countries that have the data available already in other rows. I want to fill those missing values in if appropriate

SELECT *
FROM world_life_expectancy
WHERE Status = ""
;

# I want to check the unique values in the "Status" column that aren't blank. this will help guide me on how I should approach this issue.

SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE Status <> ""
;

# I want to know if using a self join can help fill in the missing values so that I can update the original table

Select t1.Country, t1.Status, t1.Year, t2.Status as Status2, t2.Year
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
WHERE t1.Status = ""
AND t2.Status = "Developing"
;
# I believe that pieces from the query above should guide me in the right direction to solving this missing values issue.

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = "Developing"
WHERE t1.Status = ""
AND t2.Status <> ""
AND t2.Status = "Developing"
;

# The query ran properly and updated 7 rows in the table. I will run another query to check on any rows where there is no value in the "Status" column

SELECT *
FROM world_life_expectancy
WHERE Status = ""
;

# After running the query above, there is still one row in the table that has a missing value in the status column. I see the country in question is the USA.
# This makes sense since I only updated the missing values that the status would have been "Developing." The US is a developed country so I need to run the same query but replace "Developing" with "Developed."alter

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = "Developed"
WHERE t1.Status = ""
AND t2.Status <> ""
AND t2.Status = "Developed"
;

# The query ran successfully and updated 1 row in the table. When I query the table to look for any rows with a missing status, I shouldn't find any now.

SELECT *
FROM world_life_expectancy
WHERE Status = ""
;    # This query returned 0 results which means the update was successful!

# I noticed that there were a few values missing in the Life Expectancy column while looking over the data earlier. I would like to figure out a way to fill in the missing values by potentially using the average
# life expectancy for each country with a missing value.

SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy
;

# This is the logic that I am using to try and solve the missing value issue.

SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1) AS new_values
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ""
;

# Using parts of the Logic above, I need to employ the same technique I used when updating the missing values in the "Status" column and use it to update the Life expectancy column.

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = ""
;

# Check the table to make sure everything updated properly by searching for blank values in the Life Expectancy column

SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy
WHERE `Life expectancy` = ""
;