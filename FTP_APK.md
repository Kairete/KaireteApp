# APK su kairete.it (FTP automatico)

Dopo ogni build riuscita su GitHub Actions, l’APK viene caricato in:

| | |
|---|---|
| **FTP** | `/public_html/Kairete-debug.apk` |
| **URL pubblico** | https://www.kairete.it/Kairete-debug.apk |

Host e percorso sono già nel workflow CI. Servono solo **2 secret** su GitHub.

## Secret da configurare (una volta)

Repo: https://github.com/Kairete/KaireteApp  
**Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Nome secret | Valore |
|-------------|--------|
| `FTP_USER` | `admin@kairete.it` |
| `FTP_PASSWORD` | *(password FTP — non in chat)* |

I vecchi secret `FTP_HOST` e `FTP_DIR` **non servono più** (host e cartella sono fissi nel workflow).

## Quando parte l’upload

- **Automatico** ad ogni push su `main` / `master`
- **Manuale**: Actions → Build APK (debug) → Run workflow (upload FTP spuntato)

## Caricamento manuale (fallback)

1. Scaricate da https://github.com/Kairete/KaireteApp/releases/latest  
2. Caricate `Kairete-debug.apk` in `/public_html/` via FileZilla / WinSCP
