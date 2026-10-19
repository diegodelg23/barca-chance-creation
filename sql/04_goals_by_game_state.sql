-- When did Barça score their goals: while winning, drawing, or losing?
WITH goals AS (
    SELECT match_id, "index", team
    FROM shots
    WHERE shot_outcome = 'Goal'
),
score_before AS (
    SELECT team,
           COALESCE(SUM(CASE WHEN team = 'Barcelona' THEN 1 ELSE 0 END)
               OVER (PARTITION BY match_id ORDER BY "index"
                     ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS barca_before,
           COALESCE(SUM(CASE WHEN team <> 'Barcelona' THEN 1 ELSE 0 END)
               OVER (PARTITION BY match_id ORDER BY "index"
                     ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS opp_before
    FROM goals
)
SELECT CASE WHEN barca_before > opp_before THEN 'Winning'
            WHEN barca_before = opp_before THEN 'Drawing'
            ELSE 'Losing' END AS game_state,
       COUNT(*)              AS barca_goals
FROM score_before
WHERE team = 'Barcelona'
GROUP BY game_state
ORDER BY barca_goals DESC;