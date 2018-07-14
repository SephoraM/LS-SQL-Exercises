-- 1.

CREATE DATABASE billing;

\c billing

CREATE TABLE customers (
  id serial PRIMARY KEY,
  name text NOT NULL,
  payment_token char(8) UNIQUE CHECK (payment_token ~ '^[A-Z]{8}$')
);

CREATE TABLE services (
  id serial PRIMARY KEY,
  description text NOT NULL,
  price numeric(10, 2) NOT NULL CHECK (price >= 0.00)
);

INSERT INTO customers (name, payment_token)
VALUES
  ('Pat Johnson', 'XHGOAHEQ'),
  ('Nancy Monreal', 'JKWQPJKL'),
  ('Lynn Blake', 'KLZXWEEE'),
  ('Chen Ke-Hua', 'KWETYCVX'),
  ('Scott Lakso', 'UUEAPQPS'),
  ('Jim Pornot', 'XKJEYAZA');

INSERT INTO services (description, price)
VALUES
  ('Unix Hosting', 5.95),
  ('DNS', 4.95),
  ('Whois Registration', 1.95),
  ('High Bandwidth', 15.00),
  ('Business Support', 250.00),
  ('Dedicated Hosting', 50.00),
  ('Bulk Email', 250.00),
  ('One-to-one Training', 999.00);

CREATE TABLE customers_services (
  id serial PRIMARY KEY,
  customer_id integer REFERENCES customers (id)
    ON DELETE CASCADE,
  service_id integer REFERENCES services (id),
  UNIQUE(customer_id, service_id)
);

INSERT INTO customers_services (customer_id, service_id)
VALUES
  (1, 1), (1, 2), (1, 3),
  (3, 1), (3, 2), (3, 3), (3, 4), (3, 5),
  (4, 1), (4, 4),
  (5, 1), (5, 2), (5, 6),
  (6, 1), (6, 6), (6, 7);

-- 2.

SELECT customers.id, customers.name, string_agg(payment_token, ', ')
  FROM customers
    INNER JOIN customers_services
            ON customers_services.customer_id = customers.id
 GROUP BY customers.id
 ORDER BY customers.id;

-- 3.

SELECT customers.* FROM customers
LEFT JOIN customers_services
       ON customers_services.customer_id = customers.id
WHERE customers_services.customer_id IS NULL;

-- further exploration

SELECT customers.*, services.*
  FROM customers
    FULL OUTER JOIN customers_services
                 ON customers_services.customer_id = customers.id
    FULL OUTER JOIN services
                 ON customers_services.service_id = services.id
  WHERE customers_services.customer_id IS NULL
      OR customers_services.service_id IS NULL;

-- 4.

SELECT services.description
  FROM customers_services
    RIGHT OUTER JOIN services
                  ON services.id = customers_services.service_id
  WHERE customers_services.service_id IS NULL;

  -- 5.

SELECT c.name, string_agg(s.description, ', ') AS "services"
  FROM customers AS c
    LEFT OUTER JOIN customers_services AS cs
                 ON cs.customer_id = c.id
    LEFT OUTER JOIN services AS s
                 ON s.id = cs.service_id
  GROUP BY c.name;

-- further exploration

SELECT CASE customers.name
         WHEN (lag(customers.name) OVER (ORDER BY customers.name)) THEN NULL
         ELSE customers.name
       END,
       services.description
FROM customers
LEFT OUTER JOIN customers_services
             ON customer_id = customers.id
LEFT OUTER JOIN services
             ON services.id = service_id;

-- 6.

SELECT services.description, count(customers_services.customer_id) AS count
FROM services
INNER JOIN customers_services
        ON customers_services.service_id = services.id
GROUP BY services.description
  HAVING count(customers_services.customer_id) >= 3
ORDER BY services.description;

-- 7.

SELECT sum(services.price) AS gross FROM services
INNER JOIN customers_services
        ON customers_services.service_id = services.id;

-- 8.

INSERT INTO customers (name, payment_token)
VALUES ('John Doe', 'EYODHLCN');

INSERT INTO customers_services (customer_id, service_id)
VALUES (7, 1), (7, 2), (7, 3);

-- 9.

SELECT sum(services.price) FROM services
INNER JOIN customers_services
        ON customers_services.service_id = services.id
WHERE services.price > 100.00;

SELECT sum(price) * (SELECT count(id) FROM customers) AS sum
FROM services
WHERE price > 100.00;

-- 10.

DELETE FROM customers WHERE name = 'Chen Ke-Hua';

DELETE FROM customers_services WHERE service_id = 7;

DELETE FROM services WHERE id = 7;
