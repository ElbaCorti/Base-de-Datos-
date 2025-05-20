DROP DATABASE IF EXISTS cultivos;

CREATE DATABASE cultivos;

\c cultivos;

--Borro las tablas si existen
DROP TABLE IF EXISTS public.produccion_agricola CASCADE;

DROP TABLE IF EXISTS public.cultivo CASCADE;

DROP TABLE IF EXISTS public.campania CASCADE;

DROP TABLE IF EXISTS public.departamento CASCADE;

DROP TABLE IF EXISTS public.provincia CASCADE;
--Creamos las tablas finales
CREATE TABLE public.provincia (
    id_provincia INT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE public.departamento (
    id_departamento INT PRIMARY KEY,
    nombre VARCHAR(100),
    id_provincia INT,
    FOREIGN KEY (id_provincia) REFERENCES provincia (id_provincia)
);

CREATE TABLE public.campania (
    id_campania INT PRIMARY KEY,
    anio INT,
    nombre VARCHAR(100)
);

CREATE TABLE public.cultivo (
    id_cultivo INT PRIMARY KEY,
    nombre VARCHAR(100),
    anio INT,
    campania VARCHAR(100),
    id_provincia INT,
    id_departamento INT,
    superficie_sembrada DECIMAL(10, 2),
    superficie_cosechada DECIMAL(10, 2),
    produccion_toneladas DECIMAL(10, 2),
    rendimiento DECIMAL(10, 2),
    FOREIGN KEY (id_provincia) REFERENCES provincia (id_provincia),
    FOREIGN KEY (id_departamento) REFERENCES departamento (id_departamento)
);

CREATE TABLE public.produccion_agricola (
    id_produccion_agricola SERIAL PRIMARY KEY,
    id_cultivo INT,
    id_campania INT,
    superficie_sembrada DECIMAL(10, 2),
    superficie_cosechada DECIMAL(10, 2),
    produccion_toneladas DECIMAL(10, 2),
    FOREIGN KEY (id_cultivo) REFERENCES cultivo (id_cultivo),
    FOREIGN KEY (id_campania) REFERENCES campania (id_campania)
);
--Creo las tablas temporales para cargar los datos
CREATE TEMP TABLE temp_todo (
    cultivo_nombre VARCHAR,
    anio INT,
    campania VARCHAR,
    provincia_nombre VARCHAR,
    provincia_id VARCHAR,
    departamento_nombre VARCHAR,
    departamento_id VARCHAR,
    superficie_sembrada_ha FLOAT,
    superficie_cosechada_ha FLOAT,
    produccion_tm FLOAT,
    rendimiento_kgxha FLOAT
);

--Carga de archivos CSV en las tablas temporales
COPY temp_todo FROM '/csv/maiz-serie-1923-2023.csv' DELIMITER ',' CSV HEADER ENCODING
'UTF8';
COPY temp_todo FROM '/csv/soja-serie-1941-2023.csv' DELIMITER ',' CSV HEADER ENCODING
'UTF8';
COPY temp_todo FROM '/csv/trigo-serie-1927-2024.csv' DELIMITER ',' CSV HEADER ENCODING
'UTF8';

--Insercion de datos unicos y normalizados

-- Provincias
INSERT INTO public.provincia (id_provincia, nombre)
SELECT DISTINCT provincia_id::INT, provincia_nombre
FROM temp_todo
WHERE provincia_id IS NOT NULL
ON CONFLICT (id_provincia) DO NOTHING;

-- Departamentos
INSERT INTO public.departamento (id_departamento, nombre, id_provincia)
SELECT DISTINCT departamento_id::INT, departamento_nombre, provincia_id::INT
FROM temp_todo
WHERE departamento_id IS NOT NULL
ON CONFLICT (id_departamento) DO NOTHING;

-- Campañas
INSERT INTO public.campania (id_campania, anio, nombre)
SELECT DISTINCT anio, anio, campania
FROM temp_todo
WHERE anio IS NOT NULL
ON CONFLICT (id_campania) DO NOTHING;

-- Cultivos
INSERT INTO public.cultivo (
    id_cultivo, nombre, anio, campania,
    id_provincia, id_departamento,
    superficie_sembrada, superficie_cosechada, produccion_toneladas, rendimiento
)
SELECT DISTINCT
    departamento_id::INT, cultivo_nombre, anio, campania,
    provincia_id::INT, departamento_id::INT,
    superficie_sembrada_ha, superficie_cosechada_ha, produccion_tm, rendimiento_kgxha
FROM temp_todo
WHERE departamento_id IS NOT NULL
ON CONFLICT (id_cultivo) DO NOTHING;

-- Producción agrícola
INSERT INTO public.produccion_agricola (
    id_cultivo, id_campania,
    superficie_sembrada, superficie_cosechada, produccion_toneladas
)
SELECT DISTINCT
    departamento_id::INT, anio,
    superficie_sembrada_ha, superficie_cosechada_ha, produccion_tm
FROM temp_todo;