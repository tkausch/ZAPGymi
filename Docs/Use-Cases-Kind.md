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
- **Gegeben** die Startseite **Wenn** sie erscheint **Dann** zeigt «Vorschlag für heute» immer zwei Aufgaben, eine aus Mathematik und eine aus der Sprachprüfung, je mit dem Fach als Überschrift (Entscheid 01.10.2026: einfacher für das Kind als ein einzelner Vorschlag). Pro Fach: zu Beginn eine leichte Aufgabe aus einem neueren Jahrgang, danach eine ungelöste Aufgabe aus dem schwächsten Thema, sonst aus dem am wenigsten geübten Thema.
- **Gegeben** alle Aufgaben eines Fachs sind gelöst **Wenn** die Startseite erscheint **Dann** steht an dieser Stelle eine Gratulation statt eines Vorschlags.
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
- **Gegeben** eine geöffnete Aufgabe **Wenn** das Kind sie auf Papier lösen will **Dann** kann es das Original-Prüfungsheft samt Häuschenpapier drucken (siehe 3.5).

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

### 3.5 Prüfung ausdrucken
**Als** Kind, das wie an der echten Prüfung auf Papier lösen will, **möchte ich** das Original-Prüfungsheft direkt aus der geöffneten Aufgabe ausdrucken, **damit** ich mit Häuschenpapier, Lösungsfläche und Platz für Zwischenschritte arbeite und mich an das Prüfungsheft gewöhne.

*Priorität:* Should · *umgesetzt (01.10.2026)*

**Akzeptanzkriterien**
- **Gegeben** eine geöffnete Mathematik- oder Sprachaufgabe **Wenn** das Kind in der Toolbar auf das Drucker-Symbol tippt **Dann** kann es das ganze Prüfungsheft des Jahrgangs drucken, bei der Sprachprüfung zusätzlich das Textblatt.
- **Gegeben** die Lösung ist noch nicht aufgedeckt **Wenn** das Druckmenü erscheint **Dann** werden die Lösungen nicht angeboten; nach «Fertig – Lösung zeigen» sind sie druckbar.
- **Gegeben** ein geöffnetes Aufsatzthema **Wenn** das Kind druckt **Dann** stehen das Themenblatt und, falls vorhanden, die offiziellen Korrekturhinweise zur Wahl.
- **Gegeben** der Druckdialog von iOS **Wenn** er erscheint **Dann** kann das Kind Drucker, Seitenbereich, Anzahl Kopien und Papierformat wählen oder das PDF teilen.
- **Gegeben** ein Gerät ohne Druckfunktion oder ein Jahrgang ohne PDF **Wenn** die Aufgabe geöffnet ist **Dann** erscheint kein Drucker-Symbol.

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
- **Gegeben** der Tab «Fortschritt» **Wenn** das Kind die Quoten je Thema sehen will **Dann** findet es sie unter «Alle Themen im Detail» am Ende des Tabs (seit 01.10.2026; oben stehen Gesamtfortschritt, Themenlandkarte und Probeprüfungs-Verlauf, siehe 7.7–7.9).
- **Gegeben** kein Fortschritt **Wenn** die Detailseite erscheint **Dann** steht pro Fach, dass noch keine Aufgabe eingeschätzt ist.
- **Gegeben** weniger als 5 eingestufte Aufgaben in einem Thema (Annahme) **Wenn** die Seite erscheint **Dann** steht dort «noch zu wenig Daten» statt einer Quote.
- **Gegeben** eingeschätzte Aufgaben in einem Thema **Wenn** die Quote berechnet wird **Dann** gilt (richtig + 1) / (versucht + 2) (Entscheid 01.10.2026). «richtig» ist die Summe der erreichten Anteile pro Aufgabe (volle Punktzahl 1, Teilpunkte anteilig, falsch 0), «versucht» die Anzahl eingeschätzter Aufgaben, je mit dem letzten Versuch. So zählen falsche Antworten mit, und wenige Versuche ergeben keine 0 % oder 100 % (1 von 1 richtig = 67 %). Dieselbe Quote gilt für «Schwächen üben» (7.2) und «Meine Stärken» (7.6); die Auswertung einer einzelnen Simulation zeigt dagegen die tatsächlich erreichten Punkte.
- **Gegeben** genug Daten **Wenn** die Seite erscheint **Dann** sind die Themen nach Gewicht sortierbar, also nach Quote mal Häufigkeit in den Prüfungen (z. B. Termumformung erscheint 37-mal, Koordinatensystem einmal).

