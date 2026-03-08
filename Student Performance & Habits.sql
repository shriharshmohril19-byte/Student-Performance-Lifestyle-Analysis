CREATE DATABASE student_habits;
USE student_habits;

-- Creating a duplicate table so as to make no changes to the original table.
-- We will work on this duplicated table to make any sort of changes.
CREATE TABLE stud_data 
LIKE student_data;
INSERT INTO stud_data
SELECT * 
FROM student_data;

SELECT *
FROM stud_data;

-- Finding if there are any duplicate values or rows or fields
SELECT *,
ROW_NUMBER()
OVER(PARTITION BY Student_ID) AS row_id
FROM stud_data;
-- No duplicate values are found

-- Standardizing the data, eg - getting rid of blank spaces, etc
SELECT Gender, Major, TRIM(Gender), TRIM(Major)
FROM stud_data;
UPDATE stud_data
SET Gender = TRIM(Gender);
UPDATE stud_data
SET Major = TRIM(Major); 

SELECT DISTINCT Major
FROM stud_data
ORDER BY 1; -- okay

-- All the data has been cleaned
-- Data Analysis
-- -- I. STUDENT DEMOGRAPHICS -- --
	-- i. Age Distribution across Majors

SELECT Major, MIN(Age) AS min_age, MAX(Age) AS max_age, ROUND(AVG(Age),0) AS avg_age
FROM stud_data
GROUP BY Major;

	-- ii. Students per major

SELECT Major, COUNT(Student_ID) AS students_per_major
FROM stud_data
GROUP BY Major
ORDER BY students_per_major DESC;

	-- iii. Gender distribution across majors
SELECT Major, Gender,
COUNT(Gender) AS student_count
FROM stud_data
GROUP BY Major, Gender
ORDER BY Major, Gender;

	-- iv. Gender distribution percentage across majors using window function
SELECT
    Major,
    Gender,
    COUNT(Gender) AS student_count,
    ROUND(
        COUNT(Gender) * 100.0 / SUM(COUNT(Gender)) OVER (PARTITION BY Major), 2
    ) AS gender_percentage
FROM stud_data
GROUP BY Major, Gender
ORDER BY Major, Gender;

-- -- II. CGPA/GPA DATA ANALYSIS -- --
SELECT *
FROM stud_data;

	-- i. Average Final CGPA by major
SELECT Major, 
ROUND(AVG(Final_CGPA), 2) AS avg_cgpa
FROM stud_data
GROUP BY Major;   

	-- ii. Ranking Average Final CGPA by major
SELECT Major,
ROUND(AVG(Final_CGPA),2) AS avg_final_cgpa,
COUNT(Gender) AS student_count,
RANK() OVER (ORDER BY AVG(Final_CGPA) DESC) AS `rank`
FROM stud_data
GROUP BY Major
ORDER BY `rank`;

-- Students pursuing Computer Science major has the best average  final CGPA, while the students pursuing Mathematics has the worst average CGPA. 
-- However, it is noteworthy that averages depend upon the total number of students in each major, which vary significantly. Hence, it is not 
-- appropriate to compare and judge students belonging to a particular major just by their average CGPA.

	-- iii. Average Final CGPA by gender per major
SELECT Major, Gender,
ROUND(AVG(Final_CGPA), 2) AS avg_cgpa
FROM stud_data
GROUP BY Major, Gender
ORDER BY Major, Gender;

	-- iv. Difference between Average Previous GPA and Average Final CGPA
SELECT ROUND(AVG(Previous_GPA),2) AS avg_prev_gpa,
ROUND(AVG(Final_CGPA),2) AS avg_final_cgpa,
ROUND(AVG(Final_CGPA - Previous_GPA),2) AS avg_cgpa_chng
FROM stud_data;

-- Avg change in CGPA is +0.18, ie a POSITIVE value, which means, on average, the CGPA has INCREASED.

	-- v. Performance trend across Majors
