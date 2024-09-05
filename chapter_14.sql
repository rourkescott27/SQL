-- Chapter 14 Exercises
--* 14.1
CREATE DATABASE gis_analysis;

-- 14.2
--- Loading PostGIS extension
CREATE EXTENSION postgis;

-- Checking PostGIS version
SELECT postgis_full_version();

-- 14.3
--- Retrieving the WKT for SRID 4326
---** Book **--- WKT is text that represents a geometry, plus an optional Spatial Reference System Identifier (SRID) that specifies the grid on which to place the objects
SELECT srtext
FROM spatial_ref_sys 
WHERE srid = 4326;

-- 14.4
--- Creating spatial objects with ST_GeomFromText()
---- Geometry

SELECT ST_GeomFromText('POINT(-74.9233606 42.699992)', 4326);

SELECT ST_GeomFromText('LINESTRING(-74.9 42.7, -75.1 42.7)', 4326);

SELECT ST_GeomFromText('POLYGON((-74.9 42.7, -75.1 42.7,
                                 -75.1 42.6, -74.9 42.7))', 4326);

SELECT ST_GeomFromText('MULTIPOINT (-74.9 42.7, -75.1 42.7)', 4326);

SELECT ST_GeomFromText('MULTILINESTRING((-76.27 43.1, -76.06 43.08),
                                        (-76.2 43.3, -76.2 43.4,
                                         -76.4 43.1))', 4326);

SELECT ST_GeomFromText('MULTIPOLYGON((
                                     (-74.92 42.7, -75.06 42.71,
                                      -75.07 42.64, -74.92 42.7),
                                     (-75.0 42.66, -75.0 42.64,
                                      -74.98 42.64, -74.98 42.66,
                                      -75.0 42.66)))', 4326);

-- 14.5
--- Creating spatial objects with ST_GeogFromText() 
---- Geography
SELECT ST_GeogFromText('SRID=4326;MULTIPOINT(-74.9 42.7, -75.1 42.7, -74.924 42.6)');

-- 14.6
--- Functions specific to making Points
SELECT ST_PointFromText('POINT(-74.9233606 42.699992)', 4326);
SELECT ST_MakePoint(-74.9233606, 42.699992);
SELECT ST_SetSRID(ST_MakePoint(-74.9233606, 42.699992), 4326);

-- 14.7
--- Functions specific to making LineStrings
SELECT ST_LineFromText('LINESTRING(-105.90 35.67,-105.91 35.67)', 4326); 
SELECT ST_MakeLine(ST_MakePoint(-74.9, 42.7), ST_MakePoint(-74.1, 42.4));

-- 14.8
--- Functions specific to making Polygons
SELECT ST_PolygonFromText('POLYGON((-74.9 42.7, -75.1 42.7,
                                      -75.1 42.6, -74.9 42.7))', 4326);

SELECT ST_MakePolygon(
             ST_GeomFromText('LINESTRING(-74.92 42.7, -75.06 42.71,
                                         -75.07 42.64, -74.92 42.7)', 4326)); 

SELECT ST_MPolyFromText('MULTIPOLYGON((
                                         (-74.92 42.7, -75.06 42.71,
                                          -75.07 42.64, -74.92 42.7),
                                         (-75.0 42.66, -75.0 42.64,
                                          -74.98 42.64, -74.98 42.66,
                                          -75.0 42.66)
                                        ))', 4326);

--* 14.9
CREATE TABLE farmers_markets (
    fmid bigint PRIMARY KEY, 
    market_name varchar(100) NOT NULL, 
    street varchar(180), 
    city varchar(60), 
    county varchar(25), 
    st varchar(20) NOT NULL, 
    zip varchar(10), 
    longitude numeric(10,7), 
    latitude numeric(10,7), 
    organic varchar(1) NOT NULL
);

COPY farmers_markets
FROM 'D:\SQL\external_data\farmers_markets.csv'
WITH (FORMAT CSV, HEADER);

