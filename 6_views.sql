-- 6. view-uri
--------------------------------------------------------------


-- view pentru afisarea rapida a comenzilor complete
CREATE VIEW view_comenzi_rapide AS
SELECT
    co.id_comanda,
    u.nume_utilizator,
    p.nume_produs,
    cat.nume_categorie,
    pc.cantitate,
    pc.pret,
    co.pret_total,
    co.status,
    co.data_creare
FROM comanda co
JOIN utilizator u
    ON co.id_utilizator = u.id_utilizator
JOIN produse_comandate pc
    ON co.id_comanda = pc.id_comanda
JOIN produs p
    ON pc.id_produs = p.id_produs
JOIN categorie cat
    ON p.categorie_id = cat.id_categorie;


SELECT * FROM view_comenzi_rapide;


-- produse care nu au fost vandute deloc
CREATE VIEW produse_nevandute AS
SELECT
    p.id_produs,
    p.nume_produs,
    p.pret
FROM produs p
LEFT JOIN produse_comandate pc
    ON p.id_produs = pc.id_produs
WHERE pc.id_produs IS NULL;


SELECT * FROM produse_nevandute;