SELECT Major, 
COUNT(*) AS student_count,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2) AS percentage,
    CASE
        WHEN Final_CGPA > Previous_GPA THEN 'Improved'
        WHEN Final_CGPA < Previous_GPA THEN 'Worsened'
        ELSE 'No Change'
    END AS performance_trend    
FROM stud_data
GROUP BY Major, performance_trend
ORDER BY Major, percentage DESC;

	-- vi. Average CGPA change across Majors
SELECT Major,
ROUND(AVG(Final_CGPA - Previous_GPA), 2) AS avg_cgpa_chng,
COUNT(*) AS student_count
FROM stud_data
GROUP BY Major
ORDER BY avg_cgpa_chng DESC;

-- Overall, students show a slight positive improvement in academic performance compared to their previous GPA,
-- with the majority either improving or maintaining their performance. Improvement trends vary across majors.

-- -- III. ATTENDANCE VS CGPA DATA ANALYSIS -- --
SELECT *
FROM stud_data;

	-- i. Comparing Avg Final CGPA for attendance ranges
SELECT
    CASE
        WHEN Attendance_Pct < 60 THEN 'Below 60%'
        WHEN Attendance_Pct BETWEEN 60 AND 69 THEN '60–69%'
        WHEN Attendance_Pct BETWEEN 70 AND 79 THEN '70-79%'
        WHEN Attendance_Pct BETWEEN 80 AND 89 THEN '80-89%'
        ELSE '90% and above'
    END AS attendance_range,
    COUNT(*) AS student_count,
    ROUND(AVG(Final_CGPA), 2) AS avg_final_cgpa
FROM stud_data
GROUP BY attendance_range
ORDER BY
    CASE attendance_range
        WHEN '90% and above' THEN 1
        WHEN '80-89%' THEN 2
        WHEN '70-79%' THEN 3
		WHEN '60-69%' THEN 4
        ELSE 5
    END;

	-- ii. Assigning grades for attendance by Major
SELECT 
	CASE
        WHEN Attendance_Pct >= 90 THEN '90% and above'
        WHEN Attendance_Pct BETWEEN 80 AND 89 THEN '80–89%'
        WHEN Attendance_Pct BETWEEN 70 AND 79 THEN '70-79%'
        WHEN Attendance_Pct BETWEEN 60 AND 69 THEN '80-89%'
        ELSE '60% and below'
    END AS attendance_range,
	CASE
		WHEN Attendance_Pct >= 90 THEN 'A+'
        WHEN Attendance_Pct BETWEEN 80 AND 89 THEN 'A'
        WHEN Attendance_Pct BETWEEN 70 AND 79 THEN 'B+'
        WHEN Attendance_Pct BETWEEN 60 AND 69 THEN 'B'
        ELSE 'C'
	END AS Attendance_grade,
    COUNT(*) AS Stu_Count, Major,
    ROUND(AVG(Final_CGPA),2) AS Avg_CGPA
    FROM stud_data
    GROUP BY Major, Attendance_grade, attendance_range 
    ORDER BY  Major,
		CASE Attendance_grade
			WHEN 'A+' THEN 1
            WHEN 'A' THEN 2
            WHEN 'B+' THEN 3
            WHEN 'B' THEN 4
            ELSE 5
		END,
			CASE attendance_range
			WHEN '90% and above' THEN 1
			WHEN '80-89%' THEN 2
			WHEN '70-79%' THEN 3
			WHEN '60-69%' THEN 4
			ELSE 5
		END;

-- -- IV. STUDY HABITS ANALYSIS -- --
SELECT *
FROM stud_data;

	-- i. Average Study Hours by Major and Gender

SELECT Major, Gender,
ROUND(AVG(Study_Hours_Per_Day),1) AS avg_studyhrs_maj
FROM stud_data
GROUP BY Major, Gender
ORDER BY Major DESC, Gender DESC;

	-- ii. Average Study Hours Vs CGPA by Major
