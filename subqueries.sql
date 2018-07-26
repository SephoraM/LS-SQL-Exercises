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

-- 2.

SELECT name AS "Bid on Items"
FROM items
WHERE id IN (SELECT DISTINCT item_id FROM bids);

-- 3.

SELECT name AS "Not Bid On"
FROM items
WHERE id NOT IN (SELECT DISTINCT item_id FROM bids);

-- 4.

SELECT name FROM bidders
WHERE EXISTS (SELECT 1 FROM bids WHERE bidder_id = bidders.id);

-- further exploration

SELECT DISTINCT bidders.name
FROM bidders
JOIN bids
  ON bids.bidder_id = bidders.id;

-- 5.

SELECT name AS "Highest Bid Less Than 100 Dollars"
FROM items
WHERE 100.00 > ANY
  (SELECT amount FROM bids WHERE items.id = item_id);

SELECT name AS "Highest Bid Less Than 100 Dollars"
FROM items
WHERE 100.00 > ALL
  (SELECT amount FROM bids WHERE items.id = item_id);

-- further exploration

SELECT name AS "Highest Bid Less Than 100 Dollars"
FROM items
WHERE 100.00 > ALL
  (SELECT amount FROM bids WHERE items.id = item_id)
  AND EXISTS
    (SELECT 1 FROM bids WHERE items.id = item_id);


-- 6.

SELECT MAX(bidder_count.count) FROM
  (SELECT COUNT(id) FROM bids GROUP BY bidder_id) AS bidder_count;

-- 7.

SELECT name,
  (SELECT COUNT(bids.item_id) FROM bids WHERE bids.item_id = items.id)
FROM items;

-- further exploration

SELECT items.name, COUNT(bids.item_id)
FROM items
LEFT OUTER JOIN bids
ON bids.item_id = items.id
GROUP BY items.name;

-- 8.

SELECT id FROM items WHERE (name, initial_price, sales_price) = ('Painting', 100.00, 250.00);

-- 9.

EXPLAIN SELECT name FROM bidders
WHERE EXISTS (SELECT 1 FROM bids WHERE bids.bidder_id = bidders.id);
                                QUERY PLAN
--------------------------------------------------------------------------
 Hash Join  (cost=33.38..66.47 rows=635 width=32)
   Hash Cond: (bidders.id = bids.bidder_id)
   ->  Seq Scan on bidders  (cost=0.00..22.70 rows=1270 width=36)
   ->  Hash  (cost=30.88..30.88 rows=200 width=4)
         ->  HashAggregate  (cost=28.88..30.88 rows=200 width=4)
               Group Key: bids.bidder_id
               ->  Seq Scan on bids  (cost=0.00..25.10 rows=1510 width=4)
(7 rows)

EXPLAIN ANALYZE SELECT name FROM bidders
WHERE EXISTS (SELECT 1 FROM bids WHERE bids.bidder_id = bidders.id);
                                QUERY PLAN
---------------------------------------------------------------------------------------------------------------------
Hash Join  (cost=33.38..66.47 rows=635 width=32) (actual time=0.061..0.065 rows=6 loops=1)
Hash Cond: (bidders.id = bids.bidder_id)
->  Seq Scan on bidders  (cost=0.00..22.70 rows=1270 width=36) (actual time=0.013..0.014 rows=7 loops=1)
->  Hash  (cost=30.88..30.88 rows=200 width=4) (actual time=0.030..0.030 rows=6 loops=1)
Buckets: 1024  Batches: 1  Memory Usage: 9kB
->  HashAggregate  (cost=28.88..30.88 rows=200 width=4) (actual time=0.025..0.026 rows=6 loops=1)
Group Key: bids.bidder_id
->  Seq Scan on bids  (cost=0.00..25.10 rows=1510 width=4) (actual time=0.008..0.013 rows=26 loops=1)
Planning time: 0.193 ms
Execution time: 0.100 ms
(10 rows)


-- PostgreSQL has established the query plan that it'll use to perform the query.
-- In the output from the EXPLAIN clause, we can see that the plan will use a
-- hash join to load bidders into a hash table.
-- It'll do this with a sequential scan, as this is a small table it is the most
-- efficient alogrithm in this case. Once the hash table is loaded into memory,
-- a sequential scan will be executed on bids using the condition as a filter
-- on every row probing the loaded hash table on every row.
-- When ANALYZE is included in the statement, the query is actually run and the
-- actual times are given as well as some information about the memory that'll be
-- affected.

-- 10.

EXPLAIN ANALYZE SELECT MAX(bid_counts.count) FROM
  (SELECT COUNT(bidder_id) FROM bids GROUP BY bidder_id) AS bid_counts;
                                                  QUERY PLAN
---------------------------------------------------------------------------------------------------------------
 Aggregate  (cost=37.15..37.16 rows=1 width=8) (actual time=0.046..0.046 rows=1 loops=1)
   ->  HashAggregate  (cost=32.65..34.65 rows=200 width=12) (actual time=0.041..0.043 rows=6 loops=1)
         Group Key: bids.bidder_id
         ->  Seq Scan on bids  (cost=0.00..25.10 rows=1510 width=4) (actual time=0.013..0.017 rows=26 loops=1)
 Planning time: 0.110 ms
 Execution time: 0.097 ms
(6 rows)

EXPLAIN ANALYZE SELECT COUNT(bidder_id) AS max_bid FROM bids
  GROUP BY bidder_id
  ORDER BY max_bid DESC
  LIMIT 1;
                                                       QUERY PLAN
  ---------------------------------------------------------------------------------------------------------------------
   Limit  (cost=35.65..35.65 rows=1 width=12) (actual time=0.055..0.055 rows=1 loops=1)
     ->  Sort  (cost=35.65..36.15 rows=200 width=12) (actual time=0.054..0.054 rows=1 loops=1)
           Sort Key: (count(bidder_id)) DESC
           Sort Method: top-N heapsort  Memory: 25kB
           ->  HashAggregate  (cost=32.65..34.65 rows=200 width=12) (actual time=0.031..0.033 rows=6 loops=1)
                 Group Key: bidder_id
                 ->  Seq Scan on bids  (cost=0.00..25.10 rows=1510 width=4) (actual time=0.011..0.015 rows=26 loops=1)
   Planning time: 0.112 ms
   Execution time: 0.092 ms
  (9 rows)

  --
