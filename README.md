![image alt] (https://github.com/najirh/netflix_sql_project/blob/f783ef0fc711ea2d276be1e0656d276578f50a84/logo.png)
# 📊 Netflix Movies and TV Shows Data Analysis using SQL

This project delves into the analysis of Netflix's movie and TV show dataset using SQL. By extracting meaningful insights, we aim to address key business questions and provide a comprehensive understanding of Netflix's content landscape.

---

## 🎯 Objectives

1. Analyze the distribution of content types (Movies vs. TV Shows).
2. Identify the most common ratings for Movies and TV Shows.
3. Explore content based on release years, countries, and durations.
4. Categorize and extract insights from content using specific criteria and keywords.

---

## 📁 Dataset

**Source**: Kaggle Netflix Movies and TV Shows Dataset  
[Click Here to Access the Dataset](https://www.kaggle.com)  

### Dataset Schema
```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix (
    show_id      VARCHAR(5),
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
```

---

## 🛠️ Business Problems and SQL Solutions

### 1. **Count the Number of Movies vs. TV Shows**
```sql
SELECT 
    type,
    COUNT(*) AS total_count
FROM netflix
GROUP BY type;
```
**Objective**: Determine the distribution of content types on Netflix.

---

### 2. **Find the Most Common Ratings for Movies and TV Shows**
```sql
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
```
**Objective**: Identify the most frequently occurring rating for each type of content.

---

### 3. **List All Movies Released in 2020**
```sql
SELECT * 
FROM netflix
WHERE release_year = 2020;
```
**Objective**: Retrieve all movies released in a specific year.

---

### 4. **Find the Top 5 Countries with the Most Content**
```sql
SELECT country, COUNT(*) AS total_content
FROM (
    SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS country
    FROM netflix
) AS split_countries
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;
```
**Objective**: Identify the top 5 countries with the highest number of content items.

---

### 5. **Identify the Longest Movie**
```sql
SELECT * 
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 1;
```
**Objective**: Find the movie with the longest duration.

---

### 6. **Find Content Added in the Last 5 Years**
```sql
SELECT * 
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```
**Objective**: Retrieve content added to Netflix in the last 5 years.

---

### 7. **List All Movies/TV Shows by Director 'Rajiv Chilaka'**
```sql
SELECT * 
FROM (
    SELECT *,
           UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS directors_split
WHERE director_name = 'Rajiv Chilaka';
```
**Objective**: List all content directed by 'Rajiv Chilaka'.

---

### 8. **List All TV Shows with More Than 5 Seasons**
```sql
SELECT * 
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```
**Objective**: Identify TV shows with more than 5 seasons.

---

### 9. **Count the Number of Content Items in Each Genre**
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY genre;
```
**Objective**: Count the number of content items in each genre.

---

### 10. **Top 5 Years with the Highest Average Content Release in India**
```sql
SELECT release_year, 
       COUNT(show_id) AS total_content,
       ROUND(AVG(COUNT(show_id)) OVER (), 2) AS avg_content
FROM netflix
WHERE country = 'India'
GROUP BY release_year
ORDER BY avg_content DESC
LIMIT 5;
```
**Objective**: Calculate and rank years by the average content released in India.

---

### 11. **List All Movies That Are Documentaries**
```sql
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries%';
```
**Objective**: Retrieve all movies classified as documentaries.

---

### 12. **Find All Content Without a Director**
```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```
**Objective**: List content that does not have a director.

---

### 13. **Find Movies Featuring 'Salman Khan' in the Last 10 Years**
```sql
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```
**Objective**: Count the number of movies featuring 'Salman Khan' in the last 10 years.

---

### 14. **Top 10 Actors with the Most Appearances in Indian Movies**
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*) AS total_movies
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY total_movies DESC
LIMIT 10;
```
**Objective**: Identify the top 10 actors with the most appearances in Indian-produced movies.

---

### 15. **Categorize Content Based on Keywords ('Kill' and 'Violence')**
```sql
SELECT 
    CASE 
        WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS content_category,
    COUNT(*) AS total_content
FROM netflix
GROUP BY content_category;
```
**Objective**: Categorize content as 'Bad' if it contains keywords like 'kill' or 'violence' and 'Good' otherwise.

---

## 📈 Findings and Conclusion

- **Content Types**: Netflix has a balanced mix of Movies and TV Shows.
- **Ratings**: Most common ratings vary by type of content, revealing target audience preferences.
- **Geographical Insights**: Countries like India are significant contributors to Netflix's content library.
- **Content Categorization**: A deeper dive into descriptions reveals thematic trends and content nature.

This project provides actionable insights into Netflix's content strategy, aiding decision-making for future content additions and marketing efforts.

--- 

## 🚀 Author
**Arhat Petkar**  

Feel free to explore, contribute, and provide feedback. 🎉
