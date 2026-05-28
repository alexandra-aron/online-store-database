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



----produse scumpe

---v1
CREATE VIEW produse_scumpe1 AS
WITH medie AS
	(SELECT AVG(pret) AS medie_pret
	FROM produs
  )
SELECT p.nume_produs, p.pret
FROM produs p , medie m
WHERE p.pret > m.medie_pret;

SELECT * FROM produse_scumpe1;

--v2
CREATE VIEW produse_scumpe2 AS
WITH medie AS
	(SELECT AVG(pret) AS medie_pret
	FROM produs
  )
SELECT p.nume_produs, p.pret
FROM produs p
CROSS JOIN medie m
WHERE p.pret > m.medie_pret;

SELECT * FROM produse_scumpe2;




--utilizatori care au cheltuit peste_media_cheltuielilor

--v1
CREATE VIEW peste_media_cheltuielilor_1 AS
WITH total_pret AS
		(SELECT u.id_utilizator, u.nume_utilizator, SUM(pc.cantitate*pc.pret) AS pret_total
		FROM utilizator u
		JOIN comanda co ON u.id_utilizator = co.id_utilizator 
		JOIN produse_comandate pc ON co.id_comanda = pc.id_comanda
		GROUP BY u.id_utilizator, u.nume_utilizator
  ),
medie AS (
    SELECT AVG(pret_total) AS media_totalurilor
	  FROM total_pret
  )
SELECT tp.nume_utilizator, tp.pret_total
FROM total_pret tp
CROSS JOIN medie m
WHERE tp.pret_total > m.media_totalurilor;

SELECT * FROM peste_media_cheltuielilor_1;

--v2
CREATE VIEW peste_media_cheltuielilor_2 AS
WITH total_pret AS
		(SELECT u.id_utilizator, u.nume_utilizator, SUM(pc.cantitate*pc.pret) AS pret_total
		FROM utilizator u
		JOIN comanda co ON u.id_utilizator = co.id_utilizator 
		JOIN produse_comandate pc ON co.id_comanda = pc.id_comanda
		GROUP BY u.id_utilizator, u.nume_utilizator
  )
SELECT tp.nume_utilizator, tp.pret_total
FROM total_pret tp
WHERE tp.pret_total > ( SELECT AVG(pret_total) FROM total_pret );

SELECT * FROM peste_media_cheltuielilor_2;




--produse mai vandute decat media

--v1
CREATE VIEW produse_mai_vandute_decat_media_1 
    AS
WITH total_cantitate_produs AS 
		(SELECT p.id_produs, p.nume_produs,
			SUM(pc.cantitate) AS cantitate_totala
		FROM produs p
		JOIN produse_comandate pc ON p.id_produs = pc.id_produs
		GROUP BY p.id_produs, p.nume_produs),

medie AS (SELECT AVG(cantitate_totala) AS medie_cantitate
		FROM total_cantitate_produs)

SELECT  t.nume_produs, t.cantitate_totala
FROM total_cantitate_produs t
CROSS JOIN medie m
WHERE t.cantitate_totala > m.medie_cantitate;

SELECT * FROM produse_mai_vandute_decat_media_1;

--v2
CREATE VIEW produse_mai_vandute_decat_media_2
    AS
WITH total_cantitate_produs AS 
		(SELECT p.id_produs, p.nume_produs,
			SUM(pc.cantitate) AS cantitate_totala
		FROM produs p
		JOIN produse_comandate pc ON p.id_produs = pc.id_produs
		GROUP BY p.id_produs, p.nume_produs),

medie AS (SELECT AVG(cantitate_totala) AS medie_cantitate
		FROM total_cantitate_produs)
SELECT id_produs, nume_produs
FROM total_cantitate_produs
WHERE cantitate_totala > (SELECT medie_cantitate FROM medie);

SELECT * FROM produse_mai_vandute_decat_media_2;
