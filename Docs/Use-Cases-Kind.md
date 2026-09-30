# Gymi-Vorbereitung — Use Cases für das Kind

**Stand:** 30. September 2026
**Scope:** Alles, was das Kind (Langzeit und Kurzzeit) selbst in der App tut: Aufgaben finden, üben, Aufsätze schreiben, Prüfungen simulieren, Fortschritt sehen. Eltern, Inhaltspflege und Import sind in «Gymi-Vorbereitung App — Requirements» beschrieben und hier nur erwähnt, wo das Kind davon abhängt.
**Grundlage:** `mathtasks.json`, `sprachpruefung.json`, `aufsatz.json` (Kanton Zürich, 2015 bis 2025) sowie die Mathematik- und Deutsch-PDFs mit Aufgaben, Lösungen, Textblättern und Aufsatzthemen.

**Annahmen:**
- Die Gymi-Prüfung wird auf Papier geschrieben. Die App übernimmt diese Realität: Das Kind löst Mathematik und längere Sprachaufgaben auf Papier und korrigiert sich anhand der Lösung selbst. Eingabe direkt in der App ist die Ausnahme, nicht die Regel.
- Aufgabentext, Lesetexte, Bilder und Lösungen kommen aus den PDFs. Das JSON liefert Metadaten (Jahr, Nummer, Thema, Punkte, Schwierigkeit) und den Katalog.
- «Langgymnasium» im JSON entspricht «Langzeit», «Kurzgymnasium» entspricht «Kurzzeit».
- Werte mit (Annahme) sind Startwerte.

---

## Was die Daten heute hergeben

Die Use Cases richten sich nach dem, was tatsächlich im JSON steht. Die wichtigsten Befunde:

| | Mathematik | Sprachprüfung | Aufsatz |
|---|---|---|---|
| Einträge | 398 (240 Kurzzeit, 158 Langzeit) | 332 (164 Kurzzeit, 168 Langzeit) | 77 Themen |
| Jahrgänge | 2015–2025, beide Typen | 2015–2025, beide Typen | 2015–2025; **Langzeit 2020 fehlt** |
| Aufgabentext | **nur Zusammenfassung** (z. B. «Vergleich von Laufgeschwindigkeiten zweier Läuferinnen…»), nicht die Originalaufgabe | vollständiger Fragetext, aber **ohne Lesetext** und mit flachgedrückten Ankreuz-Optionen | vollständige Aufgabenstellung, aber **ohne Bild, Skizze oder Interview**, auf die sich manche beziehen |
| Lösung | keine | keine | (entfällt) |
| Punkte | vorhanden (1–4 je Teilaufgabe; Langzeit immer 36 pro Prüfung) | Kurzzeit vorhanden; **Langzeit fast immer `null`** (167 von 168) | keine |
| Thema | `category` (28 Werte) und `topic` (frei) | `thema` (21 Werte, 167× «Textverständnis») | keins |
| Schwierigkeit | vorhanden (`leicht`, `einfach`, `mittel`, `mittel-schwer`, `schwer`) | keine | keine |
| Stabile ID | `key` (z. B. `2015-Langgymnasium-1a`) | keine, nur Jahr + Typ + Nummer | keine, nur Jahr + Typ + Nummer |

Konsequenzen für das Kind:
- **Ohne PDFs kann das Kind keine Mathematikaufgabe lösen**, weil die Aufgabe selbst fehlt. Die Mathe-Stories setzen die PDFs voraus.
- **Automatische Korrektur ist mit diesen Daten nicht möglich.** Selbstkorrektur mit Punkten ist deshalb der Kern (3.2, 4.3), automatische Prüfung ist Could (3.3).
- **Schwierigkeit gibt es nur in Mathematik.** Filter und Übungssätze nach Schwierigkeit gelten nur dort.
- **Bei Langzeit-Sprachprüfungen fehlen im JSON die Punkte.** In den PDFs stehen sie (siehe unten); bis sie übertragen sind, kommen Auswertungen dort ohne Punktzahl aus.

### Mathematik-PDFs (geliefert am 30.09.2026)

44 PDFs: Aufgaben und Lösungen 2015–2025 für beide Typen vollständig. Die Lösungen Langzeit 2020 kamen nachträglich von zh.ch.

| | Langzeit (ZAP 1) | Kurzzeit (ZAP 2) |
|---|---|---|
| Prüfungszeit | 60 Minuten | 90 Minuten (in allen lesbaren Heften gleich; 2016–2018 nicht maschinenlesbar, Annahme: ebenfalls 90) |
| Taschenrechner | **verboten** | **erlaubt**: bis 2021 «übliche Sekundarschulrechner», ab 2020 nur bestimmte Modelle (TI-30, Casio FX-82, Sharp EL-501) |
| Aufbau | 9 Aufgaben à 4 Punkte = 36, teils mit a/b | 18–20 Teilaufgaben à 1–4 Punkte, 34–44 Punkte; jede Teilaufgabe ist als Algebra oder Geometrie ausgewiesen |
| Lösungen | 2015, 2023, 2024, 2025: **ausführliches Korrekturschema** mit Zwischenergebnissen und Bewertungsraster je Punktstufe. 2016–2022: **nur 1 Seite Endergebnisse**, ohne Lösungsweg | Endergebnisse mit Punkten je Teilaufgabe, teils mit Teilpunkten und Lösungsskizzen |
| Gescannt ohne Text | Aufgaben 2020 und 2021; Lösungen 2016, 2017, 2018, 2020, 2021 | Aufgaben 2016–2018 (teilweise) und 2020 |

