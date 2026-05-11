-- 5. CTE
----------------------------------------------------------------


-- total cheltuit de fiecare utilizator
WITH total_cheltuit AS (
    SELECT
        id_utilizator,
        SUM(pret_total) AS total_cheltuit
    FROM comanda
    GROUP BY id_utilizator
)
SELECT
    u.nume_utilizator,
    t.total_cheltuit
FROM total_cheltuit t
JOIN utilizator u
    ON t.id_utilizator = u.id_utilizator;


-- produse cu venit peste medie
WITH venituri AS (
    SELECT
        id_produs,
        SUM(cantitate * pret) AS venit_total
    FROM produse_comandate
    GROUP BY id_produs
),

media AS (
    SELECT
        AVG(venit_total) AS medie_venit
    FROM venituri
)
SELECT *
FROM venituri
WHERE venit_total >
(
    SELECT medie_venit
    FROM media
);


-- categoria care a generat cei mai multi bani
WITH categorie_generatoare_multi_bani AS (
    SELECT
        cat.nume_categorie,
        SUM(pc.cantitate * pc.pret) AS total_bani
    FROM produse_comandate pc
    JOIN produs p
        ON pc.id_produs = p.id_produs
    JOIN categorie cat
        ON p.categorie_id = cat.id_categorie
    GROUP BY cat.nume_categorie
)
SELECT *
FROM categorie_generatoare_multi_bani
ORDER BY total_bani DESC
LIMIT 1;