SELECT Major, 
ROUND(AVG(Final_CGPA),2) AS avg_cgpa,
ROUND(AVG(Study_Hours_Per_Day),1) AS avg_studyhrs_maj
FROM stud_data
GROUP BY Major
ORDER BY Major DESC;

SELECT * FROM stud_data;

	-- iii. Ranking and Assigning Performance Tag based on Final CGPA in each major using CTE
WITH Student_ranks AS
(
SELECT Student_ID, Gender, Major, Previous_GPA, Final_CGPA,
DENSE_RANK() OVER(PARTITION BY Major ORDER BY Final_CGPA DESC) AS Ranking
FROM stud_data
) 
SELECT *, 
CASE
		WHEN Final_CGPA = 4 THEN 'Top Performer'
        WHEN Final_CGPA BETWEEN 3.5 AND 3.9 THEN 'Good Performer'
        WHEN Final_CGPA BETWEEN 3 AND 3.4 THEN 'Average Performer'
        ELSE 'Below Average Performer'
	END AS Performance
FROM Student_ranks
ORDER BY Ranking, Major;

	-- iv. Top three rankings from each major and no of students in each ranking based on Final CGPA
WITH Student_rank AS
(
SELECT Student_ID, Gender, Major, Previous_GPA, Final_CGPA,
DENSE_RANK() OVER(PARTITION BY Major ORDER BY Final_CGPA DESC) AS Ranking
FROM stud_data
) 
SELECT Major, Ranking,
COUNT(Ranking) AS No_of_Stud, Final_CGPA
FROM Student_rank
WHERE Ranking <=3
GROUP BY Major, Final_CGPA
ORDER BY Major, Ranking;

	-- v. Analyzing if high study hours actually help in gaining CGPA
SELECT
    CASE
        WHEN Study_Hours_Per_Day < 2 THEN 'Below 2 hrs'
        WHEN Study_Hours_Per_Day BETWEEN 2 AND 4 THEN '2–4 hrs'
        WHEN Study_Hours_Per_Day BETWEEN 5 AND 6 THEN '5–6 hrs'
        WHEN Study_Hours_Per_Day BETWEEN 7 AND 8 THEN '7–8 hrs'
        ELSE 'Above 8 hrs'
    END AS study_hours_bucket,
    COUNT(*) AS student_count,
    ROUND(AVG(Final_CGPA), 2) AS avg_final_cgpa
FROM stud_data
GROUP BY study_hours_bucket
ORDER BY
    CASE study_hours_bucket
        WHEN 'Below 2 hrs' THEN 1
        WHEN '2–4 hrs' THEN 2
        WHEN '5–6 hrs' THEN 3
        WHEN '7–8 hrs' THEN 4
        ELSE 5
    END;
    
	-- vi. Comparing CGPAs for Very high Vs High Vs Moderate study hours
SELECT
CASE
	WHEN Study_Hours_Per_Day >= 3 AND Study_Hours_Per_Day < 6 THEN 'Moderate (3-6 Hrs)'
    WHEN Study_Hours_Per_Day >= 6 AND Study_Hours_Per_Day <= 8 THEN 'High (6-8 Hrs)'
    ELSE 'Very High (>8 Hrs)'
END AS study_intensity,
COUNT(*) AS stu_count,
ROUND(AVG(Final_CGPA),2) AS avg_final_cgpa
FROM stud_data
WHERE Study_Hours_Per_Day >=3
GROUP BY study_intensity
ORDER BY 
	CASE study_intensity
		WHEN 'Moderate (3-6 Hrs)' THEN 3
        WHEN 'High (6-8 Hrs)' THEN 2
        WHEN 'Very High (>8 Hrs)' THEN 1
	END;
    
    
-- -- V. LIFESTYLE ANALYSIS -- --
SELECT * FROM stud_data;

	-- i. Sleep Analysis - Avg Sleep hours vs Final_CGPA
