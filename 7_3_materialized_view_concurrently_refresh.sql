 --1. MV utilizatori inactivi 

CREATE MATERIALIZED VIEW utilizatori_inactivi
	AS
WITH data_maxima_comanda AS (SELECT id_utilizator, MAX(data_creare) AS max_data_creare FROM comanda
							GROUP BY id_utilizator
	)
SELECT u.id_utilizator, u.nume_utilizator, co.max_data_creare AS max_data_comanda
					FROM utilizator u
					LEFT JOIN data_maxima_comanda co ON u.id_utilizator = co.id_utilizator
					WHERE co.id_utilizator IS NULL OR (co.id_utilizator IS NOT NULL AND co.max_data_creare < NOW()-interval'30 days');
					------nu are nicio comanda --- SAU -are cel putin o comanda face join si data maxima a creari ultimei comenzi e mai veche de 30 zile conform max din cte)


CREATE UNIQUE INDEX CONCURRENTLY utilizatori_inactivi_unique_idx ON utilizatori_inactivi USING btree(id_utilizator);
					
REFRESH MATERIALIZED VIEW CONCURRENTLY utilizatori_inactivi;





-- 2. MV produse foarte populare dar cu stoc mic

CREATE MATERIALIZED VIEW produse_populare_stoc_mic 
	AS
WITH cantitati_totale_vandute AS (SELECT p.id_produs, SUM(pc.cantitate) AS cantitate_totala, p.stoc
								  FROM produse_comandate pc
								  JOIN produs p ON pc.id_produs = p.id_produs
								  GROUP BY p.id_produs,p.stoc
	),
medie AS (
	SELECT ROUND(AVG(cantitate_totala),2) AS medie_cantitate 
	FROM cantitati_totale_vandute
	)
SELECT ctv.id_produs, ctv.cantitate_totala, m.medie_cantitate
FROM cantitati_totale_vandute ctv
CROSS JOIN medie m 
WHERE ctv.cantitate_totala > m.medie_cantitate AND ctv.stoc < 20 ;

CREATE UNIQUE INDEX CONCURRENTLY produse_populare_stoc_mic_unique_idx ON produse_populare_stoc_mic USING btree(id_produs);

REFRESH MATERIALIZED VIEW CONCURRENTLY produse_populare_stoc_mic;





--- 3. Top categorie dupa venit 

CREATE MATERIALIZED VIEW top_categorie_dupa_venit
	AS 
WITH total_venit_si_categorie AS (SELECT cat.id_categorie , 
										 cat.nume_categorie, 
										 SUM(pc.cantitate*pc.pret) AS venit_total
										 FROM categorie cat 
										 JOIN produs p ON cat.id_categorie = p.categorie_id
										 JOIN produse_comandate pc ON p.id_produs = pc.id_produs
										 GROUP BY cat.id_categorie, cat.nume_categorie 
	)
SELECT id_categorie, nume_categorie, venit_total
FROM total_venit_si_categorie
ORDER BY venit_total DESC
LIMIT 1;

CREATE UNIQUE INDEX CONCURRENTLY top_categorie_dupa_venit_unique_idx ON top_categorie_dupa_venit USING btree(id_categorie);

REFRESH MATERIALIZED VIEW CONCURRENTLY top_categorie_dupa_venit;




--- 4. Produsul favorit al fiecarui utilizator 

CREATE MATERIALIZED VIEW produs_favorit_al_fiecarui_utilizator 
	AS 
WITH cantitate_totala_produs AS (SELECT u.id_utilizator, 
										u.nume_utilizator,
										p.id_produs,
										p.nume_produs,
										SUM(pc.cantitate) AS cantitate_totala
								FROM utilizator u
								JOIN comanda co ON u.id_utilizator = co.id_utilizator 
								JOIN produse_comandate pc ON co.id_comanda = pc.id_comanda
								JOIN produs p ON pc.id_produs = p.id_produs
								GROUP BY u.id_utilizator, u.nume_utilizator,p.id_produs,p.nume_produs
	),
	maxim_per_utilizator AS (SELECT id_utilizator,
									MAX(cantitate_totala) AS maxim_cantitate
							 FROM cantitate_totala_produs
							 GROUP BY id_utilizator
	)
