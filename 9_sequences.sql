
SELECT MAX(id_produs) FROM produs;



CREATE SEQUENCE produs_seq START WITH 11;


ALTER TABLE produs 
ALTER COLUMN id_produs SET DEFAULT nextval('produs_seq');

SELECT * FROM produs;



SELECT MAX(id_categorie) FROM categorie;

SELECT MAX(id_categorie) FROM categorie; --- 5 

CREATE SEQUENCE categorie_seq START WITH 6;

ALTER TABLE categorie
ALTER COLUMN id_categorie SET DEFAULT nextval('categorie_seq');



SELECT MAX(id_produse_comandate) FROM produse_comandate; ---13 

CREATE SEQUENCE produse_comandate_seq START WITH 14;

ALTER TABLE produse_comandate
ALTER COLUMN id_produse_comandate SET DEFAULT nextval('produse_comandate_seq');




SELECT MAX(id_comanda) FROM comanda; --- 8


CREATE SEQUENCE comanda_seq START WITH 9;

ALTER TABLE comanda
ALTER COLUMN id_comanda SET DEFAULT nextval('comanda_seq');


SELECT MAX(id_utilizator) FROM utilizator; --6

CREATE SEQUENCE utilizator_seq START WITH 7;

ALTER TABLE utilizator
ALTER COLUMN id_utilizator SET DEFAULT nextval('utilizator_seq');
