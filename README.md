# Sequel — Flutter & Firebase Quiz Platform

A full-stack quiz and assessment mobile application built with Flutter, powered by Google Firebase (Authentication & Cloud Firestore). The application features dynamic multiple-choice question serving, single-attempt test integrity, real-time score tracking, a competitive leaderboard, and an administrative control panel.

## Features

- **Firebase Authentication**: User authentication and session management.
- **Dynamic Quiz Engine**: Real-time multiple-choice question serving from Cloud Firestore.
- **Single-Attempt Enforcement**: Prevents repeat submissions once a quiz is finalized.
- **Live Leaderboard**: Real-time score aggregation and participant ranking with podium indicators.
- **Admin Control Panel**: Interface to provision users, author new questions, and review activity logs.
- **Instant Visual Feedback**: Interactive answer cards highlighting correct/wrong selections.

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart 3)
- **Backend & Database**: [Cloud Firestore](https://firebase.google.com/docs/firestore)
- **Authentication**: [Firebase Authentication](https://firebase.google.com/docs/auth)
- **Platform**: [Firebase](https://firebase.google.com/)
- **Local Persistence**: `shared_preferences`

## Firebase Setup

This project uses Firebase Authentication and Cloud Firestore.

Firebase project-specific configuration files are intentionally excluded from this repository:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

Developers cloning the project must configure their own Firebase project before running the application.

### Prerequisites

1. Install [Flutter](https://flutter.dev).
2. Install the [Firebase CLI](https://firebase.google.com/docs/cli).
3. Install the [FlutterFire](https://firebase.google.com/docs/flutter/setup) CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
4. Log in to Firebase if necessary:
   ```bash
   firebase login
   ```

### Setup Steps

1. Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Email/Password** authentication in the Firebase Authentication console.
3. Enable **Cloud Firestore** and configure appropriate security rules.
4. From the root directory of this cloned project, run:
   ```bash
   flutterfire configure
   ```
   Select your Firebase project and platforms (Android, iOS, Web, macOS). This generates your local `lib/firebase_options.dart` and native configuration files.

## Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Ahmadali-dev375/sequel.git
   cd sequel
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   Follow the [Firebase Setup](#firebase-setup) instructions above.

4. **Run the application**:
   ```bash
   flutter run
   ```

## Security & Firebase Configuration

Firebase project-specific configuration files are intentionally excluded from this repository. Developers cloning the project should configure their own Firebase project using FlutterFire.

This application relies on Firebase Authentication and Cloud Firestore. Production deployments should use properly configured Firestore Security Rules and appropriate authorization for administrative functionality.

## Author

**Ahmad Ali**
