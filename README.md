# Base-de-Datos-
# **ETL para la carga de *`datasets`* de Siembra, cosecha, producción y rendimiento de cultivos principales en Argentina**

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)

1. **Descarga de Datasets**

Los datasets utilizados en este proyecto pueden descargarse desde el portal oficial de datos abiertos del gobierno de Argentina:  
[https://datos.gob.ar/dataset](https://datos.gob.ar/dataset)

Este portal proporciona información pública en formatos reutilizables, incluyendo datos relacionados con la producción agricola en Argentina.

## **Resumen del Tutorial**

Este tutorial guía al usuario a través de los pasos necesarios para desplegar una infraestructura ETL utilizando Docker y PostgreSQL. Se incluyen instrucciones detalladas para:

1. Levantar los servicios con Docker.
2. Configurar la conexión a la base de datos en PostgreSQL.
3. Ejecutar consultas SQL para analizar los datos de siembra, cosecha, producción y rendimiento de cultivos en argentina.

## **Palabras Clave**

- Docker
- PostgreSQL
- ETL

## **Mantenido Por**

**Grupo3**

## **Descargo de Responsabilidad**

El código proporcionado se ofrece "tal cual", sin garantía de ningún tipo, expresa o implícita. En ningún caso los autores o titulares de derechos de autor serán responsables de cualquier reclamo, daño u otra responsabilidad.


## **Descripción del Proyecto**

Este proyecto implementa un proceso ETL (Extract, Transform, Load) para la carga, transformación y análisis de datos relacionados con la producción agricola en Argentina. El sistema se enfoca en el estudio de cultivos como soja, maíz y trigo, permitiendo observar su evolución en términos de producción y rendimiento a lo largo del tiempo.

Se utilizan herramientas modernas como Docker, PostgreSQL para garantizar una solución escalable, reproducible y fácil de mantener. La información se obtiene desde archivos CSV y se integra en una base de datos estructurada. El objetivo principal es proporcionar una solución escalable y reproducible para analizar tendencias históricas, rendimiento productivo, y evolución anual de estos cultivos entre 1923 y 2024.

## **Características Principales**

- **Infraestructura Contenerizada:** Uso de Docker para simplificar la configuración y despliegue.

- **Base de Datos Relacional:** PostgreSQL para almacenar y gestionar los datos.

- **Gestión de Base de Datos:** Utilizamos Docker para administrar y consultar la base de datos.

## **Requisitos Previos**

Antes de comenzar, asegúrate de tener instalados los siguientes componentes:

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [PostgreSQL](https://www.postgresql.org/download/)

## **Servicios Definidos en Docker Compose**

El archivo `docker-compose.yml` define los siguientes servicios:

1. **Base de Datos (PostgreSQL):**
   - Imagen: `postgres:alpine`
   - Puertos: `5432:5432`
   - Volúmenes:
     - `./Base-de-Datos--main/Datos:/csv` 
   - Variables de entorno:
     - Configuradas en el archivo `.env.db`
   - Healthcheck:
     - Comando: `pg_isready`
     - Intervalo: 10 segundos
     - Retries: 5


## **Instrucciones de Configuración**

1. **Clonar el repositorio:**
   ```sh
   git clone <URL_DEL_REPOSITORIO>
   cd postgres-etl
   ```

2. **Configurar el archivo `.env.db`:**
   Crea un archivo `.env.db` en la raíz del proyecto con las siguientes variables de entorno:
   ```env
    #Definimos cada variable
    DATABASE_HOST=db
    DATABASE_PORT=5432
    DATABASE_NAME=postgres
    DATABASE_USER=postgres
    DATABASE_PASSWORD=postgres
    POSTGRES_INITDB_ARGS="--auth-host=scram-sha-256 --auth-local=trust"
    # Configuracion para inicializar postgres
    POSTGRES_PASSWORD=${DATABASE_PASSWORD}
    PGUSER=${DATABASE_USER}
   ```

3. **Levantar los servicios:**
   Ejecuta los siguientes comandos para iniciar los contenedores:
   ```sh
   docker compose up -d
   . init.sh
   ```


## **Uso del Proyecto**

### **1. Configuración de la Base de Datos**
Una vez levantados los servicios con Docker, la base de datos PostgreSQL estará disponible y lista para usarse.
Puedes conectarte a la base de datos utilizando cualquier cliente compatible (terminal).
- Parámetros de conexión:
Detallados en el archivo .env.db


### **2. Consultas SQL**

#### **Consulta 1: Producción total por cultivo y año**
Esta consulta permite obtener la producción total (en toneladas) de cada cultivo por año.

```sql
SELECT
    c.nombre AS cultivo,
    ca.anio,
    SUM(p.produccion_toneladas) AS produccion_total
FROM
    produccion_agricola p
    JOIN cultivo c ON p.id_cultivo = c.id_cultivo
    JOIN campania ca ON p.id_campania = ca.id_campania
GROUP BY
    c.nombre, ca.anio
ORDER BY
    ca.anio;
```

#### **Consulta 2: Rendimiento promedio por cultivo(últimos 20 años)**
Esta consulta muestra la producción total anual de cada cultivo desde 2004, permitiendo compararlos entre sí.

```sql
SELECT
    c.nombre AS cultivo,
    AVG(c.rendimiento) AS rendimiento_promedio
FROM
    cultivo c
WHERE
    c.anio >= EXTRACT(YEAR FROM CURRENT_DATE) - 19
GROUP BY
    c.nombre
ORDER BY
    c.nombre;
```

### **Consulta 3: Comparativa entre soja y maiz en los últimos 10 años**
Esta consulta compara únicamente soja y maíz en términos de producción en los últimos 10 años.

```sql
SELECT
    ca.anio,
    c.nombre AS cultivo,
    SUM(p.produccion_toneladas) AS produccion_total
FROM
    produccion_agricola p
    JOIN cultivo c ON p.id_cultivo = c.id_cultivo
    JOIN campania ca ON p.id_campania = ca.id_campania
WHERE
    (c.nombre ILIKE 'soja' OR c.nombre ILIKE 'maiz' OR c.nombre ILIKE 'maíz')
    AND ca.anio >= EXTRACT(YEAR FROM CURRENT_DATE) - 9
GROUP BY
    ca.anio, c.nombre
ORDER BY
    ca.anio, c.nombre;
```

## **Estructura del Proyecto**
```
postgres-etl/
├── docker-compose.yml       # Configuración de Docker Compose
├── datos/                   # Carpeta para almacenar datasets
├── scripts/                 # Carpeta que contiene el script  
├── sql/                     # Consultas SQL predefinidas
├── .env.db/                 # Define las variables de entorno 
└── README.md                # Documentación del proyecto
```
