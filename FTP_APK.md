# APK su kairete.it (FTP automatico)

Scheda completa: **[FTP_TRAPPOLA.md](FTP_TRAPPOLA.md)**

## URL pubblici

| App | URL |
|-----|-----|
| Hub Kairete | https://www.kairete.it/Kairete-debug.apk |
| Juve Social | https://www.kairete.it/JuveSocial-debug.apk |

Host FTP: `178.132.0.4` · cartella `/public_html/` · utente `admin@kairete.it`

## Secret GitHub

| Secret | Valore |
|--------|--------|
| `FTP_USER` | `admin@kairete.it` |
| `FTP_PASSWORD` | *(password FTP)* |

## Build + upload

- **Automatico** su push `main`/`master` (solo hub)
- **Manuale Juve Social**: Actions → Build APK → `juve_social` + `tenant_id: 3` + upload FTP
