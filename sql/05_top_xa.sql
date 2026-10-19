-- Which Barça players set up the most expected goals (xA) with their passes?
SELECT p.player,
       COUNT(*)                           AS key_passes,
       ROUND(SUM(s.shot_statsbomb_xg), 2) AS xa
FROM shots s
JOIN passes p ON s.shot_key_pass_id = p.id
WHERE s.team = 'Barcelona'
GROUP BY p.player
ORDER BY xa DESC
LIMIT 10;