# Gliederung
### 01 [Infrastruktur](#01-infrastruktur)
### 02 [Docker Compose](#02-docker-compose)
### 03 [Datenbank](#03-datenbank)


# 01 Infrastruktur
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

# 02 [Docker Compose](https://github.com/ArvoK/postgis-dwd/blob/main/docker-compose.yml)

Die Docker Compose-Datei [docker-compose.yml](https://github.com/ArvoK/postgis-dwd/blob/main/docker-compose.yml) definiert ein PostGIS-Setup mit pgAgent für die Ausführung geplanter Aufgaben in der Datenbank.

## Services

### `gis_database`

* **Image:** `postgis/postgis:16-3.4`
   - Verwendet das offizielle PostGIS Docker-Image, das PostgreSQL mit PostGIS-Erweiterungen für räumliche Daten kombiniert.
   - Die Version `16-3.4` bezieht sich auf PostgreSQL 16 und PostGIS 3.4.

* **Container Name:** `gis_database`
   - Benennt den Container, um ihn leichter identifizieren zu können.

* **Ports:**
   - `5433:5432`
      - Leitet Port 5433 auf dem Host-System zu Port 5432 im Container weiter.
      - PostgreSQL läuft standardmäßig auf Port 5432.

* **Environment:**
   - `POSTGRES_PASSWORD: gis_database_pw`
      - Setzt das Passwort für den PostgreSQL-Benutzer `postgres`.
      - Ersetze `gis_database_pw` durch ein sicheres Passwort.

* **Volumes:**
   - `gisdata:/var/lib/postgresql/data`
      - Speichert die PostgreSQL-Daten persistent im benannten Volume `gisdata`.
      - Dadurch bleiben die Daten auch nach dem Stoppen des Containers erhalten.

* **Command:**
   - `bash -c "apt-get update && apt-get install -y --no-install-recommends postgresql-16-ogr-fdw && apt-get update && apt-get install -y pgagent && docker-entrypoint.sh postgres"`
      - Führt eine Reihe von Befehlen aus, wenn der Container gestartet wird:
         1. Aktualisiert die Paketliste (`apt-get update`).
         2. Installiert den PostgreSQL Foreign Data Wrapper für OGR (`postgresql-16-ogr-fdw`) zur Verbindung mit anderen GIS-Datenquellen.
         3. Installiert pgAgent für die Ausführung geplanter Aufgaben.
         4. Startet den PostgreSQL-Dienst mit dem Standard-Entrypoint-Skript.

## Volumes

### `gisdata`

* **Name:** `gisdata`
   - Definiert ein benanntes Volume, um die PostgreSQL-Daten persistent zu speichern.

## Verwendung

1. Starte den Container mit `docker compose up -d`.
2. WSL2 IP-Adresse herausfinden: `wsl hostname -I `.  
3. IP-Adresse ersetzen  
![image](https://github.com/ArvoK/postgis-dwd/assets/64811285/6c4a64f2-6c66-4362-969e-d3f9ebcd0eb5)  
4. Passwort eingeben(`gis_database_pw`)  
![image](https://github.com/ArvoK/postgis-dwd/assets/64811285/c028d54e-e641-4dbf-9b58-12399e804e46)  


# 03 Datenbank
## Query Tool starten:  
![image](https://github.com/ArvoK/postgis-dwd/assets/64811285/23acd1c1-0b90-4fb9-850f-0a49759e1496)

## Vorhandene Erweiterungen überprüfen:
```postgresql
SELECT * FROM pg_extension;
```
## Erweiterungen in Datenbank installieren:
```postgresql
CREATE EXTENSION pgagent;
CREATE EXTENSION ogr_fdw;
```

## Neues Schema anlegen:
```postgresql
CREATE SCHEMA daten;
```

## Daten Importieren

### Schematische Darstellung
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

### Skripte aus dem sql Ordner geordnet ausführen