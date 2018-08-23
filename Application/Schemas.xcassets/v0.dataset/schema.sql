CREATE TEMPORARY VIEW "sqlite tables" AS
 SELECT name, type
  FROM (SELECT name, type, rootpage FROM sqlite_master WHERE type = 'table'
  UNION SELECT name, type, rootpage FROM sqlite_master WHERE type = 'view')
 ORDER BY type, rootpage;
