-- =========================================================
-- TRIGGER 1: VERIFICARE + SCĂDERE STOC
-- Rol: verifică stocul și îl scade automat după comandă
-- Se execută BEFORE INSERT în produse_comandate
-- =========================================================

CREATE OR REPLACE FUNCTION gestioneaza_stoc()
RETURNS TRIGGER AS $$
DECLARE
    v_stoc INT;
BEGIN
    -- preluăm stocul curent
    SELECT stoc INTO v_stoc
    FROM produs
    WHERE id_produs = NEW.id_produs;

    -- verificăm dacă există suficient stoc
    IF v_stoc < NEW.cantitate THEN
        RAISE EXCEPTION 'Stoc insuficient pentru produsul selectat!';
    END IF;

    -- scădem stocul
    UPDATE produs
    SET stoc = stoc - NEW.cantitate
    WHERE id_produs = NEW.id_produs;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_gestioneaza_stoc
BEFORE INSERT ON produse_comandate
FOR EACH ROW
EXECUTE FUNCTION gestioneaza_stoc();


-- =========================================================
-- TRIGGER 2: CALCUL TOTAL COMANDĂ
-- Rol: actualizează automat prețul total al comenzii
-- Se execută AFTER INSERT/UPDATE
-- =========================================================

CREATE OR REPLACE FUNCTION calculeaza_total_comanda()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE comanda
    SET pret_total = (
        SELECT SUM(cantitate * pret)
        FROM produse_comandate
        WHERE id_comanda = NEW.id_comanda
    )
    WHERE id_comanda = NEW.id_comanda;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_calculeaza_total_comanda
AFTER INSERT OR UPDATE ON produse_comandate
FOR EACH ROW
EXECUTE FUNCTION calculeaza_total_comanda();


-- =========================================================
-- TRIGGER 3: VALIDARE STOC (BASIC SAFETY CHECK)
-- Rol: oprește inserarea dacă nu există stoc suficient
-- Se execută BEFORE INSERT
-- =========================================================

CREATE OR REPLACE FUNCTION verifica_stoc()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT stoc FROM produs WHERE id_produs = NEW.id_produs) < NEW.cantitate THEN
        RAISE EXCEPTION 'Stoc insuficient! Nu se poate crea comanda.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_verifica_stoc
BEFORE INSERT ON produse_comandate
FOR EACH ROW
EXECUTE FUNCTION verifica_stoc();
