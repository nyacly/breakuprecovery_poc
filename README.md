# Breakup Recovery App

A Flutter application designed to help users navigate through the emotional journey of breakup recovery, offering personalized guidance, journaling features, and emotional support.

## Features

- 🧠 Big Five Personality Assessment
- 📝 Personal Journal
- 💬 AI-Powered Coach Chat
- 📚 Resource Library
- 📋 Personalized Recovery Plan
- 🔒 Secure Authentication

## Getting Started

### Prerequisites

- Flutter SDK (^3.6.0)
- Dart SDK
- iOS Development Setup
  - Xcode
  - CocoaPods
- Android Development Setup (optional)
  - Android Studio
- Firebase Account

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/nyacly/breakuprecovery_poc.git
   cd breakuprecovery_poc
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. iOS Setup:
   ```bash
   cd ios
   pod install
   cd ..
   ```

4. Configure Firebase:
   - Create a new Firebase project
   - Add iOS and Android apps in Firebase Console
   - Download and add configuration files:
     - iOS: `GoogleService-Info.plist` to `ios/Runner`
     - Android: `google-services.json` to `android/app`

5. Run the app:
   ```bash
   flutter run
   ```

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
