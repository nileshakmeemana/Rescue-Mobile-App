# 🚨 Rescue - Emergency Response Flutter App

A Flutter emergency response app with Firebase authentication, location-aware emergency services, community reporting, and donation flows.

## 📱 App Features

- Email/password sign up and login with Firestore-backed user profiles
- Location setup using GPS or manual map picker, with region-specific emergency numbers and alerts
- SOS and incident reporting with category selection, descriptions, and media uploads
- Community feed for regional posts, with post creation and detailed post views
- Push notifications and in-app notification center for alerts and updates
- Profile settings for personal details, notification preferences, SOS setup, and account actions
- Donation flow with card payment and bank transfer paths
- Firebase Storage support for profile photos and incident media
- Automatic navigation from splash, onboarding, and auth screens into the main app

## 📱 Screens

### 1. Splash Screen

- Animated logo reveal with fade + slide transition
- Auto-navigates to onboarding after 3 seconds

### 2. Onboarding (3 pages)

- SOS alert introduction
- Emergency response overview
- Community and support explanation
- Skip functionality

### 3. Authentication

- Login screen with email/password sign-in
- Registration screen that captures name, email, phone, address, and password
- Password reset support through Firebase Auth

### 4. Dashboard (Home)

- Greeting header with the current user name and region
- Quick actions for emergency reporting, SOS, emergency numbers, and location setup
- Location-aware emergency guidance based on the selected region

### 5. Emergencies / SOS Tab

- Category-based incident reporting
- Incident creation with location picker, description, and media attachments
- Incident detail view for reviewing submitted emergencies

### 6. Community Tab

- Regional feed for community posts
- Create post flow with title, description, location, and media
- Notification access from the feed

### 7. Emergency Numbers Screen

- Region-specific police, ambulance, and fire contacts
- One-tap dialing support
- Return-to-home flow after SOS use

### 8. Profile Settings

- User profile display and editing entry points
- Notification toggle and profile photo support
- SOS setup, donation access, and account management actions

### 9. Donation Flow

- Donation amount entry
- Card payment and bank transfer options
- Donation success confirmation screen

## 🎨 Design System

| Color     | Usage                   |
| --------- | ----------------------- |
| `#E53935` | Primary / Emergency Red |
| `#B71C1C` | Dark Red                |
| `#1565C0` | Secondary / Trust Blue  |
| `#FF6F00` | Alert Orange            |
| `#2E7D32` | Success / Safe Green    |

**Font**: Google Fonts - Poppins (weights: 400, 500, 600, 700, 800)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0

### Installation

```bash
cd rescue_app
flutter pub get
flutter run
```

### Build APK

```bash
flutter build apk --release
```

### Build iOS

```bash
flutter build ios --release
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── theme/
│   └── app_theme.dart           # Colors, typography, theme
├── services/
│   ├── app_state.dart           # Location, notifications, emergency numbers
│   ├── firebase_service.dart    # Firebase Auth / Firestore / Storage / FCM
│   ├── location_service.dart    # GPS and reverse geocoding helpers
│   └── user_state.dart          # Current user profile state
├── widgets/
│   └── notification_bell.dart   # Notification shortcut widget
└── screens/
    ├── splash_screen.dart       # Splash and auth routing
    ├── onboarding_screen.dart   # Intro pages
    ├── login_screen.dart        # Email/password login
    ├── register_screen.dart     # Account creation
    ├── home_screen.dart         # Main tabs
    ├── sos_tab.dart             # Emergency reporting
    ├── community_tab.dart       # Community feed
    ├── profile_tab.dart         # Settings and account actions
    ├── emergency_numbers_screen.dart
    ├── notification_screen.dart
    ├── add_incident_screen.dart
    ├── add_post_screen.dart
    └── donation_*               # Donation flow screens
```

## 📦 Dependencies

| Package              | Purpose                                |
| -------------------- | -------------------------------------- |
| `firebase_core`      | Firebase initialization                |
| `firebase_auth`      | Email/password authentication          |
| `cloud_firestore`    | Users, incidents, posts, notifications |
| `firebase_storage`   | Media and profile photo uploads        |
| `firebase_messaging` | Push notifications                     |
| `google_fonts`       | Poppins typography                     |
| `geolocator`         | GPS location access                    |
| `geocoding`          | Reverse geocoding and region lookup    |
| `permission_handler` | Runtime permissions                    |
| `image_picker`       | Photo and video uploads                |
| `url_launcher`       | Emergency call dialing                 |
| `shared_preferences` | Local notification preference storage  |
| `uuid`               | Firestore document IDs                 |

## 🔮 Future Enhancements

- [ ] Live responder tracking on maps
- [ ] Voice-triggered SOS activation
- [ ] Offline mode with local caching
- [ ] Multi-language support
- [ ] Expanded analytics for incidents and community activity
