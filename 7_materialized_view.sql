-- 7. materialized view
----------------------------------------------------------------------


-- total vanzari pe categorii
-- rezultatul salvat fizic

CREATE MATERIALIZED VIEW mv_vanzari_categorie AS

SELECT
    cat.nume_categorie,
    SUM(pc.cantitate * pc.pret) AS total_vanzari
FROM produse_comandate pc
JOIN produs p
    ON pc.id_produs = p.id_produs
JOIN categorie cat
    ON p.categorie_id = cat.id_categorie
GROUP BY cat.nume_categorie;


REFRESH MATERIALIZED VIEW mv_vanzari_categorie;

SELECT * FROM mv_vanzari_categorie;





-- top clienti premium

CREATE MATERIALIZED VIEW top_clienti_premium AS

WITH cheltuieli_clienti AS (
    SELECT
        co.id_utilizator,
        SUM(co.pret_total) AS total_cheltuit,
        COUNT(co.id_comanda) AS nr_comenzi
    FROM comanda co
    GROUP BY co.id_utilizator
),

medie_cheltuieli AS (
    SELECT
        AVG(total_cheltuit) AS medie
    FROM cheltuieli_clienti
)

SELECT
    u.nume_utilizator,
    c.total_cheltuit,
    c.nr_comenzi
FROM cheltuieli_clienti c
JOIN utilizator u
    ON c.id_utilizator = u.id_utilizator
WHERE c.total_cheltuit >
(
    SELECT medie
    FROM medie_cheltuieli
);

REFRESH MATERIALIZED VIEW top_clienti_premium;

SELECT * FROM top_clienti_premium;







-- produse cu stoc mic dar foarte vandute

CREATE MATERIALIZED VIEW produse_stoc_critic_vip AS

WITH vanzari_produs AS (
    SELECT
        pc.id_produs,
        SUM(pc.cantitate) AS total_vandut
    FROM produse_comandate pc
    GROUP BY pc.id_produs
),

medie_vanzari AS (
    SELECT
        AVG(total_vandut) AS medie
    FROM vanzari_produs
)

SELECT
    p.nume_produs,
    p.stoc,
    v.total_vandut
FROM vanzari_produs v
JOIN produs p
    ON v.id_produs = p.id_produs
WHERE p.stoc < 20
AND v.total_vandut >
(
    SELECT medie
    FROM medie_vanzari
);

REFRESH MATERIALIZED VIEW produse_stoc_critic_vip;

SELECT * FROM produse_stoc_critic_vip;