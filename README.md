# 🚨 Rescue - Emergency Response Flutter App

A full-featured emergency response mobile application built with Flutter, inspired by the Rescue Mobile App Figma design.

## 📱 Screens & Features

### 1. Splash Screen
- Animated logo reveal with fade + slide transition
- Auto-navigates to onboarding after 3 seconds

### 2. Onboarding (3 pages)
- SOS Alert introduction
- Real-Time Tracking overview
- Coordinated Response explanation
- Skip functionality

### 3. Dashboard (Home)
- Greeting header with commander name
- **Stats Grid**: Active Incidents, Responding, Teams Available, Resolved
- **Quick Actions**: Report Incident, Live Map, Emergency Call, History
- Recent Incidents list

### 4. Incidents Tab
- Filterable list (All / Active / Responding / Pending / Resolved)
- Rich incident cards with type emoji, location, time ago, responder count
- Status badges with color coding

### 5. Incident Detail Screen
- Full-screen gradient header (color-coded by incident type)
- Location, reporter, responder info tiles
- Incident description
- Response Timeline
- Action buttons: Dispatch Units / Mark Resolved

### 6. SOS Emergency Screen
- Dark atmospheric UI
- Animated pulsing SOS button with ripple effects
- 5-second countdown with cancel option
- Quick emergency contacts (Fire / Medical / Police)

### 7. Teams Tab
- Available/Busy status indicators
- Distance and rating display
- Bottom sheet with Call & Dispatch actions

### 8. Alerts Tab
- Severity badges (CRITICAL / HIGH / MEDIUM / LOW)
- Unread indicators
- Mark all read action

## 🎨 Design System

| Color | Usage |
|-------|-------|
| `#E53935` | Primary / Emergency Red |
| `#B71C1C` | Dark Red |
| `#1565C0` | Secondary / Trust Blue |
| `#FF6F00` | Alert Orange |
| `#2E7D32` | Success / Safe Green |

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
├── models/
│   └── models.dart              # Data models + sample data
├── widgets/
│   └── widgets.dart             # Reusable UI components
└── screens/
    ├── splash_screen.dart       # Splash + Onboarding
    ├── home_screen.dart         # Main tabs (Dashboard, Incidents, Teams, Alerts)
    ├── incident_detail_screen.dart
    └── sos_screen.dart          # SOS Emergency Screen
```

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `google_fonts` | Poppins typography |
| `flutter_svg` | SVG asset support |
| `geolocator` | GPS location access |
| `permission_handler` | Runtime permissions |
| `url_launcher` | Emergency call dialing |
| `flutter_animate` | Smooth animations |
| `shimmer` | Loading skeletons |

## 🔮 Future Enhancements

- [ ] Firebase Realtime Database integration
- [ ] Push notifications for alerts
- [ ] Live Google Maps integration
- [ ] Authentication (login/roles)
- [ ] Voice SOS trigger
- [ ] Offline mode with local caching
- [ ] Multi-language support
