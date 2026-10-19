-- How much xG did Barça create and allow per match, each season?
SELECT m.season,
       COUNT(DISTINCT s.match_id)                                                          AS matches,
       ROUND(SUM(CASE WHEN s.team = 'Barcelona'  THEN s.shot_statsbomb_xg ELSE 0 END), 1) AS xg_for,
       ROUND(SUM(CASE WHEN s.team <> 'Barcelona' THEN s.shot_statsbomb_xg ELSE 0 END), 1) AS xg_against,
       ROUND(xg_for / matches, 2)                                                          AS xg_for_per_match,
       ROUND(xg_against / matches, 2)                                                      AS xg_against_per_match
FROM shots s
JOIN matches m ON s.match_id = m.match_id
GROUP BY m.season
ORDER BY m.season;