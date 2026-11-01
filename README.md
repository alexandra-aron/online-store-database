# Online Store Database (PostgreSQL)

This is the database behind a simple online shop: users, products, categories and orders. I wanted to go past just creating tables and see how much of the business logic can live in the database itself, so a big part of the project is triggers, procedures and views.

Table names are in Romanian (`utilizatori` = users, `produse` = products, `categorii` = categories, `comenzi` = orders, `produse_comandate` = the link table between orders and products).

## What I implemented

**Tables and constraints.** Primary and foreign keys, `NOT NULL`, `UNIQUE` where it made sense, and `CHECK` constraints so that, for example, stock and quantities can't go negative.

**Triggers.** When a product is added to an order, a trigger checks there is enough stock, subtracts it, and recalculates the order total. So the order total never has to be updated by hand.

**Stored procedures.** Creating an order, adding products to it, and cancelling an order (which also puts the products back in stock).

**Queries.** From simple joins to aggregates, subqueries and CTEs for reports such as how much each user has spent, which products bring in more than the average, and which category makes the most money.

**Views and materialized views.** Views for order details, one with rankings (`RANK() OVER`), and materialized views for heavier reports, including refreshing them with `REFRESH MATERIALIZED VIEW CONCURRENTLY`.

**Indexes and sequences.** Indexes on the columns used most in joins and filters, plus a few custom sequences.

**Foreign data wrapper.** `13_foreign_server_to_curier_db.sql` connects this database to my [courier database](https://github.com/alexandra-aron/curier_DB) with `postgres_fdw`. The courier tables are imported into a separate schema, so they can be queried from inside the shop database as if they were local.

## Running it

Create an empty database, then run the SQL files in numerical order (`1_...` to `13_...`). The file `2_insert_test_dummy_data.sql` adds the test data and `7_2_add_more_dummy_data.sql` adds more rows, which is useful for seeing the indexes and materialized views make a difference.

The schema diagram (made with dbdiagram.io) is in the PDF in this repo.

## Why I made it

I'm coming to software engineering from physics, and this project was my way of really understanding relational databases: modelling the data, keeping it consistent, and deciding what logic belongs in the database and what doesn't.
