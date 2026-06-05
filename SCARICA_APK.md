# Scaricare e aggiornare Kairete-debug.apk

## Perché non vedete nuove Releases

GitHub crea una Release **solo dopo una build verde**.  
La fix splash (login invece della chiocciola infinita) è sul PC ma va **caricata con git push** prima di avere un APK nuovo.

## APK attuale (già online)

- **Releases:** https://github.com/Kairete/KaireteApp/releases  
- **Oppure** build #10 → Artifacts: https://github.com/Kairete/KaireteApp/actions/runs/26986864452  

Quell’APK **non** include ancora la fix splash completa.

## Passo 1 — Caricare il codice nuovo (sul PC, una volta)

```powershell
cd C:\Users\hp\Desktop\KaireteBlog\KaireteApp
git push github master:main
```

Se chiede login GitHub, accedete nel browser.

## Passo 2 — Aspettare la build

https://github.com/Kairete/KaireteApp/actions → ultima riga **verde ✓**

## Passo 3 — Scaricare il nuovo APK

https://github.com/Kairete/KaireteApp/releases → ultima release → **Kairete-debug.apk**

## Passo 4 — Sul telefono

1. **Disinstalla** la vecchia app Kairete  
2. Installa il nuovo `Kairete-debug.apk`  
3. All’avvio: entro ~12 s compare **Accedi**, oppure tocca **Vai al login**
