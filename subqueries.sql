-- 1.

CREATE DATABASE auction;

\c auction

CREATE TABLE bidders (
  id SERIAL PRIMARY KEY,
  name text NOT NULL
);

CREATE TABLE items (
  id SERIAL PRIMARY KEY,
  name text NOT NULL,
  initial_price numeric(6, 2) NOT NULL CHECK (initial_price BETWEEN 0.01 AND 1000.00),
  sales_price numeric(6, 2) CHECK (sales_price BETWEEN 0.01 AND 1000.00)
);

CREATE TABLE bids (
  id SERIAL PRIMARY KEY,
  bidder_id integer NOT NULL REFERENCES bidders (id) ON DELETE CASCADE,
  item_id integer NOT NULL REFERENCES items (id) ON DELETE CASCADE,
  amount numeric(6, 2) NOT NULL CHECK (amount BETWEEN 0.01 AND 1000.00)
);

CREATE INDEX ON bids (bidder_id, item_id);

\copy bidders FROM bidders.csv WITH CSV HEADER

\copy items FROM items.csv WITH CSV HEADER

\copy bids FROM bids.csv WITH CSV HEADER
