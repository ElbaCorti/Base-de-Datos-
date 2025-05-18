--Borramos la base de datos por si existe
DROP DATABASE cultivos; 

--Creamos la base de datos 
CREATE DATABASE cultivos;

-- Conectamos la base de datos 
\c cultivos; 

--Borro las tablas si existen 
DROP TABLE IF EXISTS public.cultivo;
DROP TABLE IF EXISTS public.produccionAgricola;
DROP TABLE IF EXISTS public.campaña;
DROP TABLE IF EXISTS public.provincia;
DROP TABLE IF EXISTS public.departamento;

--Creamos las tablas 
CREATE TABLE public.cultivo (
  id_cultivo INT PRIMARY KEY,
    nombre VARCHAR(100),
    año INT,
    campaña VARCHAR(100),
    id_Provincia INT,
    id_Departamento INT,
    superficieSembrada DECIMAL(10,2),
    superficieCosechada DECIMAL(10,2),
    produccionToneladas DECIMAL(10,2),
    rendimiento DECIMAL(10,2),
    FOREIGN KEY (id_Provincia) REFERENCES Provincia(id_Provincia),
    FOREIGN KEY (id_Departamento) REFERENCES Departamento(id_Departamento)
);

CREATE TABLE public.produccionAgricola (
   id_produccionAgricola INT PRIMARY KEY,
    id_cultivo INT,
    id_campaña INT,
    superficieSembrada DECIMAL(10,2),
    superficieCosechada DECIMAL(10,2),
    produccionToneladas DECIMAL(10,2),
    FOREIGN KEY (id_cultivo) REFERENCES Cultivo(id_cultivo),
    FOREIGN KEY (id_campaña) REFERENCES Campaña(id_campaña)
);

CREATE TABLE public.campaña (
   id_campaña INT PRIMARY KEY,
    año INT,
    nombre VARCHAR(100)
);

CREATE TABLE public.provincia (
    id_Provincia INT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE public.departamento (
    id_Departamento INT PRIMARY KEY,
    nombre VARCHAR(100)
);


--Agrego las restricciones de clave primaria y foránea a las tablas

ALTER TABLE public.provincia
ADD CONSTRAINT pk_provincia PRIMARY KEY (id_provincia);

ALTER TABLE public.departamento
ADD CONSTRAINT pk_departamento PRIMARY KEY (id_departamento);

ALTER TABLE public.campaña
ADD CONSTRAINT pk_campaña PRIMARY KEY (id_campaña);

ALTER TABLE public.cultivo
ADD CONSTRAINT pk_cultivo PRIMARY KEY (id_cultivo);

ALTER TABLE public.produccion_agricola
ADD CONSTRAINT pk_produccion_agricola PRIMARY KEY (id_produccion_agricola);

ALTER TABLE public.departamento
ADD CONSTRAINT fk_departamento_provincia FOREIGN KEY (id_provincia) REFERENCES public.provincia(id_provincia);

ALTER TABLE public.cultivo
ADD CONSTRAINT fk_cultivo_provincia FOREIGN KEY (id_provincia) REFERENCES public.provincia(id_provincia),
ADD CONSTRAINT fk_cultivo_departamento FOREIGN KEY (id_departamento) REFERENCES public.departamento(id_departamento);

ALTER TABLE public.produccion_agricola
ADD CONSTRAINT fk_produccion_cultivo FOREIGN KEY (id_cultivo) REFERENCES public.cultivo(id_cultivo),
ADD CONSTRAINT fk_produccion_campaña FOREIGN KEY (id_campaña) REFERENCES public.campaña(id_campaña);

--Creo las tablas temporales para cargar los datos
CREATE TEMP TABLE temp_provincias (
    id_provincia VARCHAR,
    nombre VARCHAR
);

CREATE TEMP TABLE temp_departamentos (
    id_departamento VARCHAR,
    nombre VARCHAR,
    id_provincia VARCHAR
);

CREATE TEMP TABLE temp_campañas (
    id_campaña VARCHAR,
    anio INT,
    nombre VARCHAR
);

CREATE TEMP TABLE temp_cultivos (
    id_cultivo VARCHAR,
    nombre VARCHAR,
    anio INT,
    campaña VARCHAR,
    id_provincia VARCHAR,
    id_departamento VARCHAR,
    superficie_sembrada FLOAT,
    superficie_cosechada FLOAT,
    produccion_toneladas FLOAT,
    rendimiento FLOAT
);

CREATE TEMP TABLE temp_produccion_agricola (
    id_produccion_agricola VARCHAR,
    id_cultivo VARCHAR,
    id_campaña VARCHAR,
    superficie_sembrada FLOAT,
    superficie_cosechada FLOAT,
    produccion_toneladas FLOAT
);


--Carga de archivos CSV en las tablas temporales
COPY temp_provincias FROM '/datos/provincias.csv' DELIMITER ',' CSV HEADER;
COPY temp_departamentos FROM '/datos/departamentos.csv' DELIMITER ',' CSV HEADER;
COPY temp_campañas FROM '/datos/campañas.csv' DELIMITER ',' CSV HEADER;
COPY temp_cultivos FROM '/datos/cultivos.csv' DELIMITER ',' CSV HEADER;
COPY temp_produccion_agricola FROM '/datos/produccion_agricola.csv' DELIMITER ',' CSV HEADER;


--Inserción de datos únicos y normalizados

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

-- Campañas
INSERT INTO public.campaña (id_campaña, anio, nombre)
SELECT DISTINCT id_campaña::INT, anio, nombre
FROM temp_campañas
WHERE id_campaña::INT NOT IN (SELECT id_campaña FROM public.campaña);

-- Cultivos
INSERT INTO public.cultivo (
    id_cultivo, nombre, anio, campaña,
    id_provincia, id_departamento,
    superficie_sembrada, superficie_cosechada, produccion_toneladas, rendimiento
)
SELECT DISTINCT
    id_cultivo::INT, nombre, anio, campaña,
    id_provincia::INT, id_departamento::INT,
    superficie_sembrada, superficie_cosechada, produccion_toneladas, rendimiento
FROM temp_cultivos
WHERE id_cultivo::INT NOT IN (SELECT id_cultivo FROM public.cultivo);

-- Producción Agrícola
INSERT INTO public.produccion_agricola (
    id_produccion_agricola, id_cultivo, id_campaña,
    superficie_sembrada, superficie_cosechada, produccion_toneladas
)
SELECT DISTINCT
    id_produccion_agricola::INT, id_cultivo::INT, id_campaña::INT,
    superficie_sembrada, superficie_cosechada, produccion_toneladas
FROM temp_produccion_agricola
WHERE id_produccion_agricola::INT NOT IN (SELECT id_produccion_agricola FROM public.produccion_agricola);
