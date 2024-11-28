-- netflix database 
-- to find varchar length use max(length) function in excel
create table netflix(
    show_id         VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
select count(*) 
from netflix


-- Count the Number of Movies vs TV Shows

select 
type,
count(*) 
from netflix 
group by 1

-- List All Movies Released in a Specific Year (e.g., 2020)

SELECT * --count(*) as mov_2020
FROM netflix
WHERE 
     type ='Movie'
     and
     release_year = 2020 

-- Find the Most Common Rating for Movies and TV Shows
 WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


/* Step 1: Count Ratings per Type
sql
Copy code
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
)
What it does:

This creates a temporary table (RatingCounts) that counts the number of occurrences of each rating for each type (Movies and TV Shows).
COUNT(*) calculates the total occurrences for a combination of type and rating.
GROUP BY type, rating ensures that the count is calculated for each unique combination of type and rating.
Result: A table showing:

lua
Copy code
type       | rating       | rating_count
----------------------------------------
Movies     | PG-13        | 50
Movies     | R            | 30
TV Shows   | TV-MA        | 60
TV Shows   | TV-14        | 40
Step 2: Rank Ratings by Popularity
sql
Copy code
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
What it does:

This creates a second temporary table (RankedRatings) by ranking the ratings for each type (Movies and TV Shows) based on their rating_count, from highest to lowest.
The RANK() function assigns a ranking to each rating within its type group.
PARTITION BY type ensures that rankings are calculated separately for each type (e.g., Movies and TV Shows).
ORDER BY rating_count DESC sorts the counts in descending order so that the most frequent rating gets rank 1.
Result: A table showing:

lua
Copy code
type       | rating       | rating_count | rank
-----------------------------------------------
Movies     | PG-13        | 50           | 1
Movies     | R            | 30           | 2
TV Shows   | TV-MA        | 60           | 1
TV Shows   | TV-14        | 40           | 2
Step 3: Select Most Frequent Rating
sql
Copy code
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;
What it does:

Filters the RankedRatings table to include only rows where rank = 1, i.e., the most frequent rating for each type.
Renames the rating column to most_frequent_rating for better clarity.
Result: A table showing:

markdown
Copy code
type       | most_frequent_rating
---------------------------------
Movies     | PG-13
TV Shows   | TV-MA 
*/


--


 -- Find the Top 5 Countries with the Most Content on Netflix
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;


-- Identify the Longest Movie
SELECT 
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;

-- find the content added in the last 5 years 
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


-- Find All Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';

-- List All TV Shows with More Than 5 Seasons

select *
from netflix 
where type = 'TV Show'
  and SPLIT_PART(duration,' ',1)::INT > 5;
/* SPLIT PART TAKES THE COLUMN NAME , THE DELIMETER ON THE BASIS YOU WANNA SEPERATE FOR ,
AND THEN YOU HAVE TO SPECIY WHICH PART YOU WANT TO HAVE AFTER DELIMETER 1,2,3,4.. */

-- Count the Number of Content Items in Each Genre
select 
UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
count(*) as total_content
from netflix 
group by 1


-- Find each year and the average numbers of content release in India on netflix.
--return top 5 year with highest avg content release!

SELECT 
	EXTRACT(YEAR from TO_DATE(date_added, 'Month DD, YYYY')) AS years,
	count(*)
from netflix 
where country = 'India'
group by 1
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS years,
    COUNT(*) / COUNT(DISTINCT EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY'))) AS avg_content_release
FROM netflix
WHERE country = 'India'
GROUP BY EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY'))
ORDER BY avg_content_release DESC
LIMIT 5;


-- Find All Content Without a Director
SELECT * 
FROM netflix
WHERE director IS NULL;

 -- Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT * 
FROM netflix
WHERE casts ILIKE '%Salman Khan%' 
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


--  Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;


-- Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
