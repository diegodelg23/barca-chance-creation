-- Which Barça players created the most xG each season?
SELECT m.season,
       s.player,
       COUNT(*)                                                 AS shots,
       SUM(CASE WHEN s.shot_outcome = 'Goal' THEN 1 ELSE 0 END) AS goals,
       ROUND(SUM(s.shot_statsbomb_xg), 2)                       AS xg

FROM shots s
JOIN matches m ON s.match_id = m.match_id
WHERE s.team = 'Barcelona'
GROUP BY m.season, s.player
ORDER BY m.season, xg DESC;