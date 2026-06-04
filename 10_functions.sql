-- 1. Vanzari anul curent
CREATE OR REPLACE FUNCTION vanzari_anul_curent()
RETURNS FLOAT AS $$
DECLARE 
    v_suma FLOAT;
BEGIN
    SELECT COALESCE(SUM(pc.pret * pc.cantitate),0)
    INTO v_suma
    FROM produse_comandate pc
    JOIN comanda co ON pc.id_comanda = co.id_comanda
    WHERE EXTRACT(YEAR FROM co.data_creare) = EXTRACT(YEAR FROM NOW());

    RETURN v_suma;
END;
$$ LANGUAGE plpgsql;


-- 2. Total comenzi utilizator
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


-- 3. Produse din categorie
CREATE OR REPLACE FUNCTION produse_din_categorie(p_categorie_id INT)
RETURNS TABLE(
    id_produs BIGINT,
    nume_produs VARCHAR(100),
    pret NUMERIC(10,2),
    stoc BIGINT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT p.id_produs,
           p.nume_produs,
           p.pret,
           p.stoc
    FROM produs p
    WHERE p.categorie_id = p_categorie_id;
END;
$$ LANGUAGE plpgsql;
