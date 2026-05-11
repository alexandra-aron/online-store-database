-- 8. verificare index si performanta
--------------------------------------------

-- exemplu plan executie 
EXPLAIN ANALYZE
SELECT *
FROM produs
WHERE categorie_id = 3;


-- lista indecsi
SELECT
    indexname,
    tablename
FROM pg_indexes
WHERE schemaname = 'public';