Weitere Befunde:
- **Die Punkte im JSON stimmen mit den Punktetabellen der PDFs überein** (z. B. Kurzzeit 2015: 41, 2020: 38, 2024: 37, 2025: 39). Der `key` lässt sich also sicher einer Aufgabe im PDF zuordnen.
- **Die Lösungen nennen gleichwertige Schreibweisen ausdrücklich**, z. B. «20 min 2 s (oder 20 1/30 min und 1202 s)». Das ist genau die Grundlage, die 3.3 braucht; sie muss nur ins JSON übertragen werden.
- **Bewertungsregeln Langzeit:** «Ein richtiges Endergebnis ohne verständlichen Lösungsweg gibt 0 Punkte.» Fehlende Einheit im Endergebnis kostet 1 Punkt. Die Selbstkorrektur muss diese Regeln kennen, sonst gibt sich das Kind zu viele Punkte.
- **Einige Aufgaben lassen sich nur auf Papier lösen:** Konstruktionen mit Zirkel, Diagramme zeichnen, Würfelnetze («weder ausschneiden noch nachbilden»). Die Lösung ist dann eine Zeichnung.
- **Der Text in manchen PDFs ist nicht verwertbar:** doppelte Textschichten (2023 Kurzzeit) oder falsch codierte Formeln (2024 Kurzzeit). Aufgaben müssen deshalb als Bildausschnitt gezeigt werden, nicht als extrahierter Text.

### Deutsch-PDFs (geliefert am 30.09.2026)

89 PDFs: Sprachprüfung, Lösungen, Textblatt (Lesetext), Aufsatzthemen und einmal Korrekturhinweise zum Aufsatz. Nach mehreren Nachlieferungen liegen **Aufgaben, Lösungen, Textblätter und Aufsatzthemen für 2015–2025 vollständig** vor, für Langzeit und Kurzzeit.

Zeiten und Hilfsmittel (aus den Deckblättern):

| | Langzeit | Kurzzeit |
|---|---|---|
| Sprachprüfung | 45 Minuten, keine Hilfsmittel | 45 Minuten, keine Hilfsmittel, auch kein Wörterbuch |
| Aufsatz | 60 Minuten, 3 Themen zur Wahl, Füllfeder oder Kugelschreiber | 90 Minuten, 4 Themen zur Wahl, **Rechtschreibwörterbuch erlaubt** |

Weitere Befunde:
- **Die Langzeit-Sprachprüfungen haben Punkte.** Sie stehen im PDF (z. B. 2015: «Aufgabe 1 2 P.», 2020: Total 51 P.), fehlen aber im JSON. Die Lücke lässt sich schliessen; Kurzzeit hat jeweils 75 Punkte.
- **Die Lösungen sind Korrekturhinweise, keine einzelne richtige Antwort:** Musterantworten («1 Punkt für Antworten wie: …»), Zeilenverweise (Z. 1, Z. 5–6), Regeln wie «Orthografie wird nicht berücksichtigt» oder «1 Punkt Abzug für jede überzählige Unterstreichung, kein negatives Resultat». Damit wird die Selbstkorrektur (4.3) deutlich verlässlicher.
- **Die Textblätter haben Zeilennummern** (5, 10, 15 …), auf die sich Fragen und Lösungen beziehen. Das bestätigt 4.1.
- **Aufsatzthemen verweisen auf Material im PDF** (z. B. das Interview zu «Was bedeutet Familie?»). Es steht in den Themen-PDFs und kann angezeigt werden.
- **Bewertungskriterien zum Aufsatz gibt es nur für Langzeit 2015** («Positiv fällt ins Gewicht, wenn … / Negativ, wenn …»). Für alle anderen Themen muss die Checkliste (5.3) aus der Aufgabenstellung abgeleitet werden.
- **Das JSON und die PDFs widersprechen sich:** Langzeit 2020 hat Aufsatzthemen im PDF, fehlt aber im JSON.
- **Gescannt ohne Text:** 2020 komplett (Aufgaben, Lösungen, Aufsatz, Textblatt Langzeit). Dort geht Vorlesen (8.1) nur mit nachträglich erfasstem Text.
- **Dateinamen sind nicht einheitlich** und lassen sich nicht automatisch zuordnen: `2020_sprachpruefung_kg.pdf` ist die **Lösung** Kurzzeit, `2020_sprachpruefung_kg1.pdf` die Aufgabe, `2020_sprachpruefung.pdf` die Aufgabe Langzeit, `2021_sprachprueufng_kg.pdf` die **Lösung** Kurzzeit 2021, `2016_textverstaendnis_teil_a.pdf` die Aufgabe Langzeit 2016, `2018_aufsatzthemen.pdf` und `2019_textblatt.pdf` gehören zu Langzeit.

---

## Akteure

- **Kind Langzeit (11–12)** — übt 20 bis 30 Minuten, liest die Oberfläche in einfacher Sprache, braucht klare nächste Schritte und Ermutigung. Schreibt Erzählungen und Zeitungsberichte (3 Aufsatzthemen pro Jahr).
- **Kind Kurzzeit (14–15)** — übt selbständig und zielgerichtet, will Effizienz und ehrliche Zahlen. Schreibt Erörterungen und Erzählungen (4 Aufsatzthemen pro Jahr), löst schwerere Algebra und Geometrie.
- **Wiederkehrendes Kind** — hat schon Wochen geübt; braucht nicht mehr den Katalog, sondern «was als Nächstes».
- **Kind mit Leseschwäche** — scheitert an langen Lesetexten und kleiner Schrift, nicht am Stoff.
- **System** — erinnert, plant Wiederholungen, rechnet Zeit in Simulationen.

---

## 1. Einstieg und Tagesstart

### 1.1 Sofort die erste Aufgabe lösen
**Als** Kind Langzeit beim allerersten Öffnen **möchte ich** ohne Erklärseiten direkt eine passende Aufgabe bekommen, **damit** ich merke, dass die App mir hilft, bevor mir langweilig wird.

*Priorität:* Must

**Akzeptanzkriterien**
- **Gegeben** ein gewählter Prüfungstyp und kein Fortschritt **Wenn** die Startseite erscheint **Dann** wird genau eine Einstiegsaufgabe vorgeschlagen, bei Mathematik aus der Schwierigkeit `leicht` oder `einfach`.
- **Gegeben** die Einstiegsaufgabe **Wenn** das Kind sie löst und korrigiert **Dann** wird ihm gesagt, was es geschafft hat, und eine zweite Aufgabe angeboten.
- **Gegeben** die PDFs sind für diese Aufgabe noch nicht geladen **Wenn** die Einstiegsaufgabe gewählt wird **Dann** schlägt die App nur Aufgaben vor, deren Inhalt vollständig verfügbar ist.

