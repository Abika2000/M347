# Day 3: Automatisierung des Day2-Projekts

## 1. Docker-Image automatisch bauen

In [Day2/Dockerfile](../Day2/Dockerfile) wird `nginx:1.27-alpine` als
Basis verwendet und `nginx.conf` in das Image kopiert. Das Skript
[build-image.ps1](../Day2/build-image.ps1) führt den Build aus und nennt das
Image `day2-nginx:1.0`.

Die Datei [.dockerignore](../Day2/.dockerignore) begrenzt den Build-Kontext
auf `Dockerfile` und `nginx.conf`. Passwörter und Zertifikatsschlüssel werden
nicht in das Image kopiert. Die Zertifikate werden beim Start separat
schreibgeschützt eingebunden.

```powershell
cd C:\M347\Day2
.\build-image.ps1
```

In [compose.yaml](../Day2/compose.yaml) verwenden beide nginx-Services
dieses Image. Nach einer Änderung an `nginx.conf` muss es neu gebaut und
der Service neu gestartet werden.

## 2. Deployment automatisch ausführen

[deploy.ps1](../Day2/deploy.ps1) prüft zuerst die Zertifikatsdateien und die
Compose-Konfiguration. Dann baut es das Image, startet bzw. aktualisiert die
Services und wartet auf deren Status. Die Datenvolumes werden dabei nicht
gelöscht. Das Skript gibt bei einem fehlgeschlagenen Schritt einen Fehler aus.

```powershell
cd C:\M347\Day2
.\deploy.ps1
```

Voraussetzungen: Docker Desktop läuft; `.env` und die Zertifikatsdateien
wurden wie in [README.md](../Day2/README.md) beschrieben angelegt. Wenn
PowerShell das Ausführen von Skripten blockiert, kann dieses einzelne Skript
mit `powershell -ExecutionPolicy Bypass -File .\deploy.ps1` gestartet werden;
die dauerhafte Richtlinie wird dadurch nicht geändert.

## 3. Möglichkeiten zum Testen

### Automatischer Test

Nach dem Deployment ausführen:

```powershell
.\test-service.ps1
```

[test-service.ps1](../Day2/test-service.ps1) prüft die Compose-Konfiguration,
die nginx-Konfiguration, die Bereitschaft von PostgreSQL und den Vaultwarden-
API-Endpunkt über HTTPS. Dabei prüft `curl` das lokale Zertifikat. Ein Fehler
beendet das Skript mit einer Meldung.

### Weitere Tests

- `docker compose ps`: Containerstatus und Datenbank-Healthcheck ansehen.
- `docker compose logs -f`: Fehlermeldungen der Services beobachten.
- `docker compose exec db psql -U vaultwarden -d vaultwarden`: Verbindung zur
  Datenbank im Container testen; mit `\q` beenden.
- `https://localhost:8081` im Browser öffnen und Kontoerstellung sowie Login
  manuell testen. Das selbstsignierte Zertifikat erzeugt eine Warnung.
- Optional die nginx-Skalierung wie in [README.md](../Day2/README.md)
  beschrieben testen. Die zusätzlichen Instanzen sind kein Load-Balancer.

Der automatische Test prüft keine vollständige Kontoerstellung und ersetzt
keinen manuellen Funktionstest oder ein Backup. Die Umgebung ist nur für
lokale Tests gedacht; keine echten Passwörter verwenden.
