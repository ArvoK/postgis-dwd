CREATE EXTENSION IF NOT EXISTS ogr_fdw;

CREATE SERVER dwd_wfs
    FOREIGN DATA WRAPPER ogr_fdw
    OPTIONS (
        datasource 'WFS:https://cdc.dwd.de/geoserver/wfs',
        format 'WFS'
    );


-- Link zu den GetCapabilities
-- https://cdc.dwd.de/geoserver/ows?service=WFS&version=2.0.0&request=GetCapabilities

IMPORT FOREIGN SCHEMA "CDC:OBS_DEU_P1Y_SD" FROM SERVER dwd_wfs INTO datenbestand;