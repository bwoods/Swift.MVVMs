CREATE TABLE document (uid INTEGER PRIMARY KEY REFERENCES uid ON UPDATE CASCADE ON DELETE CASCADE);
CREATE TABLE title (uid INTEGER PRIMARY KEY REFERENCES uid ON UPDATE CASCADE ON DELETE CASCADE, title TEXT NOT NULL);

CREATE VIEW 'document view' (uid,title) AS SELECT uid,title FROM document NATURAL JOIN title;


-- CREATE TRIGGER 'document view → uid; title' INSTEAD OF INSERT ON 'document view'
--   BEGIN
--     INSERT OR REPLACE INTO uid (uid) VALUES (NULL);
--     INSERT INTO document (uid) VALUES (last_insert_rowid());
--     INSERT INTO title (uid,title) VALUES (last_insert_rowid(), coalesce(NEW.title, "Untitled"));
--   END;
  

-- TODO: CREATE TRIGGER 'title → FTS' INSERT/UPDATE ON 'title'

PRAGMA user_version = 3;