### 1.2 Heute weitermachen
**Als** wiederkehrendes Kind **möchte ich** beim Öffnen sehen, was heute sinnvoll ist (angefangene Aufgabe, fällige Wiederholungen, Vorschlag), **damit** ich keine Zeit mit Suchen verliere, sondern gleich übe.

*Priorität:* Must

**Akzeptanzkriterien**
- **Gegeben** eine angefangene, nicht abgegebene Aufgabe oder Simulation **Wenn** die App geöffnet wird **Dann** wird sie als Erstes zum Fortsetzen angeboten.
- **Gegeben** fällige Wiederholungen (siehe 7.3) **Wenn** die Startseite erscheint **Dann** ist ihre Anzahl sichtbar und sie lassen sich mit einer Aktion starten.
- **Gegeben** nichts ist angefangen und nichts fällig **Wenn** die Startseite erscheint **Dann** wird eine neue Übung aus einem noch wenig geübten Thema vorgeschlagen.
- **Gegeben** ein eingetragenes Prüfungsdatum **Wenn** die Startseite erscheint **Dann** zeigt sie die verbleibenden Tage.

### 1.3 Kurze Übung für wenig Zeit
**Als** Kind Langzeit an einem vollen Schultag **möchte ich** eine Übung wählen, die in 10 oder 20 Minuten (Annahme) zu schaffen ist, **damit** ich auch an solchen Tagen dranbleibe, statt ganz auszulassen.

*Priorität:* Should

**Akzeptanzkriterien**
- **Gegeben** eine gewählte Dauer **Wenn** die Übung erstellt wird **Dann** besteht sie aus Aufgaben, deren Punktzahl zusammen in die Zeit passt (Annahme: rund 3 Minuten pro Mathematikpunkt, abgeleitet aus Originalzeit und Gesamtpunkten).
- **Gegeben** eine Sprachaufgabe ohne Punktzahl (Langzeit) **Wenn** die Dauer geschätzt wird **Dann** gilt ein fester Schätzwert und die Übung überschreitet die Zeit trotzdem nicht um mehr als 5 Minuten.
- **Gegeben** die Zeit ist um, aber eine Aufgabe ist noch offen **Wenn** das Kind weitermachen will **Dann** darf es das; es gibt keinen Zwang zum Abbrechen.

---

## 2. Aufgaben finden

### 2.1 Nach Fach und Thema filtern
**Als** Kind Kurzzeit **möchte ich** Aufgaben nach Fach (Mathematik, Sprachprüfung, Aufsatz) und Thema filtern, **damit** ich z. B. gezielt «Termumformung» oder «Konjunktiv» übe, wenn das gerade in der Schule dran ist.

*Priorität:* Must

**Akzeptanzkriterien**
- **Gegeben** Fach Mathematik **Wenn** das Thema gewählt wird **Dann** stehen die Kategorien aus `category` zur Wahl, zusammengeführt wo sie dasselbe meinen (z. B. «Konstruktion» und «Geometrie: Konstruktion»).
- **Gegeben** Fach Sprachprüfung **Wenn** das Thema gewählt wird **Dann** stehen die Werte aus `thema` zur Wahl, und die Anzahl der Aufgaben je Thema ist sichtbar.
- **Gegeben** ein Thema, das es für den gewählten Prüfungstyp nicht gibt **Wenn** die Themenliste erscheint **Dann** fehlt es dort, statt eine leere Liste zu liefern.
- **Gegeben** Filter ohne Treffer **Wenn** die Liste erscheint **Dann** sagt die App, dass nichts passt, und bietet an, die Filter zurückzusetzen.

### 2.2 Nach Schwierigkeit wählen
**Als** Kind Langzeit, das sich unsicher fühlt **möchte ich** mit leichten Mathematikaufgaben beginnen und mich hocharbeiten, **damit** ich nicht gleich an einer schweren Aufgabe scheitere und aufgebe.

*Priorität:* Should

**Akzeptanzkriterien**
- **Gegeben** Fach Mathematik **Wenn** nach Schwierigkeit gefiltert wird **Dann** gibt es vier Stufen; `leicht` und `einfach` gelten als dieselbe Stufe.
- **Gegeben** Fach Sprachprüfung oder Aufsatz **Wenn** die Filter erscheinen **Dann** wird kein Schwierigkeitsfilter angeboten.
- **Gegeben** das Kind hat 5 Aufgaben einer Stufe in Folge richtig (Annahme) **Wenn** die nächste Aufgabe vorgeschlagen wird **Dann** kommt sie aus der nächsthöheren Stufe.

### 2.3 Sehen, was schon erledigt ist
**Als** wiederkehrendes Kind **möchte ich** in jeder Liste erkennen, welche Aufgaben ich schon gelöst habe und wie viele Punkte ich hatte, **damit** ich nicht versehentlich dieselben Aufgaben immer wieder mache.

*Priorität:* Should

**Akzeptanzkriterien**
- **Gegeben** eine gelöste Aufgabe **Wenn** die Liste erscheint **Dann** zeigt sie den Status (offen, teilweise, richtig) und bei Aufgaben mit Punktzahl die erreichten von möglichen Punkten.
- **Gegeben** «nur ungelöste» ist gewählt **Wenn** alle Aufgaben des Filters gelöst sind **Dann** meldet die App das als Erfolg und bietet eine Wiederholung an.
- **Gegeben** ein Katalog-Update ändert eine gelöste Aufgabe **Wenn** die Liste erscheint **Dann** bleibt ihr Status erhalten (stabile ID).

---

## 3. Mathematik üben

### 3.1 Originalaufgabe ansehen und auf Papier lösen
**Als** Kind **möchte ich** die Mathematikaufgabe genau so sehen wie in der Prüfung, mit Zeichnungen und Tabellen, **damit** ich mich an die echte Darstellung gewöhne und auf Papier rechne wie am Prüfungstag.

*Priorität:* Must (setzt die PDFs voraus)

**Akzeptanzkriterien**
- **Gegeben** eine Aufgabe mit hinterlegtem PDF-Ausschnitt **Wenn** sie geöffnet wird **Dann** erscheint nur diese Aufgabe (z. B. 1a), nicht die ganze Prüfungsseite, und lässt sich vergrössern.
- **Gegeben** eine Teilaufgabe (1a, 1b) mit gemeinsamem Einleitungstext **Wenn** 1b geöffnet wird **Dann** ist der gemeinsame Einleitungstext ebenfalls sichtbar.
- **Gegeben** eine Aufgabe ohne PDF-Ausschnitt **Wenn** sie in einer Liste erscheint **Dann** ist sie als «noch nicht verfügbar» erkennbar und lässt sich nicht öffnen.
- **Gegeben** eine Konstruktionsaufgabe (`category` Konstruktion) **Wenn** sie geöffnet wird **Dann** wird das Kind darauf hingewiesen, Zirkel und Geodreieck bereitzulegen.
- **Gegeben** eine Langzeit-Aufgabe **Wenn** sie geöffnet wird **Dann** wird das Kind daran erinnert, ohne Taschenrechner zu rechnen; **gegeben** eine Kurzzeit-Aufgabe, **dann** wird gesagt, dass ein einfacher Taschenrechner erlaubt ist.
- **Gegeben** eine Aufgabe auf Häuschenpapier im Original **Wenn** das Kind sie ausdrucken will **Dann** wird der Ausschnitt mit Lösungsfläche gedruckt (Annahme: Drucken ist Could).

### 3.2 Lösung aufdecken und sich selbst Punkte geben
**Als** Kind Kurzzeit **möchte ich** nach dem Rechnen die offizielle Lösung sehen und mir selbst Punkte geben, auch Teilpunkte, **damit** meine Statistik ehrlich zeigt, wo ich stehe, obwohl die App meine Rechnung auf Papier nicht lesen kann.

*Priorität:* Must

**Akzeptanzkriterien**
- **Gegeben** eine geöffnete Aufgabe **Wenn** das Kind «Lösung zeigen» wählt **Dann** wird zuerst gefragt, ob es fertig ist, damit die Lösung nicht versehentlich zu früh erscheint.
- **Gegeben** die sichtbare Lösung **Wenn** das Kind sich einstuft **Dann** kann es 0 bis zur Punktzahl aus `points` vergeben, in ganzen Punkten.
- **Gegeben** eine Aufgabe mit Bewertungsraster im Korrekturschema (Langzeit 2015, 2023–2025) **Wenn** das Kind sich einstuft **Dann** wählt es die Stufe, die auf seinen Lösungsweg zutrifft (z. B. «richtiger Lösungsweg, Rechenfehler»), und die Punkte ergeben sich daraus.
- **Gegeben** eine Langzeit-Aufgabe **Wenn** das Kind die volle Punktzahl geben will **Dann** wird es gefragt, ob der Lösungsweg aufgeschrieben ist und die Einheit stimmt, weil sonst an der Prüfung Punkte abgezogen werden.
- **Gegeben** eine Lösung, die nur als Zeichnung vorliegt (Konstruktion) **Wenn** sie erscheint **Dann** kann das Kind sie vergrössern, um die eigene Zeichnung zu vergleichen.
- **Gegeben** die Lösung wurde angesehen, bevor das Kind etwas eingestuft hat **Wenn** es die Aufgabe schliesst **Dann** gilt sie als «angeschaut, nicht gelöst» und zählt nicht als richtig.
- **Gegeben** keine Lösung im Datenbestand **Wenn** «Lösung zeigen» gewählt wird **Dann** sagt die App offen, dass keine vorliegt, und das Kind kann sich trotzdem einstufen oder die Aufgabe für die Eltern markieren.

### 3.3 Endresultat eintippen und prüfen lassen
**Als** Kind Langzeit **möchte ich** bei Aufgaben mit einem eindeutigen Endresultat die Zahl eintippen und sofort erfahren, ob sie stimmt, **damit** ich nicht selbst beurteilen muss, ob «3 min 20 s» dasselbe ist wie «200 s».

*Priorität:* Could (braucht ein neues Feld mit Lösungswert und Einheit je Aufgabe; die Werte samt gleichwertigen Schreibweisen stehen in den Lösungs-PDFs und müssen übertragen werden. Nicht geeignet für Konstruktionen, Diagramme und Aufgaben mit mehreren Lösungen wie Kombinatorik)

**Akzeptanzkriterien**
- **Gegeben** eine Aufgabe mit hinterlegtem Lösungswert **Wenn** ein gleichwertiger Wert eingegeben wird (0,5 / 1/2 / 0.5; 3 min 20 s / 200 s) **Dann** gilt er als richtig.
- **Gegeben** ein richtiges Resultat mit falscher oder fehlender Einheit **Wenn** geprüft wird **Dann** wird auf die Einheit hingewiesen, statt die Antwort als falsch zu werten.
- **Gegeben** eine falsche Eingabe **Wenn** die Rückmeldung erscheint **Dann** darf das Kind es noch einmal versuchen, bevor die Lösung gezeigt wird.
- **Gegeben** eine Aufgabe ohne Lösungswert **Wenn** sie geöffnet wird **Dann** gibt es kein Eingabefeld, sondern den Ablauf aus 3.2.
- **Gegeben** ein richtiges Endresultat bei einer Langzeit-Aufgabe **Wenn** die Rückmeldung erscheint **Dann** wird daran erinnert, dass an der Prüfung ohne Lösungsweg 0 Punkte vergeben werden.

### 3.4 Lösungsweg nachvollziehen
**Als** Kind Langzeit mit falschem Resultat **möchte ich** die Zwischenergebnisse der offiziellen Lösung Schritt für Schritt aufdecken, **damit** ich herausfinde, an welcher Stelle ich falsch abgebogen bin, und nicht nur die richtige Zahl sehe.

*Priorität:* Should

