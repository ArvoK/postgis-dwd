--01
DROP MATERIALIZED VIEW IF EXISTS daten."sonnenstunde-im-jahr-pro-bundesland";
CREATE MATERIALIZED VIEW daten."sonnenstunde-im-jahr-pro-bundesland" AS
(
    SELECT
        avg(dwd_av."Sonnenstunden") as "Sonnenstunden",
        max(dwd_date."Datum") as "Datum",
        bl."Name" as "Bundesland",
        bl."geom" as geom
    FROM
        daten.brd_bundeslaender bl

    INNER JOIN
        daten."dwd_sonnenstunden_jahresmittel" dwd_av ON ST_INTERSECTS(dwd_av.geom, bl.geom)
    FULL JOIN
        daten."dwd_sonnenstunden_jahresmittel" dwd_date ON dwd_av.id = dwd_date.id
	WHERE 
		bl."Name" IS NOT NULL
    GROUP BY
        dwd_date."Datum", bl."Name", bl."geom"
);


--02
CREATE INDEX geom_idx
  ON daten."sonnenstunde-im-jahr-pro-bundesland"
  USING GIST (geom);