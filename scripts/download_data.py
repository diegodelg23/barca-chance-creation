"""Download StatsBomb open data for Barça's La Liga matches (2004/05-2020/21) into data/raw/."""
import json
import warnings
from pathlib import Path

import pandas as pd
from statsbombpy import sb

warnings.filterwarnings("ignore")      # hides the "no credentials" warning

RAW = Path("data/raw")
RAW.mkdir(parents=True, exist_ok=True)


def lists_to_text(df):
    """Parquet can't store Python lists/dicts mixed with blanks, so save them as JSON text."""
    for col in df.columns:
        if df[col].dtype == "object":
            df[col] = df[col].map(lambda v: json.dumps(v) if isinstance(v, (list, dict)) else v)
    return df


# 1. Which seasons to download
comps = sb.competitions()
seasons = comps[(comps.competition_name == "La Liga") & (comps.season_name >= "2004/2005")]

# 2. Match list (one row per match: date, teams, score, coaches)
all_matches = []
for _, row in seasons.iterrows():
    all_matches.append(sb.matches(competition_id=row.competition_id, season_id=row.season_id))
matches = pd.concat(all_matches, ignore_index=True)
matches = matches[(matches.home_team == "Barcelona") | (matches.away_team == "Barcelona")]
matches = matches.drop(columns=["home_manager_id", "away_manager_id",
                                "home_manager_country_id", "away_manager_country_id"])
matches = lists_to_text(matches)
matches.to_parquet(RAW / "matches.parquet")
print(f"Saved {len(matches)} matches")

# 3. Events (every pass, shot, tackle...), one file per season
for season, group in matches.groupby("season"):
    out = RAW / f"events_{season.replace('/', '-')}.parquet"
    if out.exists():
        print(f"{season}: already downloaded, skipping")
        continue
    frames = []
    for match_id in group.match_id:
        ev = sb.events(match_id=match_id)
        ev["match_id"] = match_id
        frames.append(ev)
    events = lists_to_text(pd.concat(frames, ignore_index=True))
    events.to_parquet(out)
    print(f"{season}: {len(group)} matches, {len(events)} events")