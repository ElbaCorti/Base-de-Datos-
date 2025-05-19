-- SQLBook: Markup

-- SQLBook: Code
-- DROP DATABASE cultivos;
CREATE DATABASE cultivos;

\c cultivos;

-- Elimino tablas si existen
DROP TABLE IF EXISTS public.produccion_agricola;

DROP TABLE IF EXISTS public.cultivo;

DROP TABLE IF EXISTS public.campania;

DROP TABLE IF EXISTS public.departamento;

DROP TABLE IF EXISTS public.provincia;

-- Creo tablas definitivas
CREATE TABLE public.provincia (
    id_provincia INT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE public.departamento (
    id_departamento INT PRIMARY KEY,
    nombre VARCHAR(100),
    id_provincia INT,
    FOREIGN KEY (id_provincia) REFERENCES public.provincia (id_provincia)
);

CREATE TABLE public.campania (
    id_campania SERIAL PRIMARY KEY,
    anio INT,
    nombre VARCHAR(100)
);

CREATE TABLE public.cultivo (
    id_cultivo SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    anio INT,
    campania VARCHAR(100),
    id_provincia INT,
    id_departamento INT,
    superficie_sembrada DECIMAL(10, 2),
    superficie_cosechada DECIMAL(10, 2),
    produccion_toneladas DECIMAL(10, 2),
    rendimiento DECIMAL(10, 2),
    FOREIGN KEY (id_provincia) REFERENCES public.provincia (id_provincia),
    FOREIGN KEY (id_departamento) REFERENCES public.departamento (id_departamento)
);

CREATE TABLE public.produccion_agricola (
    id_produccion_agricola SERIAL PRIMARY KEY,
    id_cultivo INT,
    id_campania INT,
    superficie_sembrada DECIMAL(10, 2),
    superficie_cosechada DECIMAL(10, 2),
    produccion_toneladas DECIMAL(10, 2),
    FOREIGN KEY (id_cultivo) REFERENCES public.cultivo (id_cultivo),
    FOREIGN KEY (id_campania) REFERENCES public.campania (id_campania)
);

-- Tabla temporal única para maíz
CREATE TEMP
TABLE temp_maiz (
    cultivo_nombre VARCHAR,
    anio INT,
    campania VARCHAR,
    provincia_nombre VARCHAR,
    provincia_id INT,
    departamento_nombre VARCHAR,
    departamento_id INT,
    superficie_sembrada_ha FLOAT,
    superficie_cosechada_ha FLOAT,
    produccion_tm FLOAT,
    rendimiento_kgxha FLOAT
);

-- Carga de archivo CSV único
COPY temp_maiz
FROM '/Datos/maiz.csv' DELIMITER ',' CSV HEADER ENCODING 'LATIN1';
-- o 'UTF8' según el encoding del archivo

-- Inserto provincias (únicas)
INSERT INTO
    public.provincia (id_provincia, nombre)
SELECT DISTINCT
    provincia_id,
    provincia_nombre
FROM temp_maiz
WHERE
    provincia_id IS NOT NULL;

-- Inserto departamentos (únicos)
INSERT INTO
    public.departamento (
        id_departamento,
        nombre,
        id_provincia
    )
SELECT DISTINCT
    departamento_id,
    departamento_nombre,
    provincia_id
FROM temp_maiz
WHERE
    departamento_id IS NOT NULL;

-- Inserto campaña (única por nombre y año)
INSERT INTO
    public.campania (anio, nombre)
SELECT DISTINCT
    anio,
    campania
FROM temp_maiz;

-- Inserto cultivos (cada línea es un cultivo en este caso)
INSERT INTO
    public.cultivo (
        nombre,
        anio,
        campania,
        id_provincia,
        id_departamento,
        superficie_sembrada,
        superficie_cosechada,
        produccion_toneladas,
        rendimiento
    )
SELECT
    cultivo_nombre,
    anio,
    campania,
    provincia_id,
    departamento_id,
    superficie_sembrada_ha,
    superficie_cosechada_ha,
    produccion_tm,
    rendimiento_kgxha
FROM temp_maiz;

-- Inserto en producción agrícola (enlazando por cultivo y campaña)
INSERT INTO
    public.produccion_agricola (
        id_cultivo,
        id_campania,
        superficie_sembrada,
        superficie_cosechada,
        produccion_toneladas
    )
SELECT c.id_cultivo, ca.id_campania, tm.superficie_sembrada_ha, tm.superficie_cosechada_ha, tm.produccion_tm
FROM
    temp_maiz tm
    JOIN public.cultivo c ON c.nombre = tm.cultivo_nombre
    AND c.anio = tm.anio
    AND c.id_provincia = tm.provincia_id
    AND c.id_departamento = tm.departamento_id
    JOIN public.campania ca ON ca.anio = tm.anio
    AND ca.nombre = tm.campania;

-- SQLBook: Code
--DROP DATABASE cultivos;

CREATE DATABASE cultivos;

\c cultivos;

--Borro las tablas si existen
DROP TABLE IF EXISTS public.cultivo CASCADE;

DROP TABLE IF EXISTS public.produccion_agricola CASCADE;

DROP TABLE IF EXISTS public.campania CASCADE;

DROP TABLE IF EXISTS public.provincia CASCADE;

DROP TABLE IF EXISTS public.departamento CASCADE;

--Creamos las tablas
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
    id_produccion_agricola INT PRIMARY KEY,
    id_cultivo INT,
    id_campania INT,
    superficie_sembrada DECIMAL(10, 2),
    superficie_cosechada DECIMAL(10, 2),
    produccion_toneladas DECIMAL(10, 2),
    FOREIGN KEY (id_cultivo) REFERENCES cultivo (id_cultivo),
    FOREIGN KEY (id_campania) REFERENCES campania (id_campania)
);