-- 14.10
--- Creating and indexing a geography column
ALTER TABLE farmers_markets ADD COLUMN geog_point geography(POINT,4326);

UPDATE farmers_markets
SET geog_point = 
	ST_SetSRID(
 		ST_MakePoint(longitude,latitude),4326)::geography;

CREATE INDEX market_pts_idx ON farmers_markets USING GIST (geog_point);

SELECT  longitude,
        latitude,
        geog_point,
		ST_AsText(geog_point)
FROM farmers_markets
WHERE longitude IS NOT NULL
LIMIT 5;

-- 14.11
--- Using ST_DWithin() to locate farmers’ markets within 10 kilometers/miles of a point
SELECT market_name,
       city,
       st
FROM farmers_markets
WHERE ST_DWithin(geog_point,
 	  ST_GeogFromText('POINT(-93.6204386 41.5853202)'), 10000)      
ORDER BY market_name;

-- 14.12
--- Using ST_Distance() to calculate the miles between Yankee Stadium and Citi Field (Mets)
---- Converting to miles by dividing the kilometers by 1609.344
SELECT ST_Distance(
                   ST_GeogFromText('POINT(-73.9283685 40.8296466)'),
                   ST_GeogFromText('POINT(-73.8480153 40.7570917)')
                   ) / 1609.344 AS mets_to_yanks;

-- 14.13
--- Using ST_Distance() for each row in farmers_markets
---- Checking the distance (in miles) of different farmers markets from downtown
SELECT market_name,
       city,
       round(
           (ST_Distance(geog_point,
                        ST_GeogFromText('POINT(-93.6204386 41.5853202)')
                        ) / 1609.344)::numeric(8,5), 2
            ) AS miles_from_dt
FROM farmers_markets
WHERE ST_DWithin(geog_point,
                 ST_GeogFromText('POINT(-93.6204386 41.5853202)'),
                 10000)
ORDER BY miles_from_dt ASC;

-- 14.14
---  Checking the geom column's well-known text representation
SELECT ST_AsText(geom)
FROM us_counties_2010_shp
LIMIT 1;

-- 14.15
--- Finding the largest counties by area using ST_Area()
SELECT name10,
       statefp10 AS st,
       round(
             ( ST_Area(geom::geography) / 2589988.110336 )::numeric, 2
            )  AS square_miles
FROM us_counties_2010_shp
ORDER BY square_miles DESC
LIMIT 5;

-- 14.16 ERROR
--- Using ST_Within() to find the county belonging to a pair of coordinates 
SELECT name10,
       statefp10
FROM us_counties_2010_shp
WHERE ST_Within('SRID=4269;POINT(-118.3419063 34.0977076)'::geometry, 4269); --** 4269

-- 14.17
--- Using ST_GeometryType() to determine geometry
SELECT ST_GeometryType(geom)
FROM santafe_linearwater_2016
LIMIT 1;

SELECT ST_GeometryType(geom)
FROM santafe_roads_2016
LIMIT 1;

-- 14.18
--- Spatial join with ST_Intersects() to find roads crossing the Santa Fe river
SELECT water.fullname AS waterway,
       roads.rttyp,
       roads.fullname AS road
FROM santafe_linearwater_2016 water JOIN santafe_roads_2016 roads
    ON ST_Intersects(water.geom, roads.geom)
WHERE water.fullname = 'Santa Fe Riv'
ORDER BY roads.fullname;

-- 14.19
--- Using ST_Intersection() to show where roads cross the river
SELECT water.fullname AS waterway,
       roads.rttyp,
       roads.fullname AS road,
       ST_AsText(ST_Intersection(water.geom, roads.geom))
FROM santafe_linearwater_2016 water JOIN santafe_roads_2016 roads
    ON ST_Intersects(water.geom, roads.geom)
WHERE water.fullname = 'Santa Fe Riv'
ORDER BY roads.fullname
LIMIT 5;