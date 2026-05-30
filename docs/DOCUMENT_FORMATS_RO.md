# Formate documente românești — OCR ClearToDrive

ClearToDrive folosește **detectare de șablon** (template), nu un parser generic de date.
OCR-ul este doar o sugestie; utilizatorul confirmă mereu datele înainte de salvare.

## Șabloane detectate

| Șablon | Document | Expirare |
|--------|----------|----------|
| `RCA_GREEN_CARD` | Carte Verde / International Motor Insurance Card (BAAR) | Da — coloana PÂNĂ LA / TO |
| `RCA_POLICY` | Poliță RCA emisă de asigurator | Da — sfârșit valabilitate |
| `ITP_CERTIFICATE` | Certificat ITP RAR | Doar dacă data apare explicit |
| `ITP_REGISTRATION_ANNEX` | Anexă talon / certificat înmatriculare | Da — lângă cuvinte ITP |
| `CIV_RAR` | Cartea de Identitate a Vehiculului | Nu — doar VIN/plăcuță |
| `UNKNOWN` | Fallback generic | Euristică minimă |

## RCA — Carte Verde (`RCA_GREEN_CARD`)

**Semnale OCR:** `CARTE INTERNAȚIONALĂ DE ASIGURARE`, `INTERNATIONAL MOTOR INSURANCE CARD`, `CARTE VERDE`, câmp 3 `VALABILITATE / VALID`, `DE LA / FROM`, `PÂNĂ LA / TO`, `Ziua / Luna / Anul`.

**Reguli:**
1. Prioritate câmp 3 valabilitate.
2. `DE LA` = dată început; `PÂNĂ LA` = dată expirare.
3. Dacă ambele date complete → se alege TO.
4. Dacă TO e fragmentat (zi/lună + an lângă PÂNĂ LA) → reconstruire din tokeni.
5. Dacă există doar start + an TO → inferență `startDay.startMonth.toYear` cu motiv `inferred_from_green_card_to_year`.
6. Nu se alege primul date detectat ca expirare dacă e de fapt DE LA.

**Exemplu tabel:** `09 05 2026 08 05 2027` → expirare `2027-05-08`.

## RCA — Poliță (`RCA_POLICY`)

**Semnale:** `RCA`, `poliță`, `asigurare`, `valabilitate`, `perioada de valabilitate`, `de la`, `până la`, `data expirării`.

**Reguli:**
1. Interval `05.08.2026 - 05.08.2027` → `2027-08-05`.
2. Preferă datele lângă cuvinte de valabilitate.
3. Evită data emiterii, plății, nașterii, începutului.

## ITP — Certificat RAR (`ITP_CERTIFICATE`)

**Semnale:** `CERTIFICAT DE INSPECȚIE TEHNICĂ PERIODICĂ`, `ROADWORTHINESS CERTIFICATE`, `RAR`, `data următoarei inspecții tehnice periodice`.

**Reguli:**
1. Dacă apare o dată concretă lângă câmpul (8) → se extrage.
2. Dacă apare doar `conform anexei la certificatul de înmatriculare` → **fără dată inventată**; mesaj helper pentru talon.
3. Nu se deduce expirarea din alte date din certificat.

## ITP — Anexă talon (`ITP_REGISTRATION_ANNEX`)

**Semnale:** `ITP`, `inspecție tehnică periodică`, `valabil până la`, `certificat de înmatriculare`, `anexă`.

**Reguli:** preferă data cea mai apropiată de cuvinte ITP / valabilitate.

**Exemplu:** `ITP valabil până la 29.08.2026` → `2026-08-29`.

## CIV / RAR (`CIV_RAR`)

**Semnale:** `Cartea de Identitate a Vehiculului`, `CIV`, `Registrul Auto Român`, `VIN`.

**Reguli:** extrage VIN dacă e util; **nu** extrage dată expirare.

## Flux aplicație

```
Galerie → ML Kit OCR (text + blocuri) → detectare șablon → parser dedicat → ConfirmScreen
```

Tipul ales de utilizator (`RCA` / `ITP`) are prioritate față de zgomot OCR (ex. mențiune ITP pe Carte Verde).

## Build QA

Setări → Build QA → `v0.4-doc-template-parser`

Panoul **OCR diagnostics (debug)** (doar build debug) arată: șablon detectat, tip selectat, date candidate, motiv selecție.