--Creo las tablas temporales para cargar los datos
CREATE TEMP
TABLE temp_provincias (
    id_provincia VARCHAR,
    nombre VARCHAR
);

CREATE TEMP
TABLE temp_departamentos (
    id_departamento VARCHAR,
    nombre VARCHAR,
    id_provincia VARCHAR
);

CREATE TEMP
TABLE temp_campanias (
    id_campania VARCHAR,
    anio INT,
    nombre VARCHAR
);

CREATE TEMP
TABLE temp_cultivos (
    id_cultivo VARCHAR,
    nombre VARCHAR,
    anio INT,
    campania VARCHAR,
    id_provincia VARCHAR,
    id_departamento VARCHAR,
    superficie_sembrada FLOAT,
    superficie_cosechada FLOAT,
    produccion_toneladas FLOAT,
    rendimiento FLOAT
);

CREATE TEMP
TABLE temp_produccion_agricola (
    id_produccion_agricola VARCHAR,
    id_cultivo VARCHAR,
    id_campania VARCHAR,
    superficie_sembrada FLOAT,
    superficie_cosechada FLOAT,
    produccion_toneladas FLOAT
);

--Carga de archivos CSV en las tablas temporales
COPY temp_provincias
FROM '/var/lib/postgresql/Datos/provincias.csv' DELIMITER ',' CSV HEADER;

COPY temp_departamentos
FROM '/var/lib/postgresql/Datos/provincias.csv' DELIMITER ',' CSV HEADER;

COPY temp_campanias
FROM '/var/lib/postgresql/Datos/provincias.csv' DELIMITER ',' CSV HEADER;

COPY temp_cultivos
FROM '/var/lib/postgresql/Datos/provincias.csv' DELIMITER ',' CSV HEADER;

COPY temp_produccion_agricola
FROM '/var/lib/postgresql/Datos/provincias.csv' DELIMITER ',' CSV HEADER;

--Insercion de datos unicos y normalizados

-- Provincias
INSERT INTO public.provincia (id_provincia, nombre)
SELECT DISTINCT id_provincia::INT, nombre
FROM temp_provincias
WHERE id_provincia::INT NOT IN (SELECT id_provincia FROM public.provincia);

-- Departamentos
INSERT INTO public.departamento (id_departamento, nombre, id_provincia)
SELECT DISTINCT id_departamento::INT, nombre, id_provincia::INT
FROM temp_departamentos
WHERE id_departamento::INT NOT IN (SELECT id_departamento FROM public.departamento);

-- Campanias
INSERT INTO public.campania (id_campania, anio, nombre)
SELECT DISTINCT id_campania::INT, anio, nombre
FROM temp_campanias
WHERE id_campania::INT NOT IN (SELECT id_campania FROM public.campania);

-- Cultivos
INSERT INTO public.cultivo (
    id_cultivo, nombre, anio, campania,
    id_provincia, id_departamento,
    superficie_sembrada, superficie_cosechada, produccion_toneladas, rendimiento
)
SELECT DISTINCT
    id_cultivo::INT, nombre, anio, campania,
    id_provincia::INT, id_departamento::INT,
    superficie_sembrada, superficie_cosechada, produccion_toneladas, rendimiento
FROM temp_cultivos
WHERE id_cultivo::INT NOT IN (SELECT id_cultivo FROM public.cultivo);

-- Produccion Agricola
INSERT INTO public.produccion_agricola (
    id_produccion_agricola, id_cultivo, id_campania,
    superficie_sembrada, superficie_cosechada, produccion_toneladas
)
SELECT DISTINCT
    id_produccion_agricola::INT, id_cultivo::INT, id_campania::INT,
    superficie_sembrada, superficie_cosechada, produccion_toneladas
FROM temp_produccion_agricola
WHERE id_produccion_agricola::INT NOT IN (SELECT id_produccion_agricola FROM public.produccion_agricola);