### 7.2 Schwächen gezielt üben
**Als** Kind **möchte ich** mit einer Aktion einen Übungssatz aus meinen schwächsten Themen bekommen, **damit** ich nicht selbst herausfinden muss, was ich als Nächstes üben soll.

*Priorität:* Should

**Akzeptanzkriterien**
- **Gegeben** erkannte Schwächen **Wenn** «Schwächen üben» gewählt wird **Dann** entsteht ein Satz von 10 Aufgaben (Annahme) aus den drei schwächsten Themen, noch ungelöste zuerst.
- **Gegeben** ein schwaches Thema mit zu wenig ungelösten Aufgaben **Wenn** der Satz gebaut wird **Dann** wird mit verwandten Kategorien aufgefüllt, und das Kind erfährt das.
- **Gegeben** noch keine erkennbaren Schwächen **Wenn** «Schwächen üben» gewählt wird **Dann** wird stattdessen eine gemischte Übung angeboten und erklärt, warum.

### 7.3 Falsche Aufgaben wiederholen
**Als** wiederkehrendes Kind **möchte ich**, dass Aufgaben, bei denen ich weniger als die volle Punktzahl hatte, gesammelt für eine Wiederholung bereitstehen, **damit** ich den Lösungsweg wirklich kann und ihn nicht nur einmal gesehen habe.

*Priorität:* Should

**Akzeptanzkriterien**
- **Gegeben** eine Aufgabe mit weniger als voller Punktzahl oder «falsch» **Wenn** das Kind sich eingeschätzt hat **Dann** steht sie sofort in «Zu wiederholen» (Entscheid 30.09.2026: sofort statt nach 3 Tagen, weil intuitiver).
- **Gegeben** eine wiederholte Aufgabe mit voller Punktzahl **Wenn** sie eingestuft ist **Dann** kommt sie erst nach längerer Frist (Annahme: 10 Tage) oder gar nicht mehr.
- **Gegeben** eine leere Wiederholungsliste **Wenn** sie geöffnet wird **Dann** sagt die App, dass nichts ansteht, und schlägt eine neue Übung vor.

### 7.4 Wochenziele wie bei der Apple Watch
**Als** Kind **möchte ich** mir Wochenziele setzen und auf der Startseite als Ringe sehen, wie weit ich bin, **damit** ich eine Routine aufbaue und stolz auf das Erreichte bin, ohne dass ein verpasster Tag alles zunichte macht.

*Priorität:* Should · *umgesetzt (01.10.2026, ersetzt «Dranbleiben ohne schlechtes Gewissen»)*

