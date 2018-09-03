CREATE TABLE 'url history' (url TEXT PRIMARY KEY, utc NUMERIC DEFAULT (strftime('%Y%m%d%H%M%f','now')), count INTEGER DEFAULT 1) WITHOUT ROWID;
-- INSERT INTO 'url history' (url) VALUES ($1) ON CONFLICT(url) DO UPDATE SET count=count+1, utc=excluded.utc;

PRAGMA user_version = 4;
