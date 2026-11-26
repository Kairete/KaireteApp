# Mobile authentication integration — Kairete / XenForo 2.3

## Verified application state
- The native username/password login succeeds on the canonical `https://kairete.net/` host.
- `POST /api/ms-auth-login` returns a mobile session token; the app persists it in `DeviceSessionStore`.
- The API client now sends `X-Kairete-Mobile-Token`, `X-Kairete-Mobile-Device` and `X-Kairete-App-Id` only to Kairete HTTPS API routes.
- Protected API endpoints remain broken until XenForo authenticates the token **server-side**. Merely transporting a token is not enough.
- Legacy `XF-Api-Key` and `XF-Api-User` must NOT be restored with a superuser key inside the APK.

## Ownership
- `Kairete/Multisite`: mobile credentials, session issuing/revocation, multi-domain context, common API auth bridge only.
- Blog, Forum, OmniFeed, Social Groups, Social News, XFMG and profile: **retain their own API routes, controllers and permission checks**. No copying API endpoints into Multisite.
- Flutter: transports token, handles errors and restores session; does not decide authorization.

## Current staging gate (not ready for production)
The `1.9.276` staged `ApiSessionBridge` listener is deliberately INACTIVE.
The sample `allow_all_scopes` API key MUST NOT be enabled without checking the exact XenForo core API scope semantics. User-level permissions alone do not replace API scope review.

Read these files from the deployed XenForo build:
1. `src/XF/Api/App.php`: event ID, callback signature and by-reference parameters, visitor set order.
2. `src/XF/Entity/ApiKey.php`: synthetic user key fields, scope checks and superuser handling.
3. `src/XF/Repository/Api.php`: fallback key implementation and allowed-scopes conventions.
4. `src/XF/Api/Controller/AbstractController.php`: scope/superuser assertions.

## Security and functional acceptance tests
1. Login with a valid account; fetch `GET /api/me` under that exact account.
2. Invalid, missing, expired and revoked tokens fail with 401, including after logout.
3. Invalid device or app ID fails; a token for app A cannot impersonate app B.
4. An ordinary user cannot read restricted forums, edit others' posts, or access admin APIs.
5. A banned or disabled user's saved token cannot authenticate.
6. No API scope escalation via `api_bypass_permissions`, `XF-Api-User`, forged headers or arbitrary user IDs.
7. Confirm read and write operations: newsfeed, groups, blogs, threads/posts, media, profile, notifications, and other installed addon routes.
8. Check tenant scoping on mapped domains (including cross-tenant negative tests).
9. Verify native login, verify, logout, push registration, presence and device sessions still behave correctly.
10. Test non-mobile API requests with valid existing API keys; they must be unaffected.

## Deployment
- Back up files and database; install on staging first.
- Never activate the bridge solely because PHP syntax validation passes.
- Keep current production Multisite 1.9.275 until integration tests pass.