SELECT Major,
    CASE
        WHEN Sleep_Hours < 5 THEN 'Below 5 hrs'
        WHEN Sleep_Hours >= 5 AND Sleep_Hours < 6 THEN '5–<6 hrs'
        WHEN Sleep_Hours >= 6 AND Sleep_Hours < 7 THEN '6–<7 hrs'
        WHEN Sleep_Hours >= 7 AND Sleep_Hours < 8 THEN '7–<8 hrs'
        ELSE '8+ hrs'
    END AS sleep_bucket,
    COUNT(*) AS student_count,
    ROUND(AVG(Final_CGPA), 2) AS avg_final_cgpa
FROM stud_data
GROUP BY sleep_bucket, Major
ORDER BY Major, 
    CASE sleep_bucket
        WHEN 'Below 5 hrs' THEN 1
        WHEN '5–<6 hrs' THEN 2
        WHEN '6–<7 hrs' THEN 3
        WHEN '7–<8 hrs' THEN 4
        ELSE 5
    END;

		-- i.i. Sleep Analysis - Study-Sleep Balance - Top 10
				SELECT
					Study_Hours_Per_Day,
					Sleep_Hours,
					ROUND(AVG(Final_CGPA),2) AS avg_cgpa,
					COUNT(*) AS student_count
				FROM stud_data
				GROUP BY
					Study_Hours_Per_Day,
					Sleep_Hours
				HAVING COUNT(*) >= 3
				ORDER BY avg_cgpa DESC
				LIMIT 10;
                
	-- ii. Social Analysis - Min, Max, Avg Social hours per Major
SELECT Major, COUNT(*) AS stu_count,
MIN(Social_Hours_Week) AS min_social_hrs,
MAX(Social_Hours_Week) AS max_social_hrs,
ROUND(AVG(Social_Hours_Week)) AS avg_social_hrs
FROM stud_data
GROUP BY Major
ORDER BY Major;

	-- iii. Social Analysis - Avg Social hours vs Final_CGPA
SELECT Major,
CASE
	WHEN Social_Hours_Week <= 5 THEN 'Below 6 Hours'
    WHEN Social_Hours_Week BETWEEN 6 AND 10 THEN '6 - 10 Hours'
    WHEN Social_Hours_Week BETWEEN 11 AND 15 THEN '11 - 15 Hours'
    ELSE '16 - 20 Hours'
END AS social_hrs_grp,
COUNT(*) AS student_count,
ROUND(AVG(Final_CGPA), 2) AS avg_final_cgpa
FROM stud_data
GROUP BY Major, social_hrs_grp
ORDER BY Major, 
	CASE social_hrs_grp
		WHEN 'Below 6 Hours' THEN 1
        WHEN '6 - 10 Hours' THEN 2
        WHEN '11 - 15 Hours' THEN 3
        ELSE 4
	END;
    
	-- iv. Top performers Vs Average Habits   
WITH major_avg AS (
    SELECT
        Major,
        ROUND(AVG(Study_Hours_Per_Day),2) AS avg_study,
        ROUND(AVG(Sleep_Hours),1) AS avg_sleep
    FROM stud_data
    GROUP BY Major
)
SELECT
    s.Student_ID,
    s.Major,
    s.Study_Hours_Per_Day,
    m.avg_study,
    s.Sleep_Hours,
    m.avg_sleep,
    s.Final_CGPA
FROM student_data s
JOIN major_avg m
ON s.Major = m.Major
WHERE s.Final_CGPA > 3.8
ORDER BY Final_CGPA DESC, Major;


-- -- VI. COMBINED ANALYSIS -- --
SELECT * FROM stud_data;

	-- i. Study Effect on CGPA
SELECT
    CASE
        WHEN Attendance_Pct >= 85 AND Study_Hours_Per_Day >= 6
            THEN 'High Attendance + High Study'
        ELSE 'Others'
    END AS student_group,
    COUNT(*) AS student_count,
    ROUND(AVG(Final_CGPA), 2) AS avg_final_cgpa
