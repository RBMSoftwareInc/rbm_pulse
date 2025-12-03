# RBM-Pulse

Internal, anonymous daily wellbeing check-in app using Flutter + Supabase.

## Setup

1. Install Flutter 3.24+.
2. Create a Supabase project and add tables: profiles, pulses, tips, daily_insights.
3. Copy `env.example` to `.env` and fill in Supabase + survey guardrails.
4. Run:
   - `flutter pub get`
   - `flutter run`

## Build

- Android: `flutter build apk --release`
- iOS: `flutter build ios --release`
- Web: `flutter build web --release`
