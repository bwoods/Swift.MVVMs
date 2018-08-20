CREATE TABLE 'time created'  (uid INTEGER PRIMARY KEY REFERENCES uid ON UPDATE CASCADE ON DELETE CASCADE, utc NUMERIC DEFAULT (strftime('%Y%m%d%H%M%f','now')) NOT NULL);
CREATE TABLE 'time modified' (uid INTEGER PRIMARY KEY REFERENCES uid ON UPDATE CASCADE ON DELETE CASCADE, utc NUMERIC DEFAULT (strftime('%Y%m%d%H%M%f','now')) NOT NULL);
CREATE TABLE 'time imported' (uid INTEGER PRIMARY KEY REFERENCES uid ON UPDATE CASCADE ON DELETE CASCADE, utc NUMERIC DEFAULT (strftime('%Y%m%d%H%M%f','now')) NOT NULL);

CREATE VIEW 'date created' (uid,utc) AS SELECT uid, CAST (utc AS INTEGER) FROM 'time created';
CREATE TRIGGER 'uid → uuid; time created' INSERT ON uid
  BEGIN
    INSERT INTO uuid (uid) VALUES (NEW.uid);
    INSERT INTO 'time created' (uid) VALUES (NEW.uid);
  END;

CREATE VIEW 'date modified' (uid,utc) AS SELECT uid, CAST (utc AS INTEGER) FROM 'time modified';
CREATE TRIGGER 'time created → modified' INSERT ON 'time created'
  BEGIN
    INSERT INTO 'time modified' (uid,utc) VALUES (NEW.uid, NEW.utc);
  END;
  
PRAGMA user_version = 2;
