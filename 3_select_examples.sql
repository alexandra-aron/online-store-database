-- 3. select (modele)
-------------------------------------------------------------


-- verificare tabele
SELECT * FROM categorie;
SELECT * FROM utilizator;
SELECT * FROM produs;
SELECT * FROM comanda;
SELECT * FROM produse_comandate;


-- produse mai scumpe decat media
SELECT
    nume_produs,
    pret
FROM produs
WHERE pret > (
    SELECT AVG(pret)
    FROM produs
);



-- ce a cumparat fiecare utilizator
SELECT
    u.nume_utilizator,
    p.nume_produs
FROM produs p
JOIN produse_comandate pc
    ON p.id_produs = pc.id_produs
JOIN comanda co
    ON co.id_comanda = pc.id_comanda
JOIN utilizator u
    ON co.id_utilizator = u.id_utilizator;


-- toate comenzile cu utilizatorul aferent
SELECT
    u.nume_utilizator,
    co.pret_total,
    co.status,
    co.data_creare
FROM utilizator u
JOIN comanda co
    ON u.id_utilizator = co.id_utilizator;


-- produse + categoria lor
SELECT
    p.nume_produs,
    cat.nume_categorie
FROM categorie cat
JOIN produs p
    ON cat.id_categorie = p.categorie_id;


-- detalii complete despre comenzi
SELECT
    u.id_utilizator,
    u.nume_utilizator,
    p.nume_produs,
    pc.cantitate,
    cat.nume_categorie
FROM categorie cat
JOIN produs p
    ON cat.id_categorie = p.categorie_id
JOIN produse_comandate pc
    ON p.id_produs = pc.id_produs
JOIN comanda co
    ON pc.id_comanda = co.id_comanda
JOIN utilizator u
    ON co.id_utilizator = u.id_utilizator;


-- ce produse exista in comanda cu id 1
SELECT
    p.nume_produs
FROM produs p
JOIN produse_comandate pc
    ON p.id_produs = pc.id_produs
WHERE pc.id_comanda = 1;


-- utilizatori care au cumparat casti
SELECT
    u.id_utilizator,
    u.nume_utilizator,
    p.nume_produs
FROM produs p
JOIN produse_comandate pc
    ON p.id_produs = pc.id_produs
JOIN comanda co
    ON pc.id_comanda = co.id_comanda
JOIN utilizator u
    ON co.id_utilizator = u.id_utilizator
WHERE p.nume_produs ILIKE '%casti%';