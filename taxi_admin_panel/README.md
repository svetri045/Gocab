# GoCab Admin Panel

A live dashboard + bookings manager for the same Firebase project your rider
and driver apps use. Runs great as a **web app** (open in any browser) and
also builds fine for Android if you want it as an app too.

## What it does
- **Dashboard** — live counts: total bookings, waiting for driver, active
  rides, completed, cancelled, revenue from completed rides, unique
  riders/drivers seen. All computed live from the `bookings` collection.
- **Bookings** — every booking ever made, searchable and filterable by
  status. Tap any row to see full details and **manually change its status**
  (e.g. force-cancel a stuck ride, or nudge one to "completed").

No extra Firestore composite indexes needed — it deliberately fetches all
bookings ordered by `createdAt` (a single-field query) and does filtering on
the client, so you won't hit the `failed-precondition` index error you saw
with the rider/driver apps.

## 1. Install dependencies
```bash
flutter pub get
```

## 2. Connect to your Firebase project (SAME one as rider + driver apps)
```bash
dart pub global activate flutterfire_cli   # if not already installed
flutterfire configure
```
Pick the exact same project (`fir-project-8f50b` in your case). **When it
asks which platforms to support, make sure "web" is checked** — that's what
lets you run this in a browser. You can also check Android if you want a
mobile admin app.

## 3. Run it in a browser (recommended)
```bash
flutter run -d chrome
```
That's it — opens straight in Chrome, live-connected to your real data.

To build a deployable static site:
```bash
flutter build web
```
The output lands in `build/web/` — you can host that folder anywhere
(Firebase Hosting, Netlify, a plain web server, etc.). Firebase Hosting is
the easiest since you already have the project:
```bash
firebase init hosting   # point it at build/web
firebase deploy
```

## 4. Or run it as an Android app
```bash
flutter run
```
Same Gradle setup as the rider/driver apps — if you hit the same
`google-services` plugin error as before, check `android/settings.gradle.kts`
has the `com.google.gms.google-services` line like the other two projects.

## 5. Login
Default credentials (hardcoded for now — see the note below):
```
Username: admin
Password: admin123
```
Change these in `lib/services/admin_session.dart`. This is a simple local
check, not real authentication — fine for a small trusted team, but swap in
Firebase Auth + an `admins` collection before giving wider access.

## 6. Firestore rules
Uses the same `bookings` collection — your existing test-mode rules already
cover it:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /bookings/{bookingId} {
      allow read, write: if true; // tighten with auth before going live
    }
  }
}
```

## Files
| File | Purpose |
|---|---|
| `lib/main.dart` | Entry point, Firebase init, routes |
| `lib/models/booking.dart` | Full booking schema |
| `lib/services/admin_booking_service.dart` | All Firestore reads/writes — index-free by design |
| `lib/services/admin_session.dart` | Hardcoded local login |
| `lib/screens/admin_login_screen.dart` | Login form |
| `lib/screens/dashboard_screen.dart` | Live stat cards + recent bookings |
| `lib/screens/bookings_screen.dart` | Full searchable/filterable list + detail dialog with manual status control |
| `lib/widgets/admin_nav_bar.dart` | Dashboard/Bookings nav strip |

## Next steps worth doing
- Swap hardcoded login for Firebase Auth (email/password) + an `admins`
  Firestore collection so you can add/remove admin users without a code change.
- Add a **Drivers** and **Riders** management screen — right now driver/rider
  info only exists embedded inside bookings. Creating separate `drivers` and
  `riders` collections (populated at signup) would let you manage them
  directly (block a driver, verify documents, etc.).
- Add charts (the `fl_chart` package is already in `pubspec.yaml`) for
  bookings-over-time or revenue-over-time trends.
- Tighten Firestore rules so only authenticated admins can write.
