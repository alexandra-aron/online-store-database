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




--8. top clienti

CREATE MATERIALIZED VIEW top_clienti_mv AS 
SELECT u.id_utilizator, u.nume_utilizator, 
 		SUM(pc.cantitate * pc.pret) AS total_cheltuit,
		COUNT(DISTINCT pc.id_comanda) AS numar_comenzi
		
		FROM utilizator u
		JOIN comanda co ON u.id_utilizator = co.id_utilizator
 		JOIN produse_comandate pc ON co.id_comanda = pc.id_comanda
 		GROUP BY u.id_utilizator , u.nume_utilizator;
		
SELECT * FROM  top_clienti_mv
ORDER BY total_cheltuit DESC;

REFRESH MATERIALIZED VIEW top_clienti_mv;





-- 9. MV vanzari pe zile 

CREATE MATERIALIZED VIEW nr_vanzari_pe_zile AS 
	SELECT co.data_creare AS zi , 
	COUNT(DISTINCT pc.id_comanda) AS numar_comenzi, 
	SUM(pc.cantitate * pc.pret) AS suma_total_vanzari
	FROM comanda co
	JOIN produse_comandate pc ON co.id_comanda = pc.id_comanda
	GROUP BY co.data_creare
	ORDER BY zi DESC;

SELECT * FROM nr_vanzari_pe_zile;

REFRESH MATERIALIZED VIEW nr_vanzari_pe_zile;




--10. produse necomandate

CREATE MATERIALIZED VIEW produse_necomandate 
	AS
SELECT p.id_produs, p.nume_produs 
FROM produs p
LEFT JOIN produse_comandate pc ON p.id_produs = pc.id_produs
WHERE pc.id_produs IS NULL;

SELECT * FROM produse_necomandate;

REFRESH MATERIALIZED VIEW produse_necomandate;





--- 11. MV stoc_critic

CREATE MATERIALIZED VIEW mv_stoc_critic 
	AS
SELECT cat.id_categorie, cat.nume_categorie, p.nume_produs,p.stoc, SUM(pc.cantitate) AS cantitate_vanduta_total
FROM categorie cat
JOIN produs p ON cat.id_categorie = p.categorie_id
JOIN produse_comandate pc ON p.id_produs = pc.id_produs 
WHERE p.stoc < 15
GROUP BY cat.id_categorie, cat.nume_categorie, p.nume_produs,p.stoc;

SELECT * FROM mv_stoc_critic;

REFRESH MATERIALIZED VIEW  mv_stoc_critic;





--12. MV produse premium

CREATE MATERIALIZED VIEW produse_premium 
	AS
WITH total_venit AS (
	SELECT p.id_produs, p.nume_produs, SUM(pc.cantitate*pc.pret) AS venit_total
	FROM produs p
	JOIN produse_comandate pc ON p.id_produs = pc.id_produs
	GROUP BY p.id_produs, p.nume_produs
	),
  medie AS (
	SELECT AVG(venit_total) AS medie_venit 
	FROM total_venit
	)

SELECT id_produs, nume_produs
FROM total_venit tv
CROSS JOIN medie m
WHERE tv.venit_total > m.medie_venit;

SELECT * FROM produse_premium;

REFRESH MATERIALIZED VIEW  produse_premium;





--- 13. clienti premium

CREATE MATERIALIZED VIEW clienti_premium 
	AS
WITH  total_venit_si_comenzi_distincte AS ( SELECT u.id_utilizator, u.nume_utilizator, 
											        SUM(pc.cantitate * pc.pret) AS total_cheltuit,
													COUNT(DISTINCT(co.id_comanda)) AS nr_comenzi
											FROM utilizator u
											JOIN comanda co ON u.id_utilizator = co.id_utilizator
											JOIN produse_comandate pc ON co.id_comanda = pc.id_comanda
											GROUP BY u.id_utilizator, u.nume_utilizator
	),
