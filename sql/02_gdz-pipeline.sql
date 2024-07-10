--01
CREATE SERVER gdz_wfs
    FOREIGN DATA WRAPPER ogr_fdw
    OPTIONS (
        datasource 'WFS:https://sgx.geodatenzentrum.de/wfs_vg250-ew',
        format 'WFS'
    );


--02
-- Link zu den GetCapabilities
-- https://sgx.geodatenzentrum.de/wfs_vg250-ew?REQUEST=GetCapabilities&SERVICE=WFS
IMPORT FOREIGN SCHEMA "vg250-ew_vg250_lan" FROM SERVER gdz_wfs INTO daten;


--03
DROP MATERIALIZED VIEW IF EXISTS daten."brd_bundeslaender";
CREATE MATERIALIZED VIEW daten."brd_bundeslaender" AS
(
    SELECT
		gml_id AS id,
		gen AS "Name",
		ST_MAKEVALID(ST_CURVETOLINE(ST_TRANSFORM(geom, 25832))) AS geom
	FROM daten."vg250_ew_vg250_lan"
);


--04
CREATE UNIQUE INDEX brd_bundeslaender
  ON daten."brd_bundeslaender" (id);

CREATE INDEX geom_idx
ON daten."sonnenstunde-im-jahr-pro-bundesland"
USING GIST (geom);