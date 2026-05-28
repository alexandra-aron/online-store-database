--- Ranking utilizator dupa cheltuieli
-- Afișează:
-- utilizator
-- total
-- rank global

CREATE VIEW top_utilizatori_dupa_cheltuieli 
	AS 
WITH cheltuieli_totale_per_utilizator AS ( SELECT 
												u.id_utilizator, 
												u.nume_utilizator,
												SUM(pc.cantitate*pc.pret) AS suma_totala_cheltuita --pentru fiecare utilizator se face totalul cheltuielilor (pret*cantitate) de la toate comenzile utilizatorului
											FROM utilizator u
											JOIN comanda co ON u.id_utilizator = co.id_utilizator
											JOIN produse_comandate pc ON co.id_comanda = pc.id_comanda
											GROUP BY u.id_utilizator, u.nume_utilizator
	)
SELECT 
	RANK() OVER ( ORDER BY suma_totala_cheltuita DESC ) AS pozitie_clasament, 
		--aici generam pozitia in clasament: pozitia 1 inseaamna utilizatorul cu cele mai mari cheltuieli, pozitia 2 urmatoarele cele mai mari cheltuieli etc.
		--practic: cu cat pozitia in clasament este mai mare, cheltuielile sunt din ce in ce mai mici
		-- punem doar "ORDER BY suma_totala_cheltuita DESC", pentru ca generam un singur clasament pentru toti utilizatorii, NU sub-clasamente (acolo se folosea "PARTITION BY ... ORDER BY ...")
	id_utilizator,
	nume_utilizator, 
	suma_totala_cheltuita
FROM cheltuieli_totale_per_utilizator
ORDER BY pozitie_clasament ASC;


select * from top_utilizatori_dupa_cheltuieli;



--  Top 3 cele mai vandute produse per categorie
CREATE  VIEW top_3_produse_per_categorie 
	AS 
WITH cantitate_totala_per_categorie AS (SELECT cat.id_categorie, cat.nume_categorie,
													SUM(pc.cantitate) AS cantitate_totala, 
													p.id_produs
											FROM categorie cat 
											JOIN produs p ON cat.id_categorie = p.categorie_id
											JOIN produse_comandate pc ON p.id_produs = pc.id_produs
											GROUP BY cat.id_categorie, cat.nume_categorie, p.id_produs
	),
top_produse AS (SELECT RANK() OVER (PARTITION BY id_categorie ORDER BY cantitate_totala DESC) AS numar,
				id_categorie, nume_categorie, id_produs, cantitate_totala
				FROM cantitate_totala_per_categorie
	)
SELECT tp.numar, tp.id_categorie, tp.nume_categorie, tp.id_produs, p.nume_produs, tp.cantitate_totala
FROM top_produse tp
JOIN produs p ON p.id_produs = tp.id_produs 
WHERE numar IN (1,2,3)
ORDER BY tp.id_categorie, numar ;


select * from top_3_produse_per_categorie;
