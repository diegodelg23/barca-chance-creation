"""Build data/barca.duckdb from the raw Parquet files."""
import duckdb

con = duckdb.connect("data/barca.duckdb")
con.execute("""
    CREATE OR REPLACE TABLE matches AS
    SELECT *, CASE WHEN home_team = 'Barcelona' THEN home_manager_name ELSE away_manager_name END AS barca_coach
    FROM 'data/raw/matches.parquet'
""")
con.execute("""
    UPDATE matches SET barca_coach = (
        SELECT MODE(m2.barca_coach) FROM matches m2 WHERE m2.season = matches.season
    )
    WHERE barca_coach IS NULL
""")
con.execute("CREATE OR REPLACE TABLE events  AS SELECT * FROM read_parquet('data/raw/events_*.parquet', union_by_name=true)")
con.execute("CREATE OR REPLACE TABLE shots   AS SELECT * FROM events WHERE type = 'Shot'")
con.execute("CREATE OR REPLACE TABLE passes  AS SELECT * FROM events WHERE type = 'Pass'")
for t in ["matches", "events", "shots", "passes"]:
    print(t, con.sql(f"SELECT COUNT(*) FROM {t}").fetchone()[0])