**Akzeptanzkriterien**
- **Gegeben** die Startseite **Wenn** sie erscheint **Dann** zeigt der Abschnitt «Wochenziele» ganz oben (anstelle von «Diese Woche»; der Prüfungs-Countdown folgt darunter als schmale Zeile) vier konzentrische Ringe von aussen nach innen: Mathe-Aufgaben, Deutsch-Aufgaben, Übungstage, Aufsätze. Jeder Ring füllt sich mit dem Anteil am Ziel.
- **Gegeben** die Ringe **Wenn** jemand die Farben nicht unterscheiden kann **Dann** stehen daneben bzw. darunter alle vier Ziele mit Namen und Zahl (z. B. «Mathe-Aufgaben 14/10») und ein Häkchen mit «erreicht». Die Ringe nutzen 1:1 die Apple-Watch-Farben (Mathe Rot #FA114F, Deutsch Grün #92E82A, Übungstage Cyan #1EEAEF) plus Gelb #FFD60A für Aufsätze, immer auf einer schwarzen Scheibe wie auf der Uhr (Kontrast 4.3:1 bis 15:1; benachbarte Ringe auch bei Farbenblindheit klar unterscheidbar). Auf hellem Hintergrund wären Grün und Cyan fast unsichtbar (1.5:1), darum stehen auch die Farbpunkte der Legende auf Schwarz.
- **Gegeben** «Anpassen» **Wenn** das Kind die Ziele ändert **Dann** kann es pro Woche einstellen: Mathe-Aufgaben (1–50, Standard 10), Deutsch-Aufgaben (1–30, Standard 5), Übungstage (1–7, Standard 4), Aufsätze (1–5, Standard 1) (Standardwerte: Annahme). Die Werte bleiben gespeichert.
- **Gegeben** eine eingeschätzte Aufgabe **Wenn** der Fortschritt berechnet wird **Dann** zählt jede Aufgabe pro Woche einmal, auch aus einer Simulation; ein Aufsatz zählt nach der Einschätzung mit der Checkliste; ein Übungstag ist ein Tag mit mindestens einer Einschätzung. Die Woche beginnt am Montag.
- **Gegeben** nicht alle Ziele erreicht **Wenn** die Startseite erscheint **Dann** steht ermutigend, wie viele Ziele geschafft sind und wie viele Tage die Woche noch hat, ohne Vorwurf; sind alle erreicht, gratuliert die App.

### 7.5 Aufgaben merken
**Als** wiederkehrendes Kind **möchte ich** mir Aufgaben merken, die mir besonders geholfen haben, **damit** ich sie vor der Prüfung gezielt nochmals anschauen kann, auch wenn ich sie richtig gelöst habe.

*Priorität:* Should · *umgesetzt (01.10.2026)*

**Akzeptanzkriterien**
- **Gegeben** eine geöffnete Aufgabe oder ein Aufsatzthema **Wenn** ich auf das Lesezeichen tippe **Dann** ist die Aufgabe gemerkt; ein zweiter Tipp entfernt die Markierung. In Listen geht das auch mit einem Wisch nach rechts.
- **Gegeben** gemerkte Aufgaben **Wenn** ich auf der Startseite unter «Üben» die Zeile «Gemerkte Aufgaben» (direkt unter «Zu wiederholen», mit Anzahl) antippe **Dann** öffnet sich eine eigene Liste mit allen gemerkten Aufgaben, neueste zuerst. «Zu wiederholen» zeigt nur Aufgaben, die nicht ganz richtig waren.
- **Gegeben** eine gemerkte Aufgabe wird richtig gelöst **Wenn** ich «Gemerkte Aufgaben» öffne **Dann** ist sie weiterhin dort, bis ich die Markierung entferne. Die Markierung ist unabhängig vom Ergebnis (richtig, teilweise, falsch).
- **Gegeben** der Aufgabenkatalog **Wenn** ich den Filter «Nur gemerkte» wähle **Dann** sehe ich nur gemerkte Aufgaben; ist noch nichts gemerkt, erklärt die App, wie das geht.
- **Gegeben** noch keine gemerkten Aufgaben **Wenn** ich die Liste öffne **Dann** erklärt die App, wie man sich eine Aufgabe merkt.
- **Gegeben** «Alle Daten löschen» **Wenn** die Löschung bestätigt ist **Dann** sind auch die Markierungen weg.

### 7.6 Meine Stärken
**Als** Kind **möchte ich** auf einen Blick sehen, in welchen Mathematik-Bereichen ich stark bin, **damit** ich Selbstvertrauen für die Prüfung gewinne und nicht nur meine Schwächen sehe.

*Priorität:* Should · *umgesetzt (01.10.2026)*

**Akzeptanzkriterien**
- **Gegeben** die Startseite **Wenn** ich unter «Üben» direkt unter «Schwächen üben» auf «Meine Stärken» tippe **Dann** öffnet sich eine eigene Seite mit einem Netzdiagramm.
- **Gegeben** eingeschätzte Mathematikaufgaben **Wenn** das Netzdiagramm erscheint **Dann** zeigt jede Achse einen Bereich (Kategorie) und die geschätzte Quote von 0 bis 100 % nach der Formel aus 7.1, (richtig + 1) / (versucht + 2). Es sind die 8 Bereiche mit den meisten Prüfungspunkten des eigenen Prüfungstyps (Annahme: mehr Achsen sind auf dem iPhone nicht lesbar); die Achsen bleiben fest, damit man Veränderungen sieht.
- **Gegeben** ein Bereich mit weniger als 5 eingeschätzten Aufgaben **Wenn** er im Diagramm erscheint **Dann** ist sein Punkt hohl (Wert noch unsicher); ein Bereich ohne Versuch hat keinen Punkt und heisst «noch offen», damit er nicht wie 0 % aussieht.
- **Gegeben** Bereiche mit mindestens 5 Aufgaben und mindestens 70 % (Annahme) **Wenn** die Seite erscheint **Dann** stehen die bis zu 3 besten unter «Deine Stärken»; sonst erklärt die App, was es dafür braucht.
- **Gegeben** das Diagramm **Wenn** jemand es nicht sehen kann oder Farben nicht unterscheidet **Dann** stehen alle Werte zusätzlich in der Liste «Alle Bereiche» und werden von VoiceOver vorgelesen; ein Tipp auf einen Bereich öffnet dessen Aufgaben.
- **Gegeben** noch keine Mathematikaufgabe eingeschätzt **Wenn** die Seite geöffnet wird **Dann** erklärt sie, wie die Stärken entstehen.

### 7.7 Gesamtfortschritt
**Als** Kind **möchte ich** oben im Tab «Fortschritt» auf einen Blick sehen, wie weit ich insgesamt bin, **damit** ich merke, dass sich das Üben lohnt.

*Priorität:* Should · *umgesetzt (01.10.2026)*

**Akzeptanzkriterien**
- **Gegeben** der Tab «Fortschritt» **Wenn** er erscheint **Dann** steht zuoberst ein Link auf «Meine Stärken» (7.6), darunter der Gesamtfortschritt: Anteil aller bearbeiteten Aufgaben als Zahl, je Fach (Mathematik, Sprachprüfung, Aufsatz) ein Ringdiagramm (Kuchen mit Loch) mit den Anteilen richtig, teilweise, falsch und offen, in der Mitte der Anteil bearbeiteter Aufgaben und darunter «x von y», sowie die geschätzte Trefferquote nach der Formel aus 7.1.
- **Gegeben** die Ringdiagramme **Wenn** jemand Farben nicht unterscheidet oder sie nicht sehen kann **Dann** nennt eine gemeinsame Legende jede Farbe mit Text und Anzahl, die Farben (Grün, Gelb, Rot, Grau) sind auf Farbenblindheit geprüft, und VoiceOver liest pro Fach alle Zahlen vor.
- **Gegeben** noch nichts eingeschätzt **Wenn** der Tab erscheint **Dann** zeigt er 0 % und keine Trefferquote, ohne Fehlermeldung.

### 7.8 Themenlandkarte
**Als** Kind **möchte ich** die Prüfungsbereiche als Felder sehen, eingefärbt nach meinem Stand, **damit** ich Lücken sofort erkenne und weiss, was ich als Nächstes üben soll.

*Priorität:* Should · *umgesetzt (01.10.2026)*

**Akzeptanzkriterien**
- **Gegeben** die Themenlandkarte **Wenn** sie erscheint **Dann** zeigt sie die Bereiche des eigenen Prüfungstyps als Kacheln: Zahlen und Rechnen, Algebra und Gleichungen, Textaufgaben, Geometrie, Kombinatorik und Wahrscheinlichkeit, Textverständnis, Grammatik, Wortschatz, Zeichensetzung, Aufsatz. Die Themen aus dem JSON sind diesen Bereichen fest zugeordnet; Bereiche ohne Aufgaben fehlen.
- **Gegeben** ein Bereich **Wenn** seine Stufe berechnet wird **Dann** gilt (Annahme, Entscheid 01.10.2026): Neu = noch nichts geübt; Angefangen = weniger als 5 Aufgaben; Üben nötig = ab 5 Aufgaben, aber unter 60 %; Sicher = ab 5 Aufgaben und 60 %; Gemeistert = ab 10 Aufgaben und 80 %, jeweils mit der Quote aus 7.1. (Die frühere Stufe «Wird sicherer» war irreführend, weil sie keine Entwicklung mass und auch bei vielen Fehlern erschien.)
- **Gegeben** eine Kachel **Wenn** sie erscheint **Dann** ist sie umso kräftiger in der Themenfarbe gefüllt, je höher die Stufe; «Neu» hat einen gestrichelten Rand, «Üben nötig» ist orange hinterlegt mit orangem Rand und Warnsymbol. Stufe (Text und Symbol) und «x von y gelöst» stehen immer dabei, die Farbe ist nie das einzige Merkmal.
- **Gegeben** nicht alle Bereiche gemeistert **Wenn** die Karte erscheint **Dann** steht darüber «Als Nächstes üben» mit einer kurzen Begründung und einer konkreten ungelösten Aufgabe zum direkten Start. Reihenfolge: zuerst «Üben nötig» (der schwächste Bereich), dann «Neu» (der Bereich mit den meisten Prüfungsaufgaben), dann «Angefangen», dann «Sicher».
- **Gegeben** ein Tipp auf eine Kachel **Wenn** er erfolgt **Dann** öffnet sich die Liste aller Aufgaben dieses Bereichs.

### 7.9 Probeprüfungs-Verlauf
**Als** Kind und als Elternteil **möchte ich** die Ergebnisse der Probeprüfungen über die Zeit mit einer Zielmarke sehen, **damit** ich ehrlich einschätzen kann, ob ich auf Kurs bin, denn die Simulation bildet die echte Prüfungssituation ab.

*Priorität:* Should · *umgesetzt (01.10.2026)*

**Akzeptanzkriterien**
- **Gegeben** ausgewertete Simulationen **Wenn** der Verlauf erscheint **Dann** zeigt ein Liniendiagramm das Ergebnis jeder Simulation (Anteil der Punkte, bei Prüfungen ohne Punkte Anteil richtiger Antworten) über die Zeit, eine Linie je Fach, und eine gestrichelte Zielmarke bei 70 % (Annahme). Abgebrochene Simulationen zählen nicht.
- **Gegeben** das Diagramm **Wenn** jemand Farben nicht unterscheidet oder es nicht sehen kann **Dann** unterscheiden sich die Fächer auch durch die Punktform (Kreis, Quadrat), die Legende zeigt nur vorhandene Fächer, VoiceOver liest jeden Punkt vor, und «Werte anzeigen» listet alle Ergebnisse als Text.
- **Gegeben** die letzte Probeprüfung **Wenn** der Verlauf erscheint **Dann** steht, ab wann die nächste empfohlen ist (alle zwei Wochen); ist sie fällig, führt «Zeit für die nächste Probeprüfung» zum Tab «Prüfung».
- **Gegeben** noch keine ausgewertete Simulation **Wenn** der Verlauf erscheint **Dann** erklärt er, wie er entsteht, und führt zur Prüfungssimulation.

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

## 9. Aussehen (Farbthemen)

Sechs Farbthemen, damit sich die App über Monate des Übens «wie meine» anfühlt: Neon Night, Sunset Pop, Ocean Wave (Standard), Lime Zest, Galaxy, Calm Paper. Zusätzliche Akteurin: **Elternteil** (für 9.6).

**Stand der Umsetzung (30.09.2026):** 9.1–9.5 umgesetzt, 9.6 nicht umgesetzt (Could, offene Frage).

### 9.1 Ein Thema wählen
**Als** Kind beim ersten Start **möchte ich** eines von 6 Themen wählen, **damit** sich die App wie meine anfühlt.

*Priorität:* Must · *umgesetzt*

**Akzeptanzkriterien**
- **Gegeben** der erste Start **Wenn** das Onboarding den Schritt «Wähle deinen Look» erreicht (nach dem Prüfungstyp) **Dann** sind alle 6 Themen mit einer Vorschau zu sehen, und die Seite färbt sich live mit dem gewählten Thema.
- **Gegeben** ich tippe auf «Überspringen» **Wenn** das Onboarding endet **Dann** gilt das Standardthema Ocean Wave, und ich kann es später in den Einstellungen ändern.

### 9.2 Thema später wechseln
**Als** Kind **möchte ich** das Thema in den Einstellungen wechseln, **damit** mir während Monaten des Übens nicht langweilig wird.

*Priorität:* Must · *umgesetzt*

**Akzeptanzkriterien**
- **Gegeben** ich bin in Einstellungen → Farbthema **Wenn** ich ein anderes Thema wähle **Dann** ändert sich die ganze App sofort, auch das offene Einstellungsblatt.
- **Gegeben** eine laufende Prüfungssimulation **Wenn** das Thema wechselt **Dann** gehen weder Antworten noch Timer verloren. (Die Simulation läuft im Vollbild; die Einstellungen sind dort nicht erreichbar. Der Timer rechnet ab der Startzeit und ist vom Aussehen unabhängig.)

### 9.3 Thema überall
**Als** Kind **möchte ich** mein Thema auf jedem Bildschirm sehen, auch in den Tipps und in der Themenstatistik, **damit** die App einheitlich aussieht.

*Priorität:* Must · *umgesetzt*

**Akzeptanzkriterien**
- **Gegeben** ein beliebiges Thema **Wenn** ich einen beliebigen Tab öffne **Dann** folgen Akzentfarbe, Balken, Symbole, Buttons und Hintergrund dem Thema. Ausnahme: Die Prüfungs-PDFs bleiben im Original.
- **Gegeben** die App startet neu **Wenn** sie sich öffnet **Dann** ist mein Thema noch aktiv.

### 9.4 Gut lesbar
**Als** Kind mit schwachen Augen oder Farbenblindheit **möchte ich** in jedem Thema alles lesen können, **damit** ich nicht ausgeschlossen werde.

*Priorität:* Must · *umgesetzt, mit Einschränkung*

**Akzeptanzkriterien**
- **Gegeben** ein beliebiges Thema **Wenn** Text erscheint **Dann** beträgt der Kontrast mindestens 4.5:1 (Annahme). Geprüft für alle 6 Themen, hell und dunkel: Akzentfarbe auf Zeilen und Hintergrund 5.2–9.6:1, Schrift auf gefüllten Buttons 5.8–11.9:1 (im Dunkelmodus schwarze statt weisse Schrift), normaler Text auf Hintergrund über 18:1. Die Zeilen behalten den Systemhintergrund.
- **Gegeben** eine richtige oder falsche Antwort **Wenn** sie angezeigt wird **Dann** hat sie ein Symbol oder Text (Häkchen, halber Kreis, Kreuz, «Richtig/Teilweise/Falsch»), nicht nur eine Farbe.
- *Einschränkung:* Die graue Hilfsschrift von iOS (Fussnoten, Untertitel) erreicht auf hellem Hintergrund etwa 3:1, wie in allen Standard-Apps. Die Themen verschlechtern das nicht; für 4.5:1 müsste diese Schrift überall dunkler werden (siehe offene Fragen).

### 9.5 Dunkelmodus
**Als** Kind, das am Abend lernt, **möchte ich**, dass hell oder dunkel meinem Gerät folgt, **damit** meine Augen in der Nacht nicht schmerzen.

*Priorität:* Should · *umgesetzt*

**Akzeptanzkriterien**
- **Gegeben** «Automatisch» **Wenn** iOS in den Dunkelmodus wechselt **Dann** wechselt das Thema auf seine dunkle Variante.
- **Gegeben** ich wähle fest «Hell» oder «Dunkel» **Wenn** iOS wechselt **Dann** bleibt die App so, wie ich es eingestellt habe.

### 9.6 Elternsperre
**Als** Elternteil **möchte ich** das Thema in Prüfungswochen sperren, **damit** mein Kind beim Lernen bleibt.

*Priorität:* Could · *nicht umgesetzt*

**Akzeptanzkriterien**
- **Gegeben** die Sperre ist aktiv **Wenn** mein Kind die Themenauswahl öffnet **Dann** ist sie deaktiviert und sagt, warum.
- **Gegeben** die Eltern-Sperre wird nicht bestanden **Wenn** ich es nochmals versuche **Dann** ändert sich nichts.

Hängt von der Eltern-Sperre aus den Requirements (6.1) ab, die es noch nicht gibt.

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
10. **Freischaltbare Themen:** Sollen später Themen dazukommen, die man durch regelmässiges Üben freischaltet, oder nie?
11. **Elternsperre für das Thema (9.6):** Braucht es sie in v1? Sie setzt eine Eltern-Sperre voraus, die es noch nicht gibt.
12. **Kontrast der Hilfsschrift (9.4):** Soll die graue Hilfsschrift überall dunkler werden, damit auch sie 4.5:1 erreicht? Das weicht vom iOS-Standard ab.

## Ausserhalb des Scopes (Kind)

- Automatische Korrektur von Freitext und Aufsätzen (auch nicht durch KI)
- Handschrift erkennen oder Fotos von Papierlösungen auswerten
- Erklärvideos oder eigene Lerninhalte über die Prüfungsaufgaben hinaus
- Wettbewerbe, Ranglisten oder Vergleich mit anderen Kindern
- Aufgaben anderer Kantone als Zürich
- Französisch und weitere Fächer (in den Daten nicht vorhanden)
- Eigene Farben, saisonale Themen, Töne oder Maskottchen, Themen teilen
