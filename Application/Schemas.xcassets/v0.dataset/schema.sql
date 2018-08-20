CREATE TEMPORARY VIEW "sqlite tables" AS SELECT name, type FROM sqlite_master WHERE type = 'table';
