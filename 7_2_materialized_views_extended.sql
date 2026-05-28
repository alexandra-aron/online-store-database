---1 . Total comenzi per utilizator ---

CREATE MATERIALIZED VIEW comenzi_per_utilizator 
  AS
WITH total_comenzi AS (SELECT u.id_utilizator,
					          COUNT(co.id_comanda) AS numar_total_comenzi
					   FROM utilizator u 
					   JOIN comanda co ON u.id_utilizator = co.id_utilizator
					   GROUP BY u.id_utilizator
  )
SELECT u.nume_utilizator, tc.numar_total_comenzi
FROM total_comenzi tc 
JOIN utilizator u ON u.id_utilizator = tc.id_utilizator;
							  
SELECT * FROM comenzi_per_utilizator;

REFRESH MATERIALIZED VIEW comenzi_per_utilizator;



--- 2. Total bani cheltuiti per utilizator --

CREATE MATERIALIZED VIEW total_bani_cheltuiti_per_utilizator 
  AS
WITH total_bani AS (SELECT u.nume_utilizator, u.id_utilizator, SUM(co.pret_total) AS total
					FROM utilizator u
					JOIN comanda co ON u.id_utilizator = co.id_utilizator
					GROUP BY u.nume_utilizator,u.id_utilizator
  )
SELECT nume_utilizator, total
FROM total_bani;

SELECT * FROM total_bani_cheltuiti_per_utilizator;

REFRESH MATERIALIZED VIEW total_bani_cheltuiti_per_utilizator;


  
---- 3. Total produse vandute pentru fiecare produs cantitatea totala vanduta ----

CREATE MATERIALIZED VIEW total_produse_vandute 
  AS 
WITH cantitate_totala_pe_produs AS 
			(SELECT pc.id_produs AS id_produs, 
			        p.nume_produs AS nume_produs,
			        SUM(pc.cantitate) AS cantitate_totala_vanduta,
			        SUM(pc.cantitate*pc.pret) AS pret_total
			FROM produse_comandate pc
			JOIN produs p ON pc.id_produs = p.id_produs
			JOIN comanda co ON pc.id_comanda = co.id_comanda
			GROUP BY p.nume_produs,pc.id_produs
  )
SELECT id_produs, nume_produs, cantitate_totala_vanduta, pret_total
FROM cantitate_totala_pe_produs;

SELECT * FROM total_produse_vandute;

REFRESH MATERIALIZED VIEW total_produse_vandute;



------4. produse cu stoc mic sub 20 produsul si categoria ------------

CREATE MATERIALIZED VIEW stoc_mic 
  AS
WITH stoc_mic AS (
    SELECT 
        p.id_produs,
        p.nume_produs,
        p.stoc,
        c.nume_categorie
    FROM produs p
    JOIN categorie c ON p.categorie_id = c.id_categorie
)
SELECT *
FROM stoc_mic
WHERE stoc < 20;

SELECT * FROM stoc_mic;

REFRESH MATERIALIZED VIEW stoc_mic;



----- 5. total bani generati pe categorie --

CREATE MATERIALIZED VIEW bani_pe_categorie AS

WITH total_pe_categorie AS 
		(SELECT cat.id_categorie, cat.nume_categorie, SUM(pc.cantitate*pc.pret) AS suma_totala_incasata
		FROM categorie cat
		JOIN produs p ON cat.id_categorie = p.categorie_id
		JOIN produse_comandate pc ON p.id_produs = pc.id_produs
		GROUP BY cat.id_categorie, cat.nume_categorie
  )
SELECT nume_categorie, suma_totala_incasata
FROM total_pe_categorie
ORDER BY suma_totala_incasata DESC;

SELECT * FROM bani_pe_categorie;

REFRESH MATERIALIZED VIEW bani_pe_categorie;



---6. Utilizatori care au cumpărat peste 5 produse---

CREATE MATERIALIZED VIEW peste_5_produse AS
WITH produse AS 
		(SELECT SUM(pc.cantitate) AS total_cantitate_cumparata,
				u.id_utilizator, u.nume_utilizator,
				p.nume_produs
		FROM utilizator u
		JOIN comanda co ON u.id_utilizator = co.id_utilizator
		JOIN produse_comandate pc ON co.id_comanda = pc.id_comanda
		JOIN produs p ON pc.id_produs = p.id_produs
		GROUP BY u.id_utilizator, u.nume_utilizator
  )
SELECT *
FROM produse
WHERE total_cantitate_cumparata > 5;

SELECT * FROM peste_5_produse;

REFRESH MATERIALIZED VIEW peste_5_produse;




---7. comenzi finalizate -------
CREATE MATERIALIZED VIEW comenzi_finalizate AS
WITH com_finalizate AS 
		(SELECT co.id_comanda, co.status, co.data_creare AS data_plasare,
		        co.pret_total AS total_comanda, u.id_utilizator, u.nume_utilizator
		FROM comanda co 
		JOIN utilizator u ON co.id_utilizator = u.id_utilizator
		)
SELECT nume_utilizator, total_comanda, data_plasare
FROM com_finalizate
WHERE status ILIKE '%finalizata%'
ORDER BY total_comanda DESC;

SELECT * FROM comenzi_finalizate;

REFRESH MATERIALIZED VIEW comenzi_finalizate;




