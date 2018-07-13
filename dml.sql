
-- 1.

CREATE DATABASE workshop;
/c workshop

CREATE TABLE devices (
  id serial PRIMARY KEY,
  name text NOT NULL,
  created_at timestamp DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE parts (
  id serial PRIMARY KEY,
  part_number integer UNIQUE NOT NULL,
  device_id integer REFERENCES devices (id)
);

-- 2.

INSERT INTO devices (name)
VALUES ('Accelerometer'),
       ('Gyroscope');

INSERT INTO parts (part_number, device_id)
VALUES (123, 1), (456, 1), (789, 1),
       (12, 2), (34, 2), (56, 2), (78, 2), (90, 2);

INSERT INTO parts (part_number)
VALUES (123456),
       (654321),
       (098765);

-- 3.

SELECT devices.name, parts.part_number FROM devices
INNER JOIN parts ON device_id = devices.id;

-- 4.

SELECT * FROM parts WHERE part_number::text LIKE '3%';

-- 5.

SELECT devices.name, count(parts.id) FROM devices
INNER JOIN parts ON devices.id = parts.device_id
GROUP BY devices.name;

-- 6.

SELECT devices.name, count(parts.id) FROM devices
INNER JOIN parts ON devices.id = parts.device_id
GROUP BY devices.name ORDER BY devices.name;

-- 7.

SELECT part_number, device_id FROM parts
WHERE device_id IS NOT NULL ORDER BY device_id;

SELECT part_number, device_id FROM parts
WHERE device_id IS NULL ORDER BY part_number;

-- 8.

SELECT name FROM devices ORDER BY created_at LIMIT 1;

-- 9.

UPDATE parts SET device_id = 1 WHERE id=7 OR id=8;

UPDATE parts SET device_id = 1
WHERE id=(SELECT id FROM parts ORDER BY part_number LIMIT 1);

-- 10.

DELETE FROM parts WHERE device_id = 1;
DELETE FROM devices WHERE name = 'Accelerometer';
