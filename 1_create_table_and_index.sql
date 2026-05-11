-- TITLU:
-- magazin online
--------------------------------------------------------------

-- TABELE/ENTITATI:
-- utilizatorii plaseaza comenzi
-- fiecare comanda poate avea mai multe produse
-- produsele apartin unei categorii
-- tabelul produse_comandate face legatura intre comenzi si produse

-- RELATII:
-- categorie 1 -> n produse
-- utilizator 1 -> n comenzi
-- comanda 1 -> n produse_comandate
-- produs 1 -> n produse_comandate


-- 1. creare tabele + index
--------------------------------------------------------------


-- categorii produse

CREATE TABLE categorie(
    id_categorie BIGSERIAL,
    nume_categorie VARCHAR(100),
    CONSTRAINT categorie_pk PRIMARY KEY (id_categorie)
);


-- utilizatori / clienti

CREATE TABLE utilizator(
    id_utilizator BIGSERIAL,
    nume_utilizator VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    parola VARCHAR(300) NOT NULL,
    data_creata TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT utilizator_pk PRIMARY KEY (id_utilizator)
);


-- catalog produse

CREATE TABLE produs(
    id_produs BIGSERIAL,
    nume_produs VARCHAR(100) NOT NULL,
    pret NUMERIC(10,2) NOT NULL CHECK (pret > 0),
    stoc INT8 NOT NULL CHECK (stoc >= 0),
    categorie_id INT8 NOT NULL,
    CONSTRAINT produs_pk PRIMARY KEY (id_produs),
    CONSTRAINT produs_fk
        FOREIGN KEY (categorie_id)
        REFERENCES categorie(id_categorie)
);


-- lista comenzi

CREATE TABLE comanda(
    id_comanda BIGSERIAL,
    id_utilizator INT8 NOT NULL,
    pret_total NUMERIC(10,2) NOT NULL CHECK (pret_total >= 0),
    status VARCHAR(20) NOT NULL
        CHECK (
            status IN (
                'in procesare',
                'finalizata',
                'anulata'
            )
        ),
    data_creare TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT comanda_pk PRIMARY KEY (id_comanda),
    CONSTRAINT comanda_fk
        FOREIGN KEY (id_utilizator)
        REFERENCES utilizator(id_utilizator)
);


-- liste produse din fiecare comanda
-- nr bucati din fiecare produs

CREATE TABLE produse_comandate(
    id_produse_comandate BIGSERIAL,
    id_comanda INT8 NOT NULL,
    id_produs INT8 NOT NULL,
    cantitate INT8 NOT NULL CHECK (cantitate > 0),
    pret NUMERIC(10,2) NOT NULL CHECK (pret > 0),
    CONSTRAINT produse_comandate_pk PRIMARY KEY (id_produse_comandate),
    CONSTRAINT produse_comandate_fk_1
        FOREIGN KEY (id_comanda)
        REFERENCES comanda(id_comanda),
    CONSTRAINT produse_comandate_fk_2
        FOREIGN KEY (id_produs)
        REFERENCES produs(id_produs)
);



--------------------------------------------------------------

-- optimizare: select produse dupa categorie
CREATE INDEX idx_produs_categorie
ON produs(categorie_id);


-- optimizare: filtrare sau sortare dupa pret
CREATE INDEX idx_produs_pret
ON produs(pret);


-- optimizare: cautarea comenzi ale unui utilizator
CREATE INDEX idx_comanda_utilizator
ON comanda(id_utilizator);


-- optimizare: ordonare comenzi dupa data
CREATE INDEX idx_comanda_data
ON comanda(data_creare ASC);


--optimizare: filtrare dupa status
CREATE INDEX idx_comanda_status
ON comanda(status);


-- optimizare: join-uri id_comanda, id_produs
CREATE INDEX idx_pc_comanda
ON produse_comandate(id_comanda);

CREATE INDEX idx_pc_produs
ON produse_comandate(id_produs);
