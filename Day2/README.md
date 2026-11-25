# Passwortmanager mit Docker Compose

Diese Lernumgebung verwendet Vaultwarden (einen inoffiziellen, mit Bitwarden
kompatiblen Server), PostgreSQL und nginx als Reverse Proxy.

## Starten

1. In PowerShell nach `C:\M347\Day2` wechseln und die Vorlage kopieren:

   ```powershell
   cd C:\M347\Day2
   Copy-Item .env.example .env
   ```

2. In `.env` ein eigenes, langes `DB_PASSWORD` setzen. Nur Buchstaben und
   Zahlen verwenden, damit es ohne URL-Kodierung in der Datenbank-URL
   funktioniert. Zum Generieren z. B. zweimal `New-Guid` ausführen und die
   Ergebnisse ohne Bindestriche zusammenfügen. `.env` nicht weitergeben.
3. Ein selbstsigniertes Zertifikat fuer lokale Tests erstellen. Das folgende
   Beispiel verwendet OpenSSL aus Git fuer Windows:

   ```powershell
   New-Item -ItemType Directory -Force certs
   & 'C:\Program Files\Git\usr\bin\openssl.exe' req -x509 -newkey rsa:2048 -sha256 -nodes -keyout 'certs\localhost.key' -out 'certs\localhost.crt' -days 365 -subj '/CN=localhost' -addext 'subjectAltName=DNS:localhost'
   ```

   Vorhandene Zertifikate nicht ohne Grund ueberschreiben. Den privaten
   Schluessel niemals weitergeben.
4. Container starten:

   ```powershell
   .\deploy.ps1
   ```

   Das Skript baut zuerst das nginx-Image und startet danach die Services.
   Nach Änderungen an `nginx.conf` das Skript erneut ausführen, damit die
   Konfiguration neu ins Image übernommen wird.

5. `https://localhost:8081` im Browser oeffnen und ein Konto erstellen. Bei
   der Zertifikatswarnung fuer diese lokale Testseite "Erweitert" und
   "Weiter zu localhost" auswaehlen. Das Zertifikat ist selbstsigniert und
   wird vom Browser nicht automatisch als vertrauenswuerdig eingestuft.
   Port 8081 vermeidet den Konflikt mit einer Website auf Port 8080.
6. Danach in `.env` `SIGNUPS_ALLOWED=false` setzen und
   `docker compose up -d` erneut ausführen, um weitere Registrierungen zu
   deaktivieren.

Beim Ändern von `PORT` auch `DOMAIN` entsprechend anpassen. Das
Datenbankpasswort wird nur bei der ersten Initialisierung gesetzt: Eine spätere
Änderung in `.env` ändert nicht automatisch das Passwort in PostgreSQL.

## Aufbau

- **Services:** nginx leitet Anfragen an Vaultwarden weiter; Vaultwarden
  verwendet PostgreSQL.
- **Netzwerke:** `frontend` verbindet nginx mit Vaultwarden. `backend` ist
  intern und verbindet Vaultwarden mit PostgreSQL. Die Datenbank hat keinen
  veröffentlichten Port.
- **Volumes:** `postgres_data` speichert die Datenbank, `vaultwarden_data`
  speichert weitere Vaultwarden-Dateien, z. B. Anhänge und Schlüssel. Beide
  bleiben bei `docker compose down` erhalten. Beide müssen gesichert werden;
  ein Volume ersetzt kein Backup.
- **Ressourcen:** `cpus` und `mem_limit` begrenzen jeden Container.
- **Environment:** `.env` enthält die lokalen Einstellungen und das
  Datenbankpasswort; `.env.example` ist die Vorlage.

## Skalierung demonstrieren

Zusätzliche nginx-Instanzen mit jeweils eigenem, automatisch zugewiesenem
lokalem Port starten:

```powershell
docker compose --profile scaling up -d --scale nginx-scale=2
docker compose --profile scaling ps
```

Die Ports stehen in der Ausgabe von `ps`. Das ist eine Demonstration der
Compose-Skalierung, kein Load-Balancing: Jeder Port muss einzeln mit HTTPS
angesprochen werden. Fuer den normalen Betrieb und die Kontoerstellung die
konfigurierte `DOMAIN` verwenden. Der normale Zugang auf Port 8081 bleibt
bestehen. Vaultwarden und PostgreSQL bleiben Einzelinstanzen; ihre Skalierung
erfordert zusätzliche Planung für gemeinsame Daten und die Anwendung.

Die zusätzlichen Instanzen entfernen, ohne Datenvolumes zu löschen:

```powershell
docker compose --profile scaling stop nginx-scale
docker compose --profile scaling rm -f nginx-scale
```

## Sicherheit und Betrieb

Diese Konfiguration ist nur für lokale Tests gedacht: HTTPS ist auf
`127.0.0.1` gebunden und verwendet ein selbstsigniertes Zertifikat. Keine
echten Passwörter für den Test verwenden. Für Netzwerk- oder Internetzugriff
sind ein gültiges Zertifikat, angepasste Domain, Härtung und ein
Backup-Konzept erforderlich.

```powershell
docker compose logs -f
docker compose down
```

`docker compose down -v` löscht zusätzlich die Datenvolumes und damit die
gespeicherten Daten.
