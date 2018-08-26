CREATE TEMPORARY VIEW "sqlite tables" AS
 SELECT name, type, sql
  FROM (SELECT name, type, sql, rootpage FROM sqlite_master WHERE type = 'table'
  UNION SELECT name, type, sql, rootpage FROM sqlite_master WHERE type = 'view')
 ORDER BY type, rootpage;