**Akzeptanzkriterien**
- **Gegeben** eine Aufgabe mit Zwischenergebnissen im Korrekturschema (z. B. 2015 Aufgabe 1a: «459 s : 17 = 27 s», dann «19 min 35 s + 27 s = 20 min 2 s») **Wenn** das Kind den Lösungsweg öffnet **Dann** wird ein Zwischenergebnis nach dem anderen aufgedeckt.
- **Gegeben** eine Aufgabe, zu der nur das Endergebnis vorliegt (Langzeit 2016–2022) **Wenn** das Kind den Lösungsweg öffnen will **Dann** sagt die App, dass kein Lösungsweg vorhanden ist, und zeigt nur das Endergebnis.
- **Gegeben** ein Jahrgang ohne Lösungen **Wenn** eine Aufgabe dieses Jahrgangs geöffnet wird **Dann** ist vor dem Lösen klar erkennbar, dass es keine Lösung gibt.

---

## 4. Sprachprüfung üben

### 4.1 Lesetext und Fragen gleichzeitig sehen
**Als** Kind Kurzzeit **möchte ich** den Lesetext und die Fragen dazu gleichzeitig vor mir haben und zu den genannten Zeilen springen, **damit** ich wie in der Prüfung mit dem Text arbeiten kann, statt ständig hin- und herzublättern.

*Priorität:* Must (setzt die PDFs voraus)

**Akzeptanzkriterien**
- **Gegeben** eine Aufgabe zum Thema «Textverständnis» **Wenn** sie geöffnet wird **Dann** ist der zugehörige Lesetext des Jahrgangs erreichbar, auf dem iPad neben den Fragen.
- **Gegeben** eine Frage mit Zeilenangabe (z. B. «siehe Zeilen 9–24») **Wenn** das Kind darauf tippt **Dann** springt der Lesetext zu diesen Zeilen und hebt sie hervor.
- **Gegeben** ein iPhone **Wenn** Lesetext und Fragen nicht nebeneinander passen **Dann** lässt sich mit einer Aktion zwischen ihnen wechseln, ohne die Position im Text zu verlieren.
- **Gegeben** kein Lesetext für diesen Jahrgang **Wenn** eine Textverständnisaufgabe geöffnet werden soll **Dann** ist sie als «noch nicht verfügbar» gekennzeichnet.

### 4.2 Grammatik gezielt üben
**Als** Kind Langzeit **möchte ich** Grammatikaufgaben eines Themas (z. B. Verben, Satzglieder, Wortarten) aus mehreren Jahrgängen hintereinander lösen, **damit** ich ein Thema richtig verstehe, statt es nur einmal pro Jahrgang zu sehen.

*Priorität:* Should

**Akzeptanzkriterien**
- **Gegeben** ein gewähltes Grammatikthema **Wenn** die Übung startet **Dann** folgen die Aufgaben dieses Themas aus allen Jahrgängen des eigenen Prüfungstyps, neueste zuerst (Annahme).
- **Gegeben** eine Aufgabe, die keinen Lesetext braucht **Wenn** sie geöffnet wird **Dann** erscheint kein Lesetext.
- **Gegeben** ein Thema mit weniger als 3 Aufgaben im eigenen Prüfungstyp (Annahme) **Wenn** es gewählt wird **Dann** wird angeboten, Aufgaben desselben Themas aus dem anderen Prüfungstyp dazuzunehmen, und das wird klar gesagt.

### 4.3 Sprachaufgaben selbst korrigieren
**Als** Kind **möchte ich** meine Antworten mit der Lösung vergleichen und mich einstufen, **damit** ich auch bei Textverständnis-Fragen, wo mehrere Formulierungen richtig sein können, eine Rückmeldung bekomme.

*Priorität:* Must

**Akzeptanzkriterien**
- **Gegeben** eine Kurzzeit-Aufgabe mit `punktzahl` **Wenn** das Kind sich einstuft **Dann** vergibt es 0 bis `punktzahl` Punkte.
- **Gegeben** eine Langzeit-Aufgabe, deren Punkte noch nicht aus dem PDF ins JSON übertragen sind **Wenn** das Kind sich einstuft **Dann** wählt es «richtig», «teilweise» oder «falsch», und nirgends erscheint eine erfundene Punktzahl.
- **Gegeben** eine Aufgabe mit mehreren Teilfragen (z. B. 2.1 bis 2.4) **Wenn** die Lösung erscheint **Dann** sind die Teilfragen einzeln zugeordnet, damit das Kind jede für sich vergleichen kann.
- **Gegeben** eine Lösung mit Musterantworten («Antworten wie …») **Wenn** sie erscheint **Dann** ist klar, dass auch andere Formulierungen mit gleichem Inhalt zählen.
- **Gegeben** eine Aufgabe mit Korrekturregel (z. B. Abzug für überzählige Unterstreichungen, Rechtschreibung zählt mit) **Wenn** das Kind sich einstuft **Dann** wird die Regel direkt bei der Einstufung angezeigt.
- **Gegeben** ein Jahrgang ohne Lösung (2024) **Wenn** eine Aufgabe daraus geöffnet wird **Dann** ist vor dem Lösen erkennbar, dass es keine Lösung gibt.

### 4.4 Ankreuzaufgaben direkt in der App lösen
**Als** Kind Kurzzeit **möchte ich** Multiple-Choice-Aufgaben direkt antippen und sofort korrigiert bekommen, **damit** ich schnelle Aufgaben auch unterwegs ohne Papier üben kann.

*Priorität:* Could (braucht strukturierte Antwortoptionen und Lösungsschlüssel; im heutigen JSON sind die Optionen in den Fliesstext geschrieben)

**Akzeptanzkriterien**
- **Gegeben** eine Ankreuzaufgabe mit strukturierten Optionen **Wenn** das Kind eine Option antippt **Dann** bleibt die Wahl änderbar, bis es abgibt.
- **Gegeben** die Abgabe **Wenn** die Rückmeldung erscheint **Dann** sind richtige und gewählte Option unterscheidbar markiert, auch ohne Farbe.
- **Gegeben** eine Ankreuzaufgabe ohne strukturierte Optionen **Wenn** sie geöffnet wird **Dann** läuft sie über den Papier-Ablauf aus 4.3.

---

## 5. Aufsatz

