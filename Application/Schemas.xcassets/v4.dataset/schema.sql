CREATE TABLE 'url history' (url TEXT PRIMARY KEY, utc NUMERIC DEFAULT (strftime('%Y%m%d%H%M%f','now')), count INTEGER DEFAULT 1) WITHOUT ROWID;

CREATE TEMPORARY VIEW 'current url' (url) AS SELECT url FROM 'url history' WHERE utc = (SELECT max(utc) FROM 'url history') ORDER BY utc DESC LIMIT 1;
CREATE TRIGGER 'current url → url history' INSTEAD OF INSERT ON 'current url'
  BEGIN
    INSERT INTO 'url history' (url) VALUES ('https://mymodernmet.com/cats-hipster-glasses/') ON CONFLICT(url) DO UPDATE SET count=count+1, utc=excluded.utc;
  END;

PRAGMA user_version = 4;
