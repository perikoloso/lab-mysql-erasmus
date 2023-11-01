



-- 1	What is the average age of students who have outstanding grades? 
     -- Provide the table with EXCELLENT if they have a 9 or 10, GOOD if they have 7 or 8, PASS if they have a 5 or 6, and FAIL if it is less than 5. 

		
		
		SELECT 
		CASE
			WHEN g.grades < 5 THEN 'FAIL'
		    WHEN g.grades >= 9 THEN 'EXCELLENT'
		    WHEN g.grades >= 7 THEN 'GOOD'
		    WHEN g.grades >= 5 THEN 'PASS'
		    ELSE 'FAIL'
			END AS grade_category,
				ROUND(AVG((DATEDIFF(CURRENT_DATE(), s.dob)/365))) AS avg_age
		from grades g
		JOIN students s  ON s.student_id = g.student_id
		GROUP BY grade_category;


-- 2	What is the average age of students by university?
	
	
	SELECT u.uni_name , ROUND(AVG((DATEDIFF(CURDATE(), s.dob)/365))) AS avg_age FROM university u 
    JOIN campus c ON c.university_id = u.university_id 
    JOIN students s ON s.campus_id  = c.campus_id
    GROUP BY u.uni_name
    ORDER BY avg_age DESC;
	

-- 3   What is the proportion of students who failed each subject? 
--     Provide the subject name, number of students who failed, total number of students, and the proportion of students
 --    who failed (as a percentage) for each subject. Display the results in descending order of the proportion of students who failed.
   
 
   
   WITH stats (subject,fails,totals) AS (
   
   	   SELECT s2.subj_name,
   	    SUM(CASE WHEN g.grades  < 5 THEN 1 ELSE 0 END) AS students_failed,
   	    count(s.student_id) AS total_number_students
   	   FROM students s 
   	   JOIN grades g ON g.student_id  = s.student_id 
   	   JOIN subjects s2 ON s2.subject_id = g.subject_id
   	   GROUP BY s2.subj_name)  SELECT subject,fails,totals, round((fails/totals)*100,2) AS percent FROM stats ORDER BY percent desc;


-- 4	What is the average grade of students who have done an erasmus compared to those who have not? Alt text
   	  
SELECT
    CASE
        WHEN ia.student_id  IS NOT NULL THEN 'Erasmus'
        ELSE 'Non-Erasmus'
    END AS IsErasmus,
    AVG(g.grades) AS avg_grade
FROM students s
LEFT JOIN 
    international_agreement ia ON s.student_id  = ia.student_id 
LEFT JOIN grades g ON s.student_id  = g.student_id 
GROUP BY
    IsErasmus;
   
	
-- 5	For each university, identify the number of bachelor’s, master’s and PhD degrees awarded.
-- Provide the university ID and name along with the count for each type of degree. Alt text


 SELECT u.university_id ,u.uni_name,
    sum(CASE WHEN b.bachelor_id  LIKE 'B%' THEN 1 ELSE 0 END) AS Bachelor,
    sum(CASE WHEN b.bachelor_id LIKE 'M%' THEN 1 ELSE 0 END) AS Master,
    sum(CASE WHEN b.bachelor_id LIKE 'D%' THEN 1 ELSE 0 END) AS PhD 
 FROM university u
 JOIN bachelor b ON b.university_id = u.university_id
 GROUP BY  u.university_id ,u.uni_name
 ORDER BY university_id; 
  
   	  
   	  
-- 6	Which are the top 5 universities with the highest average ranking over the years? Provide the University ID, University Name, and Average Ranking.

SELECT  r.university_id, u.uni_name ,
round(avg (intl_ranking)) AS rk
FROM ranking r
JOIN university u ON u.university_id = r.university_id 
GROUP BY r.university_id, u.uni_name 
ORDER BY rk desc;
	

-- 7	Provide de id, the name, the last name, the name of the home university and the email of the 10 students that have been on an international agreement more times.

	SELECT s.student_id, s.f_name, s.l_name,(SELECT x.uni_name  FROM university x WHERE x.university_id = ia.home_university) AS uniname,s.email ,count(ia.agreement_code) AS totagreement
	FROM university u
	JOIN international_agreement ia ON ia.home_university = u.university_id 
	JOIN students s ON s.student_id = ia.student_id 
	GROUP BY s.student_id, s.f_name, s.l_name,s.email,uniname
	ORDER BY totagreement desc,student_id  asc;
	
	

-- 8	Make a query where, by modifying the international agreement number, 
--      you can identify the id and name of the student who did the exchange, the name of the home university and the name of the city where the exchange took place. 
--    Bonus: Now you can try to use procedures to parameterize the query. https://learn.microsoft.com/es-es/sql/t-sql/statements/create-procedure-transact-sql?view=sql-server-ver16

	SELECT ia.agreement_code ,s.student_id ,s.f_name AS Student_First_name ,s.l_name AS Student_Last_name,
		   (SELECT u2.uni_name  FROM university u2 WHERE u2.university_id = ia.home_university) AS home_university,
		   	(SELECT u2.uni_name  FROM university u2 WHERE u2.university_id = ia.away_university) AS away_university
	FROM international_agreement ia 
	JOIN students s ON s.student_id = ia.student_id 
	JOIN university u ON u.university_id = ia.home_university
	WHERE ia.agreement_code  = '9OP82';

	-- PROCEDURE

	CALL GetIa('9OP82');

-- 9	Find and display the number of universities offering each subject, along with the average grade for each subject. 

-- 10	Find the top 5 cities with the highest percentage of students who have outstanding grades (9 or 10). Provide the city, state, and the percentage of outstanding students for each city. Alt text Alt text

-- 11	Compare the universities that send the most students with the universities that receive the most students. Do it in 2 queries. Alt text Bonus: Now you can try to join both queries by using “UNION ALL” operator. Alt text

-- 12	Create a CTE that lists all students who have not signed any international agreements. Include the columns student_id, f_name, and l_name. Then, write a query to select all the rows from the CTE. Alt text

-- 13	Write a SQL query to rank universities based on their international ranking for the year 2022 in descending order. Include the following columns in the result: uni_name, intl_ranking, and the rank assigned using the window function. Alt text

-- 14	Write a query to find the students who have the highest and lowest grades for each subject. Include the columns subject_id, subj_name, student_id, f_name, l_name, and grades. Use window functions to rank the students within each subject based on their grades. Alt text


-- 15	Create a CTE that calculates the total number of subjects offered by each university. Include the columns uni_name and total_subjects. Then, write a query to select all the rows from the CTE in descending order of total subjects. Alt text

