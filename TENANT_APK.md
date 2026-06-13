# Sotto-app community (modello APK tenant)

Ogni community Multisite può avere una **APK dedicata** con lo stesso layout dell'app hub Kairete e colori/branding propri.

Juve Social è il **pilota** del modello.

## Architettura

| Componente | Ruolo |
|------------|--------|
| [`lib/config/tenant_apps.dart`](lib/config/tenant_apps.dart) | Registry di tutte le sotto-app (slug, colori, tenant id, package id) |
| [`lib/config/app_branding.dart`](lib/config/app_branding.dart) | Risolve branding da `APP_VARIANT` |
| Flavor Android `juveSocial` | Package `com.kairete.tenant.juve_social` |
| Multisite MobileApi | Bootstrap tenant, device session SSO, feed `tenant_group` |

## Aggiungere una nuova community APK

1. **Multisite ACP** — crea tenant attivo con mapping e `newsfeed_group_id`
2. **Registry** — aggiungi voce in `TenantApps.registry` in `tenant_apps.dart`
3. **Logo** — `assets/branding/<slug>/logo.png`
4. **Flavor Android** — duplica blocco `juveSocial` in `android/app/build.gradle`:
   ```gradle
   miaCommunity {
       dimension "kairete"
       applicationId "com.kairete.tenant.mia_community"
       resValue "string", "app_name", "Nome Community"
   }
   ```
5. **Icona launcher** (opzionale) — copia logo in `android/app/src/miaCommunity/res/mipmap-xxxhdpi/ic_launcher.png`
6. **Build**:
   ```bash
   flutter build apk --flavor miaCommunity ^
     --dart-define=APP_VARIANT=mia_community ^
     --dart-define=TENANT_ID=<id_acp>
   ```

## Build Juve Social (pilota)

```powershell
cd C:\Users\hp\Desktop\KaireteBlog\KaireteApp
.\_tools\build_juve_social.ps1
```

Output locale:
- `JuveSocial-debug.apk` (root progetto)
- `_release\JuveSocial-debug.apk`

Package Android: `com.kairete.tenant.juve_social` (installabile **accanto** all'hub `com.kairete.app`).

### Scaricare l'APK senza compilare sul PC

1. Push del codice su GitHub `main`
2. **Actions** → **Build APK (debug)** → **Run workflow**
3. Scegli `app_variant: juve_social`, `tenant_id: 3`
4. Al termine: **Artifacts** → `JuveSocial-debug-ms1`  
   oppure release: https://github.com/Kairete/KaireteApp/releases/tag/juve-social-latest

Dopo upload FTP (se configurato): https://www.kairete.it/JuveSocial-debug.apk

## Hub Kairete (invariato)

```powershell
flutter build apk --debug --flavor hub --dart-define=APP_VARIANT=hub
```

## Server XenForo

Dopo deploy add-on Multisite **1.9.95+** e OmniFeed aggiornato:

- Upgrade Multisite in ACP (tabella `xf_ms_mobile_device_session`)
- API key: scope `ms_tenant:read` e `ms_mobile_auth:write`
- Endpoint bootstrap: `GET /api/ms-tenants/{id}/bootstrap`
- Feed community: `GET /api/newsfeed?mode=tenant_group` + header `X-Ms-Tenant-Id`

## Colori

Solo **primary**, **accent** e **appBarBorderBottom** cambiano per tenant. Layout, card, spacing e struttura tab restano identici all'hub.
