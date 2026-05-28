 --MV utilizatori inactivi 

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
