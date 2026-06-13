# APK di test Kairete

## Dove scaricare l’APK (senza un altro PC)

### 1) GitHub — consigliato (gratis, dal browser)

Repository: **https://github.com/Kairete/KaireteApp**

Dopo ogni build riuscita:

| Dove | Cosa fare |
|------|-----------|
| **Releases** | https://github.com/Kairete/KaireteApp/releases → ultima *apk-debug-…* → scarica `Kairete-debug.apk` |
| **Actions** | tab **Actions** → run verde → in basso **Artifacts** → `kairete-debug-apk` |

Avviare una build: **Actions** → **Build APK (debug)** → **Run workflow**.

- **Hub Kairete** (default): `app_variant = hub` → `Kairete-debug.apk`
- **Juve Social**: `app_variant = juve_social`, `tenant_id = 3` → `JuveSocial-debug.apk`  
  Release: https://github.com/Kairete/KaireteApp/releases/tag/juve-social-latest

Serve un push del codice aggiornato su branch `main` (o avvio manuale del workflow).

### 2) FTP su kairete.it (automatico)

Dopo ogni build, l’APK finisce su **https://www.kairete.it/Kairete-debug.apk**

Configurate solo 2 secret su GitHub → **Settings** → **Secrets and variables** → **Actions**:

- `FTP_USER` — es. `admin@kairete.it`
- `FTP_PASSWORD` — password FTP (solo lì, non in chat)

Dettagli: [FTP_APK.md](FTP_APK.md)

## Sul telefono

1. Scaricate `Kairete-debug.apk` (da GitHub o dal link sul sito).
2. Aprite il file e consentite **Origini sconosciute** se Android lo chiede.
3. Installate. Pacchetto: `com.kairete.app`.

## Generare l’APK

### A) GitHub Actions (consigliato se il PC va in out-of-memory)

Vedi tabella sopra. Il PC con poca RAM non compila; GitHub sì.

### B) Sul PC Windows

Requisiti: Flutter in `C:\Users\hp\flutter`, JDK 17 (Adoptium), Android SDK, **Developer Mode** attivo (symlink).

```powershell
cd C:\Users\hp\Desktop\KaireteBlog\KaireteApp
# Chiudi programmi pesanti (browser con molte tab, ecc.)
.\scripts\build-apk.ps1
```

Output: `Kairete-debug.apk` nella cartella del progetto.

Se compare **Out of memory**, usa solo il metodo A.
