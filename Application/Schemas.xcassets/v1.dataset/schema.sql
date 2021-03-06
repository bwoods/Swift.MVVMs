CREATE TABLE uid (uid INTEGER PRIMARY KEY NOT NULL);
CREATE TABLE uuid (uid INTEGER PRIMARY KEY REFERENCES uid ON UPDATE CASCADE ON DELETE CASCADE, uuid BLOB DEFAULT (randomblob(16)) UNIQUE NOT NULL);

PRAGMA user_version = 1;