### 5.1 Ein Thema wählen wie in der Prüfung
**Als** Kind Kurzzeit **möchte ich** die Themen eines Jahrgangs nebeneinander sehen und mich für eines entscheiden, **damit** ich übe, in wenigen Minuten das Thema zu wählen, zu dem mir am meisten einfällt, denn genau das verlangt die Prüfung.

*Priorität:* Must

**Akzeptanzkriterien**
- **Gegeben** ein gewählter Jahrgang **Wenn** die Themenwahl erscheint **Dann** zeigt sie alle Themen dieses Jahrgangs (Kurzzeit 4, Langzeit 3) mit Titel und Aufgabenstellung.
- **Gegeben** ein Thema, das sich auf ein Bild, eine Skizze oder ein Interview bezieht (z. B. «Vor dem Bildschirm», «Radfahrer verletzt») **Wenn** das Material vorliegt **Dann** ist es beim Thema sichtbar; **wenn nicht**, ist das Thema als «Material fehlt» gekennzeichnet.
- **Gegeben** ein Thema mit «(kein Titel vorgegeben)» **Wenn** es angezeigt wird **Dann** erscheint dieser Platzhalter nicht als Titel, sondern der Hinweis, dass das Kind selbst einen Titel setzen muss.
- **Gegeben** ein Jahrgang, der nur im JSON oder nur als PDF vorliegt (Langzeit 2020, 2024, 2025) **Wenn** die Jahrgänge erscheinen **Dann** werden nur Themen angeboten, zu denen Aufgabenstellung und nötiges Material vollständig vorliegen.
- **Gegeben** Kurzzeit **Wenn** die Themenwahl erscheint **Dann** wird gesagt, dass an der Prüfung ein Rechtschreibwörterbuch erlaubt ist; bei Langzeit nicht.

### 5.2 Einen Aufsatz schreiben
**Als** Kind **möchte ich** meinen Aufsatz mit der Prüfungszeit schreiben, auf Papier oder in der App, **damit** ich lerne, in dieser Zeit einen vollständigen Text mit Einleitung, Hauptteil und Schluss fertigzubekommen.

*Priorität:* Should

**Akzeptanzkriterien**
- **Gegeben** ein gewähltes Thema **Wenn** das Kind startet **Dann** kann es zwischen «auf Papier» (nur Timer) und «in der App» (Texteingabe mit Timer) wählen; die Zeit ist 60 Minuten (Langzeit) bzw. 90 Minuten (Kurzzeit).
- **Gegeben** Texteingabe in der App **Wenn** die App unterbrochen oder beendet wird **Dann** ist der Text beim Zurückkehren vollständig da.
- **Gegeben** Texteingabe in der App **Wenn** das Kind schreibt **Dann** ist die Wortzahl jederzeit abrufbar.
- **Gegeben** die Zeit ist abgelaufen **Wenn** das Kind noch schreibt **Dann** wird es informiert, darf aber zu Ende schreiben; die Überziehung wird festgehalten.

### 5.3 Den Aufsatz anhand von Kriterien einschätzen
**Als** Kind Kurzzeit **möchte ich** meinen fertigen Aufsatz Punkt für Punkt gegen die Aufgabenstellung prüfen, **damit** ich merke, wenn ich einen Teil der Aufgabe vergessen habe, z. B. «Ziehe am Ende ein Fazit».

*Priorität:* Should

**Akzeptanzkriterien**
- **Gegeben** ein abgeschlossener Aufsatz **Wenn** die Einschätzung startet **Dann** erscheinen die Teilaufträge aus der Aufgabenstellung als Checkliste (z. B. «Erkläre, wie es dazu kam» / «Erzähle ein Erlebnis» / «Ziehe ein Fazit»).
- **Gegeben** eine Langzeit-Aufgabe mit Formvorgabe (Präteritum, Ich-Form, Zeitungsbericht) **Wenn** die Checkliste erscheint **Dann** sind diese Vorgaben eigene Punkte darauf.
- **Gegeben** ein Thema mit offiziellen Korrekturhinweisen (bisher nur Langzeit 2015) **Wenn** die Checkliste erscheint **Dann** enthält sie die Punkte daraus, getrennt nach «spricht dafür» und «spricht dagegen» (z. B. «wenn nicht im Präteritum erzählt wird»).
- **Gegeben** eine eingestufte Checkliste **Wenn** das Kind abschliesst **Dann** ist das Ergebnis beim Aufsatz gespeichert und später wieder einsehbar.
- **Gegeben** ein leerer oder sehr kurzer Text (unter 150 Wörtern, Annahme) **Wenn** das Kind die Einschätzung starten will **Dann** wird es vorher darauf hingewiesen.

---

## 6. Prüfung simulieren

### 6.1 Einen Jahrgang unter Prüfungsbedingungen schreiben
**Als** Kind **möchte ich** einen ganzen Jahrgang (Mathematik, Sprachprüfung, Aufsatz) mit Originalzeit und ohne Lösungen durchspielen, **damit** ich weiss, wie sich Tempo und Ermüdung am echten Prüfungstag anfühlen.

*Priorität:* Must

**Akzeptanzkriterien**
- **Gegeben** ein gewählter Jahrgang **Wenn** die Simulation startet **Dann** läuft je Fach die Originalzeit, und Lösungen sind gesperrt, bis das Fach abgegeben ist.
- **Gegeben** ein Jahrgang, für den nicht alle Aufgaben verfügbar sind **Wenn** er zur Simulation angeboten wird **Dann** wird das vor dem Start gesagt, damit keine Simulation mit Lücken beginnt.
- **Gegeben** eine unterbrochene Simulation **Wenn** das Kind zurückkehrt **Dann** kann es fortsetzen, und die Zeit ist weitergelaufen.
- **Gegeben** eine abgelaufene Zeit **Wenn** das Kind noch rechnet **Dann** wird das Fach abgeschlossen, und das Kind stuft danach seine Papierlösungen ein.

### 6.2 Nur ein Fach simulieren
**Als** Kind Langzeit **möchte ich** nur die Mathematik- oder nur die Sprachprüfung eines Jahrgangs unter Zeitdruck lösen, **damit** ich eine realistische Übung in eine normale Übungszeit bekomme.

*Priorität:* Should

