--presupunem ca folosim user-ul "postgres" ca owner al bazelor de date "curier_db" si "magazin_db"
--alter user postgres with login encrypted password 'PAROLA';

--in baza de date "magazin_db", vom crea o noua schema (alta decat "public")
create schema curier_fdw; --fdw = foreign data wrapper
--aceasta va fi folosita pentru a conecta tabelele din baza "curier_db"

CREATE EXTENSION IF NOT EXISTS postgres_fdw;
--s-a creat extensia de postgres necesara conectarii tabelelor intre baze
--postgres are mai multe extensii care ofera functionalitati diferite, "postgres_fdw" permite de exemplu conectarea unei alte baze Postgres la baza curenta

CREATE SERVER curier_server --numele obiectului de tip server
FOREIGN DATA WRAPPER postgres_fdw --extensia folosita pentru conectare
OPTIONS (
    host 'localhost',
    dbname 'curier_db',
    port '5432'
);
--in interiorul bazei de date magazin_db (baza curenta) s-a creat un obiect de tip "server", adica un intermediar intre baza magazin_db si curier_db
--in server s-a definit conexiunea catre baza de date curier_db (va fi accesibila din interiorul bazei curente "magazin_db")

CREATE USER MAPPING FOR postgres --numele user-ului de postgres, din baza de date sursa "magazin_db" (baza curenta)
SERVER curier_server
OPTIONS (
    user 'postgres', --numele si parola user-ului de postgres, din baza de date destinatie "curire_db" (baza curenta), poate fi si alt user cu drepturi asupra tabelelor
    password 'PAROLA'
);
--user mapping permite folosirea e

IMPORT FOREIGN SCHEMA public --importare tabele din serverul extern, schema "public" (tabelele din baza "curier_db" sunt in schema public)
FROM SERVER curier_server --folosind obiectul server de legatura
INTO curier_fdw; --le importam in schema locala "curier_fdw";


--interogram tabelele externe si interne, in baza "magazin_db"
select * from curier_fdw.colete;
select * from public.comanda;



--adaugare coloana de legatura "id_colet", in tabela de comenzi din baza de date "magazin_db"
--coloana se va completa, in momentul crearii unui 
alter table public.comanda add column id_colet int8 NULL;

--completare date dummy
update public.comanda set id_colet = 1 where id_comanda = 1;
update public.comanda set id_colet = 2 where id_comanda = 2;
update public.comanda set id_colet = 4 where id_comanda = 3;
update public.comanda set id_colet = 6 where id_comanda = 4;
update public.comanda set id_colet = 7 where id_comanda = 5;
update public.comanda set id_colet = 9 where id_comanda = 6;
update public.comanda set id_colet = 10 where id_comanda = 7;
update public.comanda set id_colet = 12 where id_comanda = 8;

--combinare tabele din baza de date "curier_db" si "magazin_db"
select * 
from public.comanda magazin_colet
left join curier_fdw.colete curier_colet on curier_colet.id_colet=magazin_colet.id_colet