SELECT ctp.id_utilizator, 
	   ctp.nume_utilizator,
	   STRING_AGG(ctp.nume_produs::TEXT,', '),
	   ctp.cantitate_totala
FROM cantitate_totala_produs ctp
JOIN maxim_per_utilizator mpu ON ctp.id_utilizator = mpu.id_utilizator AND ctp.cantitate_totala = mpu.maxim_cantitate
GROUP BY ctp.id_utilizator, 
	   ctp.nume_utilizator,
		ctp.cantitate_totala;
		
CREATE UNIQUE INDEX CONCURRENTLY produs_favorit_al_fiecarui_utilizator_unique_idx ON produs_favorit_al_fiecarui_utilizator USING btree(id_utilizator);

REFRESH MATERIALIZED VIEW CONCURRENTLY produs_favorit_al_fiecarui_utilizator;




--- 5. Cea mai mare comanda per utilizator 

CREATE MATERIALIZED VIEW valoare_maxima_comanda_per_utilizator 
	AS 
WITH valoare_maxima_comanda AS (SELECT  u.id_utilizator, 
										u.nume_utilizator, 
										co.id_comanda, 
										SUM(pc.cantitate * pc.pret) AS valoare_comanda
										FROM utilizator u
										JOIN comanda co ON u.id_utilizator = co.id_utilizator
										JOIN produse_comandate pc ON co.id_comanda = pc.id_comanda
										GROUP BY u.id_utilizator, u.nume_utilizator, co.id_comanda
	),
	maxim AS (SELECT id_utilizator, MAX(valoare_comanda) AS maxim_bani 
		FROM valoare_maxima_comanda
		GROUP BY id_utilizator
	)
SELECT vmc.id_utilizator, vmc.nume_utilizator, m.maxim_bani
FROM valoare_maxima_comanda vmc
JOIN maxim m ON vmc.id_utilizator = m.id_utilizator AND vmc.valoare_comanda=m.maxim_bani;

CREATE UNIQUE INDEX CONCURRENTLY valoare_maxima_comanda_per_utilizator_unique_idx ON valoare_maxima_comanda_per_utilizator USING btree(id_utilizator);

REFRESH MATERIALIZED VIEW CONCURRENTLY valoare_maxima_comanda_per_utilizator;






--- 6, Categoria preferata a fiecarui utilizator 

CREATE MATERIALIZED VIEW categorie_preferata 
	AS 
WITH utilizator_total_cheltuit AS (SELECT u.id_utilizator, 
										  u.nume_utilizator, 
                                          co.id_comanda, 
                                          SUM(pc.cantitate * pc.pret) AS total_cheltuit,
										  cat.id_categorie,
										  cat.nume_categorie
									FROM categorie cat 
									JOIN produs p ON cat.id_categorie = p.categorie_id
									JOIN produse_comandate pc ON p.id_produs = pc.id_produs
									JOIN comanda co ON pc.id_comanda = co.id_comanda
									JOIN utilizator u ON co.id_utilizator = u.id_utilizator
									GROUP BY u.id_utilizator, u.nume_utilizator,co.id_comanda,cat.id_categorie,cat.nume_categorie
	),		
	valoare_maxima_suma AS (SELECT id_utilizator,
							MAX(total_cheltuit) as maxim_cheltuit
							FROM utilizator_total_cheltuit
							GROUP BY id_utilizator
	)
SELECT utc.id_utilizator, utc.nume_utilizator, utc.id_categorie, utc.nume_categorie
FROM utilizator_total_cheltuit utc
JOIN valoare_maxima_suma vms ON utc.id_utilizator = vms.id_utilizator AND utc.total_cheltuit = vms.maxim_cheltuit;

CREATE UNIQUE INDEX CONCURRENTLY categorie_preferata_unique_idx ON categorie_preferata USING btree(id_utilizator);

REFRESH MATERIALIZED VIEW CONCURRENTLY categorie_preferata;
					