**Akzeptanzkriterien**
- **Gegeben** ein gewähltes Fach **Wenn** die Teilsimulation startet **Dann** gilt die Originalzeit dieses Fachs.
- **Gegeben** eine abgeschlossene Teilsimulation **Wenn** der Fortschritt erscheint **Dann** zählt sie in die Fachstatistik, aber nicht als vollständige Prüfung.

### 6.3 Auswertung nach der Simulation
**Als** Kind Kurzzeit **möchte ich** nach der Simulation meine Punkte je Aufgabe und je Thema sehen und wo ich zu viel Zeit verloren habe, **damit** ich für die nächste Simulation weiss, welche Aufgaben ich zuerst lösen und welche ich überspringen sollte.

*Priorität:* Must

**Akzeptanzkriterien**
- **Gegeben** eine eingestufte Mathematiksimulation **Wenn** die Auswertung erscheint **Dann** zeigt sie erreichte von möglichen Punkten (z. B. 24 von 36) und die Punkte je `category`.
- **Gegeben** eine Langzeit-Sprachsimulation ohne Punktzahlen **Wenn** die Auswertung erscheint **Dann** zeigt sie Anteil richtig / teilweise / falsch statt Punkten.
- **Gegeben** ein Aufsatz in der Simulation **Wenn** die Auswertung erscheint **Dann** ist das Gesamtergebnis als unvollständig gekennzeichnet, bis der Aufsatz eingeschätzt ist.
- **Gegeben** keine bekannte Bestehensgrenze **Wenn** die Auswertung erscheint **Dann** wird keine Aussage über Bestehen gemacht.
- **Gegeben** eine zweite Simulation **Wenn** die Auswertung erscheint **Dann** ist der Vergleich zur letzten Simulation desselben Fachs sichtbar.

**Rahmenbedingungen (Simulation):** Restzeit aus der Systemuhr, nicht durch Uhrverstellen verlängerbar. Zeitzuschlag gemäss Eltern-Einstellung (Requirements 6.4). Originalzeiten aus den PDFs: Langzeit Mathematik 60, Sprachprüfung 45, Aufsatz 60 Minuten (zusammen 165); Kurzzeit Mathematik 90, Sprachprüfung 45, Aufsatz 90 Minuten (zusammen 225). Hilfsmittel wie im Original: Taschenrechner nur Kurzzeit-Mathematik, Wörterbuch nur Kurzzeit-Aufsatz. Eine vollständige Simulation braucht alle drei Teile eines Jahrgangs samt Lösungen; das ist inzwischen für alle Jahrgänge 2015–2025 der Fall. Kurzzeit-Auswertungen zeigen Punkte getrennt nach Algebra und Geometrie, wie in der offiziellen Punkteverteilung.

---

## 7. Fortschritt und Lernplan

### 7.1 Stand je Thema sehen
**Als** Kind Kurzzeit **möchte ich** meine Quote je Mathematik-Kategorie und Sprach-Thema sehen, **damit** ich meine Zeit dort einsetze, wo ich die meisten Punkte gewinnen kann.

*Priorität:* Should

**Akzeptanzkriterien**
- **Gegeben** kein Fortschritt **Wenn** die Fortschrittsseite erscheint **Dann** erklärt sie, wie der Fortschritt entsteht, und verweist auf die erste Übung.
- **Gegeben** weniger als 5 eingestufte Aufgaben in einem Thema (Annahme) **Wenn** die Seite erscheint **Dann** steht dort «noch zu wenig Daten» statt einer Quote.
- **Gegeben** genug Daten **Wenn** die Seite erscheint **Dann** sind die Themen nach Gewicht sortierbar, also nach Quote mal Häufigkeit in den Prüfungen (z. B. Termumformung erscheint 37-mal, Koordinatensystem einmal).

### 7.2 Schwächen gezielt üben
**Als** Kind **möchte ich** mit einer Aktion einen Übungssatz aus meinen schwächsten Themen bekommen, **damit** ich nicht selbst herausfinden muss, was ich als Nächstes üben soll.

*Priorität:* Should

**Akzeptanzkriterien**
- **Gegeben** erkannte Schwächen **Wenn** «Schwächen üben» gewählt wird **Dann** entsteht ein Satz von 10 Aufgaben (Annahme) aus den drei schwächsten Themen, noch ungelöste zuerst.
- **Gegeben** ein schwaches Thema mit zu wenig ungelösten Aufgaben **Wenn** der Satz gebaut wird **Dann** wird mit verwandten Kategorien aufgefüllt, und das Kind erfährt das.
- **Gegeben** noch keine erkennbaren Schwächen **Wenn** «Schwächen üben» gewählt wird **Dann** wird stattdessen eine gemischte Übung angeboten und erklärt, warum.

### 7.3 Falsche Aufgaben wiederholen
**Als** wiederkehrendes Kind **möchte ich**, dass Aufgaben, bei denen ich weniger als die volle Punktzahl hatte, nach einigen Tagen wiederkommen, **damit** ich den Lösungsweg wirklich kann und ihn nicht nur einmal gesehen habe.

*Priorität:* Should

**Akzeptanzkriterien**
- **Gegeben** eine Aufgabe mit weniger als voller Punktzahl oder «falsch» **Wenn** 3 Tage vergangen sind (Annahme) **Dann** steht sie in «Zu wiederholen».
- **Gegeben** eine wiederholte Aufgabe mit voller Punktzahl **Wenn** sie eingestuft ist **Dann** kommt sie erst nach längerer Frist (Annahme: 10 Tage) oder gar nicht mehr.
- **Gegeben** eine leere Wiederholungsliste **Wenn** sie geöffnet wird **Dann** sagt die App, dass nichts ansteht, und schlägt eine neue Übung vor.

### 7.4 Dranbleiben ohne schlechtes Gewissen
**Als** Kind Langzeit **möchte ich** sehen, an wie vielen Tagen ich diese Woche geübt habe, **damit** ich stolz auf meine Routine bin, ohne dass ein verpasster Tag alles zunichte macht.

*Priorität:* Could

