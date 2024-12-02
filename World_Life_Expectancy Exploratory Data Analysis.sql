# Exploratory Data Analysis

# I want to look at the lowest and highest life expectancy values for each country to see how far they have progressed in the last 15 years

SELECT Country, MIN(`Life expectancy`), MAX(`Life expectancy`)
FROM world_life_expectancy
GROUP BY Country
ORDER BY MAX(`Life expectancy`) DESC
;

# I also would like to see which country has had the largest growth in life expectancy over the past 15 years. I will do this by subtracting the MAX Life expectancy column by the MIN Life Expectancy column.
# I will sort the new column called le_growth (Life Expectancy Growth) in descending order which will give me the largest value at the top of the table. 

SELECT Country, 
MIN(`Life expectancy`),
MAX(`Life expectancy`),
Round(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS le_growth 
FROM world_life_expectancy
GROUP BY Country
HAVING Min(`Life expectancy`) <> 0
AND Max(`Life expectancy`) <> 0
ORDER BY le_growth DESC
#LIMIT 10
;

# I want to look at the average life expectancy based on the year. I also want to make sure to exclude any country with a 0 in the life expectancy column.

SELECT Year, 
round(avg(`Life expectancy`),1) as avg_life_exp
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
;

# I want to see if there is any correlation between the avg GDP and avg life expectancy

SELECT Country, Round(AVG(`Life expectancy`),1) as avg_le, Round(AVG(GDP),1) as GDP
FROM world_life_expectancy
GROUP BY Country
HAVING avg_le > 0
AND GDP > 0
ORDER BY GDP ASC
;
# Upon first glance, it appears that there is definitely some correlation between GDP and Life Expectancy. I would need to feed this data into a visualization tool or python to run further analysis.

# I want to try to segment the data into 2 categories. High GDP Countries & Low GDP Countries. 

SELECT
sum(CASE WHEN GDP >= 1200 THEN 1 ELSE 0 END) as High_GDP_Count,
round(AVG(CASE WHEN GDP >= 1200 THEN `Life expectancy` ELSE NULL END),1) as High_GDP_life_expectancy,
sum(CASE WHEN GDP < 1200 THEN 1 ELSE 0 END) as Low_GDP_Count,
round(AVG(CASE WHEN GDP < 1200 THEN `Life expectancy` ELSE NULL END),1) as Low_GDP_life_expectancy
FROM world_life_expectancy
;


# I want to look at the average life expectancy based on the status of every country to see if there is any correlation between a country that is already developed having a higher life expectancy

SELECT Status, COUNT(DISTINCT Country), ROUND(Avg(`Life expectancy`),1) AS avg_LE
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Status
;   # While there is definitely a correlation between country status and life expectancy in this dataset, we can see that there is a large disparity in the sample sizes between the countries that are developed vs developing.
	# You would need better demographic data to receive more accurate results.

# I want to see what effect BMI has on Adult Mortality numbers. Intuition says the higher the BMI, the higher the mortality. I believe sample size will still effect the result but it is interesting to look at regardless.

SELECT Country, ROUND(AVG(`Life expectancy`),1) as avg_LE, ROUND(AVG(BMI),1) as avg_BMI
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
AND BMI <> 0
GROUP BY Country
ORDER BY avg_BMI DESC
; # This is a case where I can immediately recognize that there is something off with the quality of the data in the BMI column. Taking that into consideration, I do believe that you would find that even though developed
  # countries have a higher BMI on average due to factors such as access to food and overall nutrition quality, these populations tend to live longer on average due to having high quality health care and preventitive medicines
  # while countries that are either under developed or are still in the process of developing could have serious limitations to these types of things.
  
  