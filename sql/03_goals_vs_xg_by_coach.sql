-- Did each coach's Barça score more or fewer goals than their xG?
WITH match_xg AS (
    SELECT match_id, SUM(shot_statsbomb_xg) AS xg
    FROM shots
    WHERE team = 'Barcelona'
    GROUP BY match_id
)
SELECT m.barca_coach,
       MIN(m.match_date)                                                              AS first_match,
       COUNT(*)                                                                       AS matches,
       SUM(CASE WHEN m.home_team = 'Barcelona' THEN m.home_score ELSE m.away_score END) AS goals,
       ROUND(SUM(x.xg), 1)                                                            AS total_xg,
       ROUND(goals - total_xg, 1)                                                     AS goals_minus_xg
FROM matches m
LEFT JOIN match_xg x ON m.match_id = x.match_id
GROUP BY m.barca_coach
ORDER BY first_match;