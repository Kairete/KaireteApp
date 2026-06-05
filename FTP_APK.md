# APK sul vostro server FTP

**Non inviate password FTP in chat** (né a Cursor né ad altri). Usate i Secret di GitHub.

## 1. Configurate i secret (una volta)

Repo: https://github.com/Kairete/KaireteApp  
**Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Nome secret | Esempio | Cosa mettere |
|-------------|---------|----------------|
| `FTP_HOST` | `ftp.kairete.it` | Host FTP (senza `ftp://`) |
| `FTP_USER` | `vostro_utente` | Username FTP |
| `FTP_PASSWORD` | *(solo nel secret)* | Password FTP |
| `FTP_DIR` | `/public_html/download/app/` | Cartella che avete creato (inizia con `/`, finisce con `/`) |

## 2. Caricamento automatico

Dopo ogni build verde, l’APK viene copiato in:

`FTP_DIR` + `Kairete-debug.apk`

Esempio URL pubblico (se la cartella è web):

`https://www.kairete.it/download/app/Kairete-debug.apk`

## 3. Caricamento manuale adesso (senza secret)

1. Scaricate: https://github.com/Kairete/KaireteApp/releases/latest  
2. FileZilla → cartella che avete creato → caricate `Kairete-debug.apk`

## 4. Forzare upload FTP da GitHub

**Actions** → **Build APK (debug)** → **Run workflow**  
(spuntate upload FTP se compare l’opzione)
