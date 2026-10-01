# Gymi Trainer

Eine iPhone- und iPad-App, mit der sich Kinder auf die Zentrale Aufnahmeprüfung (ZAP) für das Gymnasium im Kanton Zürich vorbereiten. Die Aufgaben stammen aus den Prüfungen 2015 bis 2025.

Die App unterscheidet zwischen zwei Prüfungstypen:

- **Langzeit** (Langgymnasium, nach der 6. Klasse)
- **Kurzzeit** (Kurzgymnasium, aus der 2. oder 3. Sekundarschule)

## Funktionen

- **Heute:** Wochenziele als Aktivitätsringe, Countdown bis zur Prüfung, jeden Tag ein Vorschlag für Mathematik und für die Sprachprüfung, Listen «Zu wiederholen», «Gemerkte Aufgaben», «Schwächen üben» und «Meine Stärken».
- **Aufgaben:** Alle Aufgaben nach Jahr, Fach, Thema und Schwierigkeit filtern. Die Originalprüfung wird direkt bei der Aufgabe geöffnet, die Lösung kann man aufdecken. Danach schätzt man selbst ein, wie es lief. Aufgaben kann man merken und ausdrucken.
- **Prüfung:** Eine ganze Probeprüfung mit der echten Zeit und den erlaubten Hilfsmitteln, danach korrigieren und das Resultat ansehen.
- **Aufsatz:** Einen Entwurf direkt in der App schreiben und mit einer Checkliste überprüfen.
- **Fortschritt:** Gesamtfortschritt als Kuchendiagramme, eine Themenlandkarte mit fünf Stufen (Neu, Angefangen, Üben nötig, Sicher, Gemeistert), ein Netzdiagramm «Meine Stärken» und der Verlauf der Probeprüfungen.
- **Tipps:** Lerntipps für Langzeit, für Kurzzeit und für beide.
- **Aussehen:** Sechs Farbthemen sowie ein heller oder dunkler Modus.

Ein Thema bewertet die App mit der geglätteten Quote `(richtig + 1) / (versucht + 2)`. So zählen auch falsch gelöste Aufgaben, und ein einzelner Treffer wiegt nicht zu viel.

## Technik

- SwiftUI, iOS 26 oder neuer, für iPhone und iPad
- SwiftData für Versuche, Aufsatzentwürfe, Probeprüfungen und gemerkte Aufgaben
- PDFKit zum Anzeigen der Prüfungen, Swift Charts für die Diagramme
- Keine Anmeldung und kein Server: Alle Daten bleiben auf dem Gerät

## Projektstruktur

```
App/
  App.swift              Einstiegspunkt, lädt den Aufgabenkatalog
  Model/                 Datenmodell, Katalog, Fortschritt und Einstellungen
  Views/                 Alle Bildschirme und Komponenten
  Resources/
    Data/                Aufgaben als JSON (Mathematik, Sprachprüfung, Aufsatz)
    PDF/                 Originalprüfungen und Lösungen 2015–2025
Docs/
  Use-Cases-Kind.md      Use Cases aus der Sicht des Kindes
appStoreConnect/         Texte für den App Store
Project.json             Projektkonfiguration
```

Die PDF-Dateien heissen nach diesem Schema: `<Jahr>-<lg|kg>-<mathematik|sprache|aufsatz>-<aufgaben|loesungen|textblatt|korrektur>.pdf`, zum Beispiel `2024-lg-mathematik-aufgaben.pdf`.

## Entwicklung

Die App wurde mit [Bitrig](https://bitrig.app) entwickelt. Die Projektkonfiguration steht in `Project.json`.

## Quellen

Die Prüfungsaufgaben und Lösungen stammen von der Zentralen Aufnahmeprüfung des Kantons Zürich ([zh.ch](https://www.zh.ch)). Die Rechte daran liegen beim Kanton Zürich.
