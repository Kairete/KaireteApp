# FTP in trappola — scarica APK da kairete.it

Scheda rapida: host, percorsi, secret GitHub, avvio build.

---

## Connessione FTP

| Campo | Valore |
|-------|--------|
| **Host** | `178.132.0.4` |
| **Porta** | `21` (passive) |
| **Utente** | `admin@kairete.it` |
| **Password** | *(la tua password FTP — solo su GitHub Secrets)* |
| **Cartella** | `/public_html/` |

Client: FileZilla, WinSCP, o curl.

---

## File APK sul sito (dopo build CI)

| App | File su FTP | URL diretto sul telefono |
|-----|-------------|--------------------------|
| **Hub Kairete** | `/public_html/Kairete-debug.apk` | https://www.kairete.it/Kairete-debug.apk |
| **Juve Social** | `/public_html/JuveSocial-debug.apk` | https://www.kairete.it/JuveSocial-debug.apk |

Versione build:
- Hub → https://www.kairete.it/app-version.txt
- Juve Social → https://www.kairete.it/JuveSocial-app-version.txt

---

## Secret GitHub (una volta)

Repo: **https://github.com/Kairete/KaireteApp**  
**Settings → Secrets and variables → Actions → New repository secret**

| Secret | Valore |
|--------|--------|
| `FTP_USER` | `admin@kairete.it` |
| `FTP_PASSWORD` | *(password FTP)* |

Host e cartella sono già nel workflow — **non** servono altri secret.

---

## Build Juve Social + upload FTP automatico

1. Push del codice su `main` (include flavor Android + codice tenant)
2. **Actions → Build APK (debug) → Run workflow**
3. Imposta:
   - `app_variant` → **juve_social**
   - `tenant_id` → **3**
   - `upload_ftp` → **true**
4. Al termine (circa 5–10 min):
   - Scarica da **Artifacts**, oppure
   - Apri sul telefono: **https://www.kairete.it/JuveSocial-debug.apk**

Release GitHub Juve Social:  
https://github.com/Kairete/KaireteApp/releases/tag/juve-social-latest

---

## Upload manuale (se CI non va)

```powershell
# Esempio curl (sostituisci PASSWORD)
curl -T JuveSocial-debug.apk --ftp-pasv -u "admin@kairete.it:PASSWORD" ftp://178.132.0.4/public_html/JuveSocial-debug.apk
```

---

## Package Android (convivono sullo stesso telefono)

| App | Package |
|-----|---------|
| Hub | `com.kairete.app` |
| Juve Social | `com.kairete.tenant.juve_social` |
