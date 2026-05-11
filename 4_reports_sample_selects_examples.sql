-- 4. agregari si rapoarte
-----------------------------------------------------------------------


-- total cheltuit per utilizator
SELECT
    u.nume_utilizator,
    COUNT(co.id_comanda) AS numar_comenzi,
    SUM(co.pret_total) AS total_cheltuit
FROM utilizator u
JOIN comanda co
    ON u.id_utilizator = co.id_utilizator
GROUP BY u.nume_utilizator;


-- categoria cu cele mai multe produse vandute
SELECT
    cat.nume_categorie,
    SUM(pc.cantitate) AS cantitate_totala_vanduta
FROM produse_comandate pc
JOIN produs p
    ON pc.id_produs = p.id_produs
JOIN categorie cat
    ON p.categorie_id = cat.id_categorie
GROUP BY cat.nume_categorie
ORDER BY cantitate_totala_vanduta DESC;


-- top 3 produse cele mai vandute
SELECT
    p.nume_produs,
    SUM(pc.cantitate) AS total_vandut
FROM produse_comandate pc
JOIN produs p
    ON pc.id_produs = p.id_produs
GROUP BY p.nume_produs
ORDER BY total_vandut DESC
LIMIT 3;


-- utilizatori care au cheltuit peste media comenzilor
SELECT
    u.nume_utilizator,
    SUM(co.pret_total) AS total
FROM utilizator u
JOIN comanda co
    ON u.id_utilizator = co.id_utilizator
GROUP BY u.nume_utilizator
HAVING SUM(co.pret_total) >
(
    SELECT AVG(pret_total)
    FROM comanda
);