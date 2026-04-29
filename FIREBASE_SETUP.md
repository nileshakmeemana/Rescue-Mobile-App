# Firebase Setup Guide for Rescue App

## Step 1 — Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click **Add project** → Name it `rescue-app`
3. Enable Google Analytics (optional)

## Step 2 — Enable Services

### Authentication

- Console → Authentication → Get Started
- Sign-in method → **Phone** → Enable → Save

### Firestore Database

- Console → Firestore Database → Create database
- Start in **production mode** → choose region (e.g. `asia-south1`)

### Firebase Storage

- Console → Storage → Get Started
- Start in production mode → same region

### Cloud Messaging (FCM)

- Automatically enabled when you create the project

---

## Step 3 — Add Android App

1. Console → Project Settings → Add app → Android
2. Package name: `com.example.rescue_app`
3. Download `google-services.json`
4. Place it at: `android/app/google-services.json`

### android/build.gradle

```gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.4.2'
  }
}
```

### android/app/build.gradle

```gradle
apply plugin: 'com.google.gms.google-services'

android {
  compileSdkVersion 34
  defaultConfig {
    minSdkVersion 21   // Firebase requires min 21
  }
}
```

### android/app/src/main/AndroidManifest.xml

Add inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

---

## Step 4 — Add iOS App

1. Console → Project Settings → Add app → iOS
2. Bundle ID: `com.example.rescueApp`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist` (via Xcode)

### ios/Runner/Info.plist — add these keys:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Rescue needs your location to show nearby emergency services.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Rescue needs your location for SOS alerts.</string>
<key>NSCameraUsageDescription</key>
<string>Rescue needs camera access to upload incident photos.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Rescue needs gallery access to upload incident media.</string>
```

---

## Step 5 — Firestore Security Rules

In Console → Firestore → Rules, paste:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users — own profile only
    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }

    // Incidents — authenticated users can read all, write own
    match /incidents/{incidentId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
                    && request.resource.data.reportedBy == request.auth.uid;
      allow delete: if request.auth != null
                    && resource.data.reportedBy == request.auth.uid;
      allow update: if false; // immutable after creation
    }

    // Community posts — authenticated users can read all, write own
    match /community_posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
                    && request.resource.data.postedBy == request.auth.uid;
      allow delete: if request.auth != null
                    && resource.data.postedBy == request.auth.uid;
      allow update: if false;
    }

    // Notifications — own only
    match /notifications/{notifId} {
      allow read, write: if request.auth != null
                         && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
    }
  }
}
```

---

## Step 6 — Firebase Storage Rules

In Console → Storage → Rules:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_photos/{userId}.jpg {
      allow read: if request.auth != null;
      allow write: if request.auth != null
                   && request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024;
    }
    match /incident_media/{fileId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
                   && request.resource.size < 20 * 1024 * 1024;
    }
    match /post_media/{fileId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
                   && request.resource.size < 20 * 1024 * 1024;
    }
  }
}
```

---

## Step 7 — Firestore Indexes

In Console → Firestore → Indexes → Composite, add:

| Collection        | Field 1          | Field 2          | Order |
| ----------------- | ---------------- | ---------------- | ----- |
| `incidents`       | `region` Asc     | `createdAt` Desc | —     |
| `incidents`       | `reportedBy` Asc | `createdAt` Desc | —     |
| `community_posts` | `region` Asc     | `createdAt` Desc | —     |
| `community_posts` | `postedBy` Asc   | `createdAt` Desc | —     |
| `notifications`   | `userId` Asc     | `createdAt` Desc | —     |

---

## Step 8 — FlutterFire CLI (recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# In your project root:
flutterfire configure --project=rescue-app
```

This auto-generates `lib/firebase_options.dart` and updates
`main.dart` with:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

---

## Firestore Data Structure

```
/users/{uid}
  name, email, address, phone, region,
  policeStation, hospital, photoURL

/incidents/{id}
  type, description, location, region,
  mediaUrls[], reportedBy, hasPin, createdAt

/community_posts/{id}
  rawTitle, title, subtitle, fullDesc,
  location, region, mediaUrls[], color,
  postedBy, userAdded, createdAt

/notifications/{id}
  userId, title, message, region,
  isRead, createdAt
```

---

## Step 9 — Google Maps (required for Map Picker)

1. Enable the APIs in Google Cloud Console:

- Go to https://console.cloud.google.com/apis/library
- Enable **Maps SDK for Android** and **Maps SDK for iOS** for your project.
- Ensure billing is enabled for the project (required by Maps APIs).

2. Create an API key:

- Console → APIs & Services → Credentials → Create Credentials → API key
- Restrict the key by Android package name (and SHA-1) and/or iOS bundle ID.

3. Add the API key to Android

- Add this inside the `<application>` element in `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
   android:name="com.google.android.geo.API_KEY"
   android:value="YOUR_API_KEY_HERE" />
```

- Use the package name and (recommended) the SHA-1 fingerprint to restrict the key.
- Use a Google Play / Google APIs system image for Android emulators to test Maps.

4. Add the API key to iOS

- In `ios/Runner/AppDelegate.swift` (Swift) add near `didFinishLaunchingWithOptions`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
   _ application: UIApplication,
   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
   GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
   GeneratedPluginRegistrant.register(with: self)
   return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

- If your project uses Objective-C, call `[GMSServices provideAPIKey:@"YOUR_API_KEY_HERE"];` in `AppDelegate.m`.

5. Flutter plugin & permissions

- Ensure `pubspec.yaml` includes `google_maps_flutter` (already added).
- Run:

```bash
flutter pub get
flutter clean
flutter run
```

- Android: ensure `android/app/src/main/AndroidManifest.xml` contains these permissions (already documented above):
  - `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `INTERNET` etc.
- iOS: ensure `Info.plist` includes `NSLocationWhenInUseUsageDescription` and any camera/photo usage keys.

6. Testing notes

- Android emulators must use Google Play / Google APIs images to show maps.
- On real devices, ensure Google Play Services is up to date.
- For iOS, CocoaPods must be installed and `pod install` runs automatically during `flutter run`.

7. Security & best practices

- Restrict API keys by package name (Android) and bundle ID (iOS).
- Do not embed unrestricted keys in public repositories; use different keys per environment and consider runtime provisioning or CI secret management for production builds.

If you want, I can add the example AppDelegate change for Objective-C projects, and a short checklist into `README.md`.
