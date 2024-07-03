
--01
DROP MATERIALIZED VIEW IF EXISTS daten."brd_sonnenstunden_jahresmittel";
CREATE MATERIALIZED VIEW daten."brd_sonnenstunden_jahresmittel" AS
(
    SELECT
        CONCAT(dwd_date."id",';',bl."id") as id,
        avg(dwd_av."Sonnenstunden") as "Sonnenstunden",
        dwd_date."Datum" as "Datum",
        bl."Name" as "Bundesland",
        bl."geom" as geom
    FROM
        datenbestand.brd_bundeslaender bl

    INNER JOIN
        datenbestand."dwd_sonnenstunden_jahresmittel" dwd_av ON ST_INTERSECTS(dwd_av.geom, bl.geom)
    FULL JOIN
        datenbestand."dwd_sonnenstunden_jahresmittel" dwd_date ON dwd_av.id = dwd_date.id
    GROUP BY
        bl."Name", dwd_date."Datum",bl."geom",CONCAT(dwd_date."id",';',bl."id")
);


--02
CREATE UNIQUE INDEX idx_brd_sonnenstunden_jahresmittel_id
  ON daten."brd_sonnenstunden_jahresmittel" (id);