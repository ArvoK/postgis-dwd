-- 1. Schritt

CREATE SERVER dwd_wfs
    FOREIGN DATA WRAPPER ogr_fdw
    OPTIONS (
        datasource 'WFS:https://cdc.dwd.de/geoserver/wfs',
        format 'WFS'
    );

CREATE SCHEMA datenbestand;

-- Link zu den GetCapabilities
-- https://cdc.dwd.de/geoserver/ows?service=WFS&version=2.0.0&request=GetCapabilities

IMPORT FOREIGN SCHEMA "CDC:OBS_DEU_P1Y_SD" FROM SERVER dwd_wfs INTO datenbestand;

DROP MATERIALIZED VIEW IF EXISTS datenbestand."dwd_sonnenstunden_jahresmittel";

CREATE MATERIALIZED VIEW datenbestand."dwd_sonnenstunden_jahresmittel" AS
(
    SELECT
		gml_id AS id,
		sdo_name AS "Name",
		(EXTRACT(YEAR FROM zeitstempel) || '-01-01')::DATE + INTERVAL '00:00:00' AS "Datum",
		wert AS "Sonnenstunden",
		ST_MAKEVALID(ST_TRANSFORM(sdo_geom, 25832)) AS geom
	FROM datenbestand."cdc_obs_deu_p1y_sd"
    WHERE EXTRACT(YEAR FROM zeitstempel) < 2020 AND EXTRACT(YEAR FROM zeitstempel) > 2010
);

CREATE UNIQUE INDEX idx_dwd_sonnenstunden_jahresmittel_id
  ON datenbestand."dwd_sonnenstunden_jahresmittel" (id);