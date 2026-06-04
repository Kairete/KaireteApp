# Kairete App (Flutter)

App mobile per il network **Kairete**, basata sulla codebase legacy in `Mobile App Files/kairete`.

## Ambiente API

| Ambiente | URL | Uso |
|----------|-----|-----|
| **Staging (attivo)** | `https://www.kairete.it/` | Sviluppo e test |
| **Produzione (futuro)** | `https://www.kairete.net/` | Dopo migrazione |

Modifica in `lib/config/app_config.dart`:

```dart
static const AppEnvironment environment = AppEnvironment.stagingIt;
// oppure AppEnvironment.production
```

## Avvio

1. Installa [Flutter SDK](https://docs.flutter.dev/get-started/install) e aggiungilo al `PATH`.
2. Nella cartella del progetto:

```bash
cd C:\Users\hp\Desktop\KaireteBlog\KaireteApp
flutter pub get
flutter run
```

Cartella ufficiale del progetto, accanto agli add-on XenForo in `C:\Users\hp\Desktop\KaireteBlog\`.

APK debug (locale):

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### APK in cloud (consigliato)

Vedi **[BUILD_APK_GITHUB.md](BUILD_APK_GITHUB.md)** — build automatico su GitHub Actions, scarichi l'APK e lo carichi su FTP.

## Struttura nuova (v2 UI)

- `lib/config/app_config.dart` — URL API e header app
- `lib/theme/kairete_theme.dart` — header/footer grigi, body bianco
- `lib/widgets/kairete_page_shell.dart` — layout a 3 zone
- `lib/widgets/cards/kairete_thread_card.dart` — card lista thread
- `lib/widgets/cards/kairete_comment_card.dart` — commenti L1 bianco / risposte grigie

## Prossimi passi

- [ ] MobileApi Multisite su XenForo
- [ ] Lista thread con `KaireteThreadCard` in `ForumDetailScreen`
- [ ] Picker smilies forum
- [ ] Push FCM + presenza in-app
- [ ] Switch `production` su kairete.net

## Nota sicurezza

La chiave `XF-Api-Key` in `app_config.dart` è per staging. Non committare chiavi di produzione in chiaro; usare `--dart-define` o file locali esclusi da git.
