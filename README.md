# Bază de date Magazin Online (PostgreSQL)

Acest proiect reprezintă o bază de date pentru un magazin online, realizată în PostgreSQL.

Am încercat să simulez un sistem simplu de tip e-commerce, în care există utilizatori, produse, categorii și comenzi, toate legate între ele prin relații în baza de date.

---

## Structura proiectului

Baza de date este formată din mai multe tabele principale:

- utilizatori (clienți)
- produse
- categorii
- comenzi
- produse_comandate (tabel de legătură între comenzi și produse)

Relațiile dintre tabele sunt realizate prin chei primare și chei străine.

---

## Ce am implementat

### 1. Tabele și relații
Am creat tabelele și am definit relațiile dintre ele pentru a menține integritatea datelor.

---

### 2. Constrângeri
Am folosit:
- PRIMARY KEY
- FOREIGN KEY
- NOT NULL
- CHECK (de exemplu pentru stoc și cantitate)
- UNIQUE unde a fost necesar

---

### 3. Triggers
Am implementat trigger-e pentru automatizare:
- verificarea stocului înainte de a adăuga un produs în comandă
- scăderea automată a stocului după comandă
- calcularea automată a prețului total al comenzii

---

### 4. Proceduri stocate
Am creat proceduri pentru:
- crearea unei comenzi
- adăugarea produselor într-o comandă
- anularea unei comenzi și refacerea stocului

---

### 5. Interogări SQL
Am folosit interogări de tip:
- SELECT simple și cu JOIN
- agregări (SUM, COUNT)
- subinterogări
- CTE-uri pentru analize mai complexe

---

### 6. View-uri
Am creat view-uri pentru a afișa mai ușor informații despre comenzi și produse.

---

### 7. Indexuri
Am adăugat indexuri pentru a îmbunătăți performanța anumitor interogări.

---

### 8. Date de test
Am introdus date de test pentru a simula situații reale (clienți, produse, comenzi).

---

## Scopul proiectului

Scopul a fost să înțeleg mai bine cum funcționează o bază de date relațională și să aplic concepte precum:
- modelare de date
- relații între tabele
- automatizare cu triggers
- proceduri stocate
- interogări SQL mai complexe