**Akzeptanzkriterien**
- **Gegeben** Übungstage in der aktuellen Woche **Wenn** die Startseite erscheint **Dann** ist die Anzahl sichtbar (z. B. «3 von 4 Tagen», Wochenziel Annahme: 4).
- **Gegeben** ein verpasster Tag **Wenn** die App am nächsten Tag geöffnet wird **Dann** gibt es keinen Vorwurf und keinen verlorenen «Rekord», sondern einen Vorschlag für heute.
- **Gegeben** eine Übung unter 5 Minuten (Annahme) **Wenn** der Tag bewertet wird **Dann** zählt er trotzdem als Übungstag.

---

## 8. Lesbarkeit und Zugänglichkeit

### 8.1 Aufgaben vergrössern und vorlesen lassen
**Als** Kind mit Leseschwäche **möchte ich** Aufgaben und Lesetexte gross darstellen und mir vorlesen lassen, **damit** ich an der Sprachprüfung nicht wegen des Lesetempos scheitere, sondern zeigen kann, was ich verstehe.

*Priorität:* Should

**Akzeptanzkriterien**
- **Gegeben** die grösste Systemschrift **Wenn** eine Aufgabe erscheint **Dann** ist nichts abgeschnitten und alles durch Scrollen erreichbar.
- **Gegeben** eine Aufgabe als Text (Sprachprüfung, Aufsatz) **Wenn** Vorlesen gewählt wird **Dann** wird sie auf Deutsch vorgelesen und der vorgelesene Abschnitt ist erkennbar.
- **Gegeben** eine Aufgabe, die nur als PDF-Bild vorliegt **Wenn** VoiceOver aktiv ist **Dann** wird die Beschreibung aus dem JSON vorgelesen und die Aufgabe als «nicht vollständig barrierefrei» gekennzeichnet.
- **Gegeben** eine laufende Simulation **Wenn** Vorlesen benutzt wird **Dann** ist es erlaubt, falls die Eltern Nachteilsausgleich eingestellt haben; sonst wird darauf hingewiesen, dass es an der Prüfung nicht verfügbar ist.

**Rahmenbedingungen (für alle Kind-Stories):**
- Langzeit: Oberfläche in einfacher Sprache, Du-Form, kurze Sätze. Kurzzeit: sachlich, ohne Kindersprache.
- Schweizer Rechtschreibung (ss statt ß). Die JSON-Felder `category` und `topic` in Mathematik enthalten Umschreibungen wie «Rueckwaertsrechnen» und «Flaeche»; dem Kind werden sie mit Umlauten gezeigt.
- Jede Eingabe und jede Einstufung wird sofort gespeichert; kein Verlust bei Unterbrechung.
- Nach dem ersten Laden funktioniert alles in diesem Dokument offline.

---

## Offene Fragen

Durch die PDFs geklärt: Es gibt Lösungen (mit Lücken, siehe oben), die Punkte für Langzeit-Deutsch stehen in den PDFs, und die Originalzeiten sind bekannt.

1. **Aufgaben aus den PDFs ausschneiden:** Schneidest du jede Aufgabe vorab als Bild zu, oder soll das JSON Seite und Bereich im PDF angeben? Wegen gescannter Seiten und unbrauchbarer Textschichten geht es nur über Bildausschnitte. Davon hängen 3.1, 4.1 und 5.1 ab.
2. **Fehlende Dateien:** Geklärt. Alle Aufgaben, Lösungen, Textblätter und Aufsatzthemen 2015–2025 liegen vor. Offizielle Korrekturhinweise zum Aufsatz gibt es weiterhin nur für Langzeit 2015.
3. **JSON ergänzen:** Sollen die Punkte der Langzeit-Sprachprüfung, der Aufsatz Langzeit 2020 und die Einteilung Algebra/Geometrie (Kurzzeit-Mathematik) ins JSON übertragen werden? Alle drei stehen in den PDFs.
4. **Korrekturhinweise übernehmen:** Sollen Musterantworten, Korrekturregeln und Bewertungsraster als Text ins JSON, damit die Selbstkorrektur sie direkt anzeigen kann (3.2, 4.3)? Oder reicht es, die Lösungsseite als Bild zu zeigen?
5. **Eingabe in der App:** Soll Mathematik bewusst auf Papier bleiben (wie in der Prüfung), oder willst du mittelfristig Eingabe in der App (3.3, 4.4)? Das entscheidet, ob Lösungswerte und strukturierte Antwortoptionen ins JSON müssen.
6. **Einheitliches Schema und Dateinamen:** Mathematik nutzt englische Feldnamen und einen `key`, Sprache und Aufsatz deutsche Feldnamen ohne `key`; die PDF-Namen sind uneinheitlich (z. B. `2021_sprachprueufng_kg.pdf` ist eine Lösung). Sollen alle Inhalte einen stabilen `key` im selben Format bekommen und die PDFs danach benannt werden?
7. **Themen zusammenführen:** Sollen ähnliche Mathematik-Kategorien (z. B. «Konstruktion» / «Geometrie: Konstruktion», «Zahlenfolgen» / «Zahlenfolgen und Muster») im JSON zusammengeführt werden, oder erst in der App?
8. **Sprach-Thema «Textverständnis»:** Die Hälfte aller Sprachaufgaben hat dieses Thema. Reicht das, oder soll es feiner aufgeteilt werden (z. B. Detailfrage, Wortbedeutung, Aussage prüfen), damit 7.1 und 7.2 aussagekräftig sind?
9. **Nutzungsrechte:** Die PDFs tragen das Logo des Kantons Zürich. Ist geklärt, dass sie in einer kommerziellen App gezeigt werden dürfen? (siehe Requirements, offene Frage 2)

## Ausserhalb des Scopes (Kind)

- Automatische Korrektur von Freitext und Aufsätzen (auch nicht durch KI)
- Handschrift erkennen oder Fotos von Papierlösungen auswerten
- Erklärvideos oder eigene Lerninhalte über die Prüfungsaufgaben hinaus
- Wettbewerbe, Ranglisten oder Vergleich mit anderen Kindern
- Aufgaben anderer Kantone als Zürich
- Französisch und weitere Fächer (in den Daten nicht vorhanden)
