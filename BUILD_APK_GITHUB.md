# Build APK su GitHub (senza tenere acceso il PC)

Compila l'app **Kairete** nei server GitHub. Tu carichi solo l'APK su FTP.

## 1. Crea un repository GitHub

1. Vai su [https://github.com/new](https://github.com/new)
2. Nome esempio: `KaireteApp`
3. **Private** (consigliato: contiene chiavi API in `app_config.dart`)
4. Crea il repo **senza** README (evita conflitti)

## 2. Carica il progetto (prima volta)

Apri **PowerShell** nella cartella del progetto:

```powershell
cd C:\Users\hp\Desktop\KaireteBlog\KaireteApp
git init
git add .
git commit -m "Kairete app + CI build APK"
git branch -M main
git remote add github https://github.com/Kairete/KaireteApp.git
git push -u github master:main
```

Repo GitHub: **https://github.com/Kairete/KaireteApp**

> Se Git chiede login: usa un [Personal Access Token](https://github.com/settings/tokens) al posto della password.

## 3. Avvia il build

**Automatico:** ogni `git push` su `main` avvia il build.

**Manuale:**

1. Su GitHub apri il repo → tab **Actions**
2. Scegli **Build APK (debug)** → **Run workflow** → **Run workflow**
3. Attendi **10–20 minuti** (prima esecuzione può essere più lenta)

## 4. Scarica l'APK

1. Apri l'esecuzione completata (segno verde)
2. In basso: **Artifacts** → **kairete-debug-apk**
3. Scarica lo zip: dentro c'è **`app-debug.apk`**

## 5. Metti su FTP e prova sul telefono

1. Carica `app-debug.apk` sul tuo FTP
2. Dal browser del telefono scarica e installa
3. Consenti **origini sconosciute** se Android lo chiede

L'app punta a **https://www.kairete.it/** (staging).

## Problemi comuni

| Problema | Cosa fare |
|----------|-----------|
| Build fallisce | Apri il job rosso in Actions e leggi l'errore nel log |
| `git` non trovato | Chiudi e riapri il terminale dopo l'installazione di Git |
| Push rifiutato | Controlla URL remote e token GitHub |

## Build locale (opzionale)

Se un giorno vuoi compilare sul PC:

```powershell
cd C:\Users\hp\Desktop\KaireteBlog\KaireteApp
flutter build apk --debug
```

Output: `build\app\outputs\flutter-apk\app-debug.apk`
