UPDATE utilizator SET data_creata = data_creata - interval'5 days' WHERE id_utilizator IN (2,3);

INSERT INTO utilizator(id_utilizator, nume_utilizator, email, parola, data_creata) VALUES (5,'Ion Ion','ion.ion@gmail.com','!@wsDCt%%','2021-05-03');
INSERT INTO comanda(id_comanda, id_utilizator, pret_total, status, data_creare) VALUES (7,5, 190, 'finalizata', '2022-03-12');
INSERT INTO produse_comandate(id_produse_comandate, id_comanda, id_produs, cantitate, pret) VALUES (11, 7, 7, 1, 40), (12, 7, 9,1,150);

INSERT INTO utilizator(id_utilizator, nume_utilizator, email, parola, data_creata) VALUES (6,'Ioan Ionescu','ioan.io@gmail.com','!@ws34235DCt%%','2023-01-01');