FROM stud_data
GROUP BY student_group;

	-- ii. Sleep & Study Effect on CGPA
SELECT
    CASE
        WHEN Sleep_Hours < 6 AND Study_Hours_Per_Day >= 6
            THEN 'Low Sleep + High Study'
        WHEN Sleep_Hours >= 7 AND Study_Hours_Per_Day >= 6
            THEN 'Adequate Sleep + High Study'
        ELSE 'Other'
    END AS sleep_study_group,
    COUNT(*) AS student_count,
    ROUND(AVG(Final_CGPA), 2) AS avg_final_cgpa
FROM stud_data
WHERE Study_Hours_Per_Day >= 6
GROUP BY sleep_study_group;

	-- iii. Best performing students (top 10%) using NTILE
WITH ranked_students AS (
    SELECT
        *,
        NTILE(10) OVER (ORDER BY Final_CGPA DESC) AS cgpa_a
    FROM stud_data
)
SELECT
    Major,
    ROUND(AVG(Attendance_Pct), 1) AS avg_attendance,
    ROUND(AVG(Study_Hours_Per_Day), 1) AS avg_study_hours,
    ROUND(AVG(Sleep_Hours), 1) AS avg_sleep_hours,
    ROUND(AVG(Social_Hours_Week), 1) AS avg_social_hours,
    ROUND(AVG(Final_CGPA), 2) AS avg_final_cgpa,
    COUNT(*) AS top10_stud_count
FROM ranked_students
WHERE cgpa_a = 1 
GROUP BY Major
ORDER BY avg_final_cgpa DESC;

	-- iv. Worst performing students (bottom 10%) using NTILE
WITH ranked_students AS (
    SELECT
        *,
        NTILE(10) OVER (ORDER BY Final_CGPA DESC) AS cgpa_a
    FROM stud_data
)
SELECT
    Major,
    ROUND(AVG(Attendance_Pct), 1) AS avg_attendance,
    ROUND(AVG(Study_Hours_Per_Day), 1) AS avg_study_hours,
    ROUND(AVG(Sleep_Hours), 1) AS avg_sleep_hours,
    ROUND(AVG(Social_Hours_Week), 1) AS avg_social_hours,
    ROUND(AVG(Final_CGPA), 2) AS avg_final_cgpa,
    COUNT(*) AS worst10_stud_count
FROM ranked_students
WHERE cgpa_a = 10
GROUP BY Major
ORDER BY avg_final_cgpa DESC;

	-- v. Comparing top 10% & worst 10% students using NTILE
WITH ranked_students AS (
    SELECT
        *,
        NTILE(10) OVER (ORDER BY Final_CGPA DESC) AS cgpa_pctile
    FROM stud_data
)
SELECT
    CASE
        WHEN cgpa_decile = 1 THEN 'Top 10%'
        WHEN cgpa_decile = 10 THEN 'Bottom 10%'
    END AS performance_group,
    COUNT(*) AS student_count,
    ROUND(AVG(Final_CGPA),2) AS avg_cgpa,
    ROUND(AVG(Attendance_Pct),2) AS avg_attendance,
    ROUND(AVG(Study_Hours_Per_Day),2) AS avg_study_hours,
    ROUND(AVG(Sleep_Hours),2) AS avg_sleep_hours,
    ROUND(AVG(Social_Hours_Week),2) AS avg_social_hours
FROM ranked_students
WHERE cgpa_pctile IN (1,10)
GROUP BY performance_group;

	-- vi. Top 10 Students on Productivity Score 
    -- Weightage - 50% of (Study Hours - 40%, Attendance - 40%, Sleep - 20%) + 50% of (4 * Final CGPA)
    -- Productivity Score = (0.5 * (0.4 × Study Hours) + (0.4 × Attendance) + (0.2 × Sleep Balance)) + ((4 * Final_CGPA)*0.5)
