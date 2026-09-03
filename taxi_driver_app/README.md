# GoCab Driver App

A separate Flutter app that connects to the **same Firebase project** as your
rider app, listens for new ride requests in real time, and lets a driver
accept and manage a ride through to completion.

## How the data flow works

```
RIDER APP                         FIRESTORE                    DRIVER APP
----------                        ----------                   ----------
Book button tapped
  -> creates a doc in
     `bookings` collection
     status: "requested"    -->  bookings/{id}          -->    Orders screen listens
                                    status: requested            (watchPendingBookings)
                                                                  shows it in the list

                                                                 Driver taps "Accept"
                                                          <--    (acceptBooking — Firestore
                                  status: confirmed             transaction, so only one
                                  driverId, driverName           driver can win it)

Tracking screen listens    <--  status/driverLat/driverLng
  (watchBooking) and                updated live
  updates automatically                                        Driver taps through:
                                                                  Arrived -> Start trip
                                  status: arrived,         <--    -> Complete ride
                                  ongoing, completed
```

Both apps talk to Firestore directly — there's no server in between. The
rider app's `BookingService.watchBooking(bookingId)` and this app's writes
both point at the exact same document, so updates show up on the rider's
screen within a second or two automatically (Firestore's real-time
listeners), no polling or push notifications required for MVP.

## 1. Connect this app to your existing Firebase project
```bash
dart pub global activate flutterfire_cli   # skip if already installed
cd taxi_driver_app
flutterfire configure
```
Pick the **same Firebase project** you used for the rider app. This
regenerates `lib/firebase_options.dart` and drops `google-services.json`
into `android/app/`.

## 2. Install dependencies
```bash
flutter pub get
```

## 3. Firestore rules
Same collection as the rider app (`bookings`). If you used the test-mode
rules from the rider app setup, no changes needed. For reference:
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
Before production, restrict writes so only:
- the rider who owns a booking can create it, and
- a driver can only update `status`/`driverId`/`driverLat`/`driverLng` on
  bookings that are `requested` (to accept) or already theirs.

## 4. Run it
```bash
flutter run
```
First launch → enter a name + phone number (this is a simple local session,
not real authentication — see the note in `lib/services/driver_session.dart`
about swapping in Firebase Auth phone OTP later) → lands on the **Orders**
screen, which live-streams any booking with `status: "requested"`.

## 5. Testing the full loop
1. Run the **rider app**, book a ride → creates a `requested` booking.
2. Run this **driver app** (same Firebase project) → the order appears on
   the Orders screen within a second or two.
3. Tap the order → **Accept ride** → status flips to `confirmed`.
4. On the rider app's tracking screen, the status updates live too.
5. Walk the driver app through **Arrived → Start trip → Complete ride** —
   watch each change reflect on the rider side in real time.

## Project structure
| File | Purpose |
|---|---|
| `lib/main.dart` | App entry point, Firebase init, routes |
| `lib/theme.dart` | Colors/theme shared across screens |
| `lib/models/booking.dart` | Mirrors the rider app's booking schema, plus driver fields |
| `lib/services/booking_service.dart` | All Firestore reads/writes (pending orders, accept, status updates, live location) |
| `lib/services/driver_session.dart` | Local on-device driver "login" (swap for Firebase Auth later) |
| `lib/services/location_service.dart` | GPS permission + live position stream |
| `lib/screens/driver_login_screen.dart` | Simple name/phone entry |
| `lib/screens/orders_screen.dart` | Live list of pending ride requests |
| `lib/screens/order_detail_screen.dart` | Accept/decline a specific request |
| `lib/screens/active_ride_screen.dart` | Status progression + live location sharing during a ride |

## Next steps worth doing before production
- Replace `DriverSession` with real **Firebase Auth** (phone OTP) so driver
  identity is actually verified.
- Add push notifications (Firebase Cloud Messaging) so drivers get alerted
  even when the app is backgrounded — right now new orders only show up
  while the Orders screen is open and listening.
- Tighten Firestore security rules as noted above.
- Show driver's live location on a real map (`google_maps_flutter`) on both
  the driver's active-ride screen and the rider's tracking screen — the data
  (`driverLat`/`driverLng`) is already being written, just needs a map
  widget to render it.
