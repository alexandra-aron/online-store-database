--1.
CREATE OR REPLACE FUNCTION vanzari_anul_curent()
RETURNS float AS $$
DECLARE 
	v_suma FLOAT;
BEGIN
  
    SELECT SUM(pc.pret*pc.cantitate) AS pret_total 
    INTO v_suma
    FROM produse_comandate pc
    JOIN comanda co ON pc.id_comanda = co.id_comanda
    WHERE EXTRACT (YEAR FROM co.data_creare) = EXTRACT(YEAR FROM NOW()); --- vanzarile din anul curent

RETURN v_suma;
END;
$$ LANGUAGE plpgsql;

--exemplu
SELECT vanzari_anul_curent();




--2.
CREATE OR REPLACE FUNCTION total_comenzi_utilizator(p_id INT)
RETURNS INT AS $$
DECLARE
    v_total INT;
BEGIN
    SELECT COUNT(*)
    INTO v_total
    FROM comanda
    WHERE id_utilizator = p_id;

    RETURN COALESCE(v_total, 0);
END;
$$ LANGUAGE plpgsql;

--exemplu
SELECT total_comenzi_utilizator(123);
