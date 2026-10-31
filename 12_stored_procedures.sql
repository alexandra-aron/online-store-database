-- PROCEDURĂ: CREARE COMANDĂ
-- Rol: creează o comandă nouă pentru un client

CREATE OR REPLACE PROCEDURE creeaza_comanda(
    p_id_client INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO comanda (id_client, data_comanda, pret_total)
    VALUES (p_id_client, NOW(), 0);

    RAISE NOTICE 'Comanda a fost creata cu succes!';
END;
$$;

-- PROCEDURĂ: ADAUGĂ PRODUS ÎN COMANDĂ
-- Rol: adaugă un produs într-o comandă existentă

CREATE OR REPLACE PROCEDURE adauga_produs_in_comanda(
    p_id_comanda INT,
    p_id_produs INT,
    p_cantitate INT,
    p_pret NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO produse_comandate (id_comanda, id_produs, cantitate, pret)
    VALUES (p_id_comanda, p_id_produs, p_cantitate, p_pret);

    RAISE NOTICE 'Produs adaugat in comanda!';
END;
$$;


-- PROCEDURĂ: ANULARE COMANDĂ
-- Rol: șterge comanda și readuce stocul produselor

CREATE OR REPLACE PROCEDURE anuleaza_comanda(
    p_id_comanda INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Refacem stocul
    UPDATE produs p
    SET stoc = p.stoc + pc.cantitate
    FROM produse_comandate pc
    WHERE pc.id_produs = p.id_produs
      AND pc.id_comanda = p_id_comanda;

    -- Ștergem produsele din comandă
    DELETE FROM produse_comandate
    WHERE id_comanda = p_id_comanda;

    -- Ștergem comanda
    DELETE FROM comanda
    WHERE id_comanda = p_id_comanda;

    RAISE NOTICE 'Comanda a fost anulata!';
END;
$$;