medie_cheltuieli AS (
	SELECT AVG(total_cheltuit) AS medie 
	FROM total_venit_si_comenzi_distincte
	)
SELECT t.id_utilizator, t.nume_utilizator, t.total_cheltuit, t.nr_comenzi
FROM total_venit_si_comenzi_distincte t
CROSS JOIN medie_cheltuieli m
WHERE t.total_cheltuit > m.medie AND t.nr_comenzi >=2;

SELECT * FROM clienti_premium;

REFRESH MATERIALIZED VIEW  clienti_premium;




--- 14. MV categorii_profitabile 

--v1
CREATE MATERIALIZED VIEW categorii_profitabile1 
	AS
WITH categorie_statistici1 AS 
		(SELECT cat.id_categorie, cat.nume_categorie, 
		        SUM(pc.cantitate* pc.pret) AS total_cheltuit,
				SUM(pc.cantitate) AS total_produse_vandute,
				SUM(pc.cantitate * pc.pret) /  NULLIF(COUNT(DISTINCT p.id_produs),0) AS profit_mediu_per_produs
		FROM categorie cat
		JOIN produs p ON cat.id_categorie =p.id_categorie
		JOIN produse_comandate pc ON pc.id_produs = p.id_produs
		GROUP BY cat.id_categorie, cat.nume_categorie
	)
SELECT * 
FROM  categorie_statistici1
WHERE total_cheltuit > (SELECT AVG(total_cheltuit) FROM categorie_statistici1); 

SELECT * FROM categorii_profitabile1;

REFRESH MATERIALIZED VIEW  categorii_profitabile1;

--- v2
CREATE MATERIALIZED VIEW categorii_profitabile2 
	AS
WITH categorie_statistici2 AS 
		(SELECT cat.id_categorie, cat.nume_categorie, 
		        SUM(pc.cantitate* pc.pret) AS total_cheltuit,
				SUM(pc.cantitate) AS total_produse_vandute,
				SUM(pc.cantitate * pc.pret) / NULLIF(COUNT(DISTINCT p.id_produs),0) AS profit_mediu_per_produs
		FROM categorie cat
		JOIN produs p ON cat.id_categorie =p.id_categorie
		JOIN produse_comandate pc ON pc.id_produs = p.id_produs
		GROUP BY cat.id_categorie, cat.nume_categorie
	),
medie AS (
	SELECT AVG(total_cheltuit) AS medie 
	FROM categorie_statistici2
	)
SELECT * 
FROM categorie_statistici2 cs
CROSS JOIN medie m
WHERE cs.total_cheltuit > m.medie;

SELECT * FROM categorii_profitabile2;

REFRESH MATERIALIZED VIEW  categorii_profitabil2;




-- 15. MV produse rare si scumpe (WHERE c.cantitate_totala_vanduta < m.medie_cantitati AND c.pret > m.media_preturi)

CREATE MATERIALIZED VIEW produse_rare_scumpe 
	AS
WITH cantitati_totale AS (SELECT p.id_produs, p.nume_produs,p.pret
						 SUM(pc.cantitate) AS cantitate_totala_vanduta
						 FROM produs p 
						 JOIN produse_comandate pc ON p.id_produs = pc.id_produs 
						 GROUP BY p.id_produs, p.nume_produs, p.pret
	),
medie AS (SELECT AVG(cantitate_totala_vanduta) AS medie_cantitati,
 				AVG(pret) AS media_preturi
		   FROM cantitate_totala
	)		
SELECT c.id_produs, c.nume_produs, c.pret, c.cantitate_totala_vanduta
FROM cantitati_totale c
CROSS JOIN medie m
WHERE c.cantitate_totala_vanduta < m.medie_cantitati AND c.pret > m.media_preturi;

SELECT * FROM produse_rare_scumpe;

REFRESH MATERIALIZED VIEW  produse_rare_scumpe;




