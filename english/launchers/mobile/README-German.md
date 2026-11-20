# Ein Symbol zum Startbildschirm hinzufügen (Android/iPhone/iPad)

open-english ist eine statische Webanwendung ohne Server-Voraussetzung (mit PWA-Manifest-
Unterstützung), sodass keine spezielle native App aus einem Store installiert werden muss —
Sie können mit der Funktion "Zum Startbildschirm hinzufügen" des Browsers ein Symbol auf
dem Startbildschirm platzieren.

## Voraussetzungen

- `index.html` muss über einen Webserver geöffnet werden (oder über den Download-Server von
  `open-easy-web`) — beim direkten Öffnen als `file://` blockieren viele Browser das Laden
  von manifest.json/Symbolen, und "Zum Startbildschirm hinzufügen" erscheint möglicherweise
  nicht. Zum lokalen Testen zum Beispiel:
  ```
  cd open-english
  python3 -m http.server 8090
  ```
  und dann `http://<IP des PCs>:8090/index.html` im Browser des Smartphones öffnen.

## Android (Chrome)

1. `index.html` in Chrome öffnen.
2. Das "⋮"-Menü oben rechts antippen → "Zum Startbildschirm hinzufügen" (oder
   "Installieren" im automatisch erscheinenden Installationsbanner).
3. Die `icons` aus `manifest.json` (`icons/icon-192.png`, `icons/icon-512.png`) werden als
   Startbildschirmsymbol verwendet.

## iPhone / iPad (Safari)

1. `index.html` in Safari öffnen.
2. Die Teilen-Schaltfläche antippen (das quadratische Symbol mit dem Pfeil nach oben).
3. "Zum Home-Bildschirm" auswählen.
4. `<link rel="apple-touch-icon" ...>` (`icons/icon-180.png`) wird als
   Startbildschirmsymbol verwendet.

## Ehrliche Offenlegung

- Beide Methoden erstellen **eine Browser-Verknüpfung (eine PWA), keine native App** — dies
  ist keine Store-basierte Installation.
- Der Offline-Betrieb (ein Service Worker) ist nicht implementiert — eine
  Netzwerkverbindung ist weiterhin erforderlich (da `aruaru-llm` im Phase-0-Design als
  lokal residenter Server konzipiert ist, geht diese Einrichtung nicht davon aus, dass
  `aruaru-llm` eigenständig auf dem Smartphone läuft).
