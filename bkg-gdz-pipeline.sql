CREATE SERVER gdz_wfs
    FOREIGN DATA WRAPPER ogr_fdw
    OPTIONS (
        datasource 'WFS:https://sgx.geodatenzentrum.de/wfs_vg250-ew',
        format 'WFS'
    );

-- Link zu den GetCapabilities
-- https://sgx.geodatenzentrum.de/wfs_vg250-ew?REQUEST=GetCapabilities&SERVICE=WFS


IMPORT FOREIGN SCHEMA "vg250-ew_vg250_lan" FROM SERVER gdz_wfs INTO datenbestand;

DROP MATERIALIZED VIEW IF EXISTS datenbestand."brd_bundeslaender";


CREATE MATERIALIZED VIEW datenbestand."brd_bundeslaender"
(
    SELECT
		gml_id AS id,
		gen AS "Name",
		ST_MAKEVALID(ST_TRANSFORM(geom, 25832)) AS geom
	FROM datenbestand."vg250_ew_vg250_lan"
);

CREATE UNIQUE INDEX idx_brd_bundeslaender_id
  ON datenbestand."brd_bundeslaender" (id);