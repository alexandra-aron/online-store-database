-- 2. insert date test
-------------------------------------------------------------------


-- categorii

INSERT INTO categorie(id_categorie, nume_categorie)
VALUES
    (1, 'Carti'),
    (2, 'Rechizite'),
    (3, 'Jucarii'),
    (4, 'Cadouri'),
    (5, 'Electronice');


-- utilizatori

INSERT INTO utilizator(
    id_utilizator,
    nume_utilizator,
    email,
    parola
)
VALUES
    (1, 'Andrei Popescu', 'andrei_popescu@gmail.com', 'hash1'),
    (2, 'Maria Dragomir', 'maria.draga@gmail.com', 'hash2'),
    (3, 'Alex Toma', 'tomalex@gmail.com', 'hash3'),
    (4, 'Ana Maria Dobre', 'ana_dobre@yahoo.com', 'hash4');


-- produse

INSERT INTO produs(
    id_produs,
    nume_produs,
    pret,
    stoc,
    categorie_id
)
VALUES
    (1, 'Carte SQL', 60.66, 20, 1),
    (2, 'Carte Python', 70.00, 15, 1),
    (3, 'Caiet A4', 10.00, 100, 2),
    (4, 'Pix', 5.00, 200, 2),
    (5, 'Masinuta', 50.00, 30, 3),
    (6, 'Papusa', 70.00, 20, 3),
    (7, 'Agenda', 40.00, 25, 4),
    (8, 'Suport casti', 35.00, 10, 4),
    (9, 'Casti', 150.00, 20, 5),
    (10, 'Lampa birou', 120.00, 10, 5);


-- comenzi

INSERT INTO comanda(
    id_comanda,
    id_utilizator,
    pret_total,
    status
)
VALUES
    (1, 1, 130.00, 'finalizata'),
    (2, 2, 60.00, 'in procesare'),
    (3, 3, 150.00, 'finalizata'),
    (4, 4, 200.00, 'in procesare'),
    (5, 2, 120.00, 'finalizata'),
    (6, 4, 253.00, 'finalizata');


-- produse comandate

INSERT INTO produse_comandate(
    id_produse_comandate,
    id_comanda,
    id_produs,
    cantitate,
    pret
)
VALUES
    (1, 1, 1, 1, 60.66),
    (2, 2, 2, 1, 70.00),
    (3, 3, 10, 1, 120.00),
    (4, 4, 9, 1, 150.00),
    (5, 5, 8, 2, 35.00),
    (6, 6, 7, 3, 40.00),
    (7, 1, 6, 2, 70.00),
    (8, 2, 5, 3, 50.00),
    (9, 3, 4, 15, 5.00),
    (10, 4, 8, 20, 35.00);