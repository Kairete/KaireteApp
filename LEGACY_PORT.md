# Kairete App v2 — migrazione da lib_legacy

Il codice precedente è in **`lib_legacy/`** (non cancellato).

## Fatto in v2 (2.0.0)

- Login → `POST api/auth`
- Registrazione → `POST api/users` (username, email, password, dob, timezone)
- Profilo → `GET api/me`, aggiornamento `POST api/users/{id}/` con `custom_fields[...]`
- Sessione → `flutter_secure_storage` (user id)
- Base URL → **kairete.it** (`lib/config/app_config.dart`)
- **OmniFeed** → `lib/features/omnifeed/` (`GET api/newsfeed`, dettaglio, commenti, reazioni, nuovo post `api/profile-posts`)

## Ordine suggerito per reimportare moduli

| # | Modulo | Cartella legacy |
|---|--------|-----------------|
| 1 | ~~Feed / newsfeed~~ | `lib/features/omnifeed/` (v2) — filtri, allegati, suggerimenti ancora in legacy |
| 2 | Forum | `lib_legacy/features/forum/` |
| 3 | Blog | `lib_legacy/features/blogs/` |
| 4 | Gruppi | `lib_legacy/features/groups/` |
| 5 | Messaggi | `lib_legacy/features/conversation/` |
| 6 | Notifiche | `lib_legacy/features/notice/` |
| 7 | Firebase push | `main.dart` legacy + `firebase_*` in pubspec |

Per ogni modulo: copiare in `lib/features/`, adattare a `XenforoApi` + `SessionStore`, aggiungere voce in `HomeShellPage`.

## Dipendenze

`pubspec.yaml` v2 è minimo. Ripristinare dipendenze da `pubspec.lock` / vecchio `pubspec` quando serve un modulo (es. `cached_network_image` per feed).

## Build

Prima di APK: allineare Gradle (vedi tentativi precedenti) o usare `flutter run` su dispositivo/emulatore.