SELECT
    Student_ID,
    Major,
    Final_CGPA,
    ROUND(
        (0.5*(Study_Hours_Per_Day * 0.4) +
        (Attendance_Pct/100 * 0.4 * 10) +
        (Sleep_Hours * 0.2)) + ((4 * Final_CGPA)*0.5), 1) 
        AS productivity_score
FROM stud_data
ORDER BY productivity_score DESC
LIMIT 10;

		-- vii. Lifestyle Risk
SELECT
    Student_ID,
    Major,
    Final_CGPA,
    Study_Hours_Per_Day,
    Sleep_Hours,
    Attendance_Pct,
    Social_Hours_Week,
    CASE
        WHEN Sleep_Hours < 6
        AND Study_Hours_Per_Day < 3
        AND Attendance_Pct < 75
        THEN 'High Risk'
        WHEN Sleep_Hours < 6
        OR Attendance_Pct < 75
        THEN 'Moderate Risk'
        ELSE 'Healthy Lifestyle'
    END AS lifestyle_risk
FROM stud_data
ORDER BY Final_CGPA DESC;

-- -- VII. PREDICTING STUDENT PERFORMANCE BASED ON HABITS -- --
WITH student_profiles AS (
    SELECT
        Student_ID,
        Major,
        Final_CGPA,
        Study_Hours_Per_Day,
        Sleep_Hours,
        Attendance_PCT,
        Social_Hours_Week,
        CASE
            WHEN Attendance_Pct >= 85
            AND Study_Hours_Per_Day BETWEEN 4 AND 7
            AND Sleep_Hours BETWEEN 7 AND 8
            AND Social_Hours_Week <= 12
            THEN 'Optimal Habits'

            WHEN Attendance_Pct >= 75
            AND Study_Hours_Per_Day >= 3
            AND Sleep_Hours >= 6
            THEN 'Balanced Habits'
            ELSE 'Risky Habits'
        END AS habit_profile
    FROM stud_data
)
SELECT
    habit_profile,
    COUNT(*) AS student_count,
    ROUND(AVG(Final_CGPA),2) AS avg_cgpa,
    ROUND(AVG(Study_Hours_Per_Day),2) AS avg_study,
    ROUND(AVG(Sleep_Hours),2) AS avg_sleep,
    ROUND(AVG(Attendance_Pct),2) AS avg_attendance,
    ROUND(AVG(Social_Hours_Week),2) AS avg_social
FROM student_profiles
GROUP BY habit_profile
ORDER BY avg_cgpa DESC;

-- -- VIII. STUDENT BEHAVIORAL ANALYSIS -- --
WITH ranked_students AS (
    SELECT
        *,
        NTILE(10) OVER (ORDER BY Final_CGPA DESC) AS cgpa_pctile
    FROM stud_data
),
performance_groups AS (
    SELECT *,
        CASE
            WHEN cgpa_pctile = 1 THEN 'Top Performers'
            WHEN cgpa_pctile BETWEEN 2 AND 4 THEN 'High Performers'
            WHEN cgpa_pctile BETWEEN 5 AND 7 THEN 'Average Performers'
            ELSE 'Below Average Performers'
        END AS performance_group
    FROM ranked_students
)
SELECT
    performance_group,
    COUNT(*) AS student_count,
    ROUND(AVG(Final_CGPA),2) AS avg_cgpa,
    ROUND(AVG(Attendance_Pct),2) AS avg_attendance,
    ROUND(AVG(Study_Hours_Per_Day),2) AS avg_study_hours,
    ROUND(AVG(Sleep_Hours),2) AS avg_sleep_hours,
    ROUND(AVG(Social_Hours_Week),2) AS avg_social_hours
FROM performance_groups
GROUP BY performance_group
ORDER BY avg_cgpa DESC;



SELECT * FROM stud_data;