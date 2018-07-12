
-- 1. In terminal - createdb extrasolar, then - psql -d extrasolar
-- or in psql - CREATE DATABASE extrasolar ,then - \c extrasolar
CREATE TABLE stars (
  id serial PRIMARY KEY,
  name varchar(20) NOT NULL UNIQUE,
  distance integer NOT NULL,
  spectral_type char(1) NOT NULL,
  companions integer NOT NULL,
  CHECK (distance > 0),
  CHECK (companions > 0),
  CHECK (length(spectral_type) = 1)
);

CREATE TABLE planets (
  id serial PRIMARY KEY,
  designation char(1) UNIQUE,
  mass integer
);

-- 2.

ALTER TABLE planets
ADD COLUMN star_id integer NOT NULL REFERENCES stars(id);

-- 3.

ALTER TABLE stars
ALTER COLUMN name TYPE varchar(50);

-- 4.

ALTER TABLE stars
ALTER COLUMN distance TYPE numeric;

-- 5.

ALTER TABLE stars
ADD CHECK (spectral_type IN ('O', 'B', 'A', 'F', 'G', 'K', 'M')),
ALTER COLUMN spectral_type SET NOT NULL;

-- 6.

ALTER TABLE stars DROP CONSTRAINT stars_spectral_type_check;
ALTER TABLE stars DROP CONSTRAINT stars_spectral_type_check1;

CREATE TYPE spectral_types AS ENUM ('O', 'B', 'A', 'F', 'G', 'K', 'M');

ALTER TABLE stars
ALTER COLUMN spectral_type TYPE spectral_types
                          USING spectral_type::spectral_types;

-- 7.

ALTER TABLE planets
ALTER COLUMN designation SET NOT NULL,
ALTER COLUMN mass SET NOT NULL,
ALTER COLUMN mass TYPE numeric,
ADD CHECK (mass > 0);

-- 8.

ALTER TABLE planets
ADD COLUMN semi_major_axis numeric NOT NULL;

-- further exploration

ALTER TABLE planets
ADD COLUMN semi_major_axis numeric;

UPDATE planets
SET semi_major_axis = 0.04 WHERE star_id = 1;

UPDATE planets
SET semi_major_axis = 40 WHERE star_id = 2;

ALTER TABLE planets
ALTER COLUMN semi_major_axis SET NOT NULL;

-- 9.

CREATE TABLE moons (
  id serial PRIMARY KEY,
  designation integer NOT NULL CHECK (designation > 0),
  semi_major_axis numeric CHECK (semi_major_axis > 0.0),
  mass numeric CHECK (mass > 0.0),
  star_id integer NOT NULL REFERENCES planets(id)
);

-- 10.

\c sql_course
DROP DATABASE extrasolar;
