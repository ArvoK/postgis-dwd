## Infrastructure
```mermaid
flowchart TD
 subgraph Container["Container"]
        PSQL[("PostgreSQL Database")]
  end
 subgraph WSL["Windows-Subsystem for Linux (WSL)"]
        Docker["Docker"]
        Container
  end
 subgraph Windows["Windows"]
        WSL
  end
    Docker --> Container
    Container --> PSQL
    style PSQL fill:#424242,color:#FFFFFF,stroke:#000000
    style Docker fill:#757575,color:#FFFFFF,stroke:#000000
    style Container stroke:#000000,fill:#757575
    style WSL fill:#616161,stroke:#000000
    style Windows color:#FFFFFF,fill:#424242
```
- **Windows:** Entwicklungsumgebung, Verwaltung von WSL2
- **WSL2:** Natives entwickeln auf Linux mit allen seinen Vorteilen.
- **Docker:**  Eine Anwendung mit allen ihren Abhängigkeiten in einem "Container". Abgsehen von der "Docker Engine" unabhängig lauffähig. Somit ist es deutlich leichter komplexe Systeme mit wenigen Zeilen Code zum laufen zu bringen.



### Datenbank
Vorhandene Erweiterungen überprüfen:
```postgresql
SELECT * FROM pg_extension;
```
Erweiterungen in Datenbank installieren:
```postgresql
CREATE EXTENSION pgagent;
CREATE EXTENSION ogr_fdw;
```

Neues Schema anlegen:
```postgresql
CREATE SCHEMA daten;
```
Daten Pipeline
```mermaid
flowchart TB
    A{{"dwd_wfs"}} -- Import Foreign Schema --> C("OBS_DEU_P1Y_SD")
    B{{"gdz_wfs"}} -- Import Foreign Schema --> D("vg250-ew_vg250_lan")
    C -- Datenaufbereitung ---> A2("dwd_sonnenstunden_jahresmittel")
    D -- Datenaufbereitung ---> B2("brd_bundeslaender")
    A2 -- geom --- E[\"Räumliche Verknüpfung"/]
    B2 -- geom --- E
    E --> n1["brd_sonnenstunden_jahresmittel"]
```
