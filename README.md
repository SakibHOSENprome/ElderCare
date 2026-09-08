# ElderCare — Flutter + Supabase

A smart healthcare app for elderly people: medicine reminders, doctor
appointments, emergency SOS, caregiver monitoring, and health analytics.
Built to match the ElderCare Figma design (colors, typography, and all 18
screens).

## 1. Prerequisites

- Flutter SDK 3.3+ (`flutter --version`)
- A free [Supabase](https://supabase.com) account

## 2. Create the Supabase backend

1. Create a new Supabase project.
2. Go to **SQL Editor** → **New query**, paste the contents of
   `supabase/schema.sql`, and run it. This creates all tables
   (`profiles`, `medicines`, `appointments`, `health_records`,
   `emergency_contacts`, `sos_alerts`) with row-level security so:
   - Elders can only manage their own data.
   - Caregivers can *view* the data of the elder they're linked to
     (via `profiles.linked_elder_id`).
3. Go to **Project Settings → API** and copy your **Project URL** and
   **anon public key**.
4. (Optional) In **Authentication → Providers**, disable "Confirm email"
   while testing so sign-up logs users in immediately.

## 3. Configure the Flutter app

Open `lib/core/supabase_config.dart` and either:

- hard-code your URL/key directly, **or**
- run the app with `--dart-define` (recommended):

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR-PROJECT-REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR-ANON-KEY
```

## 4. Project structure

```
lib/
  core/            theme, routes, Supabase client config
  models/          Medicine, Appointment, HealthRecord, EmergencyContact, AppUser
  services/        Supabase CRUD wrappers (auth, medicines, appointments, health, emergency, caregiver)
  widgets/         Reusable buttons, text fields, cards, bottom nav
  screens/
    splash/        1. Splash
    onboarding/     2-4. Onboarding
    auth/           5-6. Login, Register
    home/           7. Dashboard + bottom-nav shell
    medicines/      8-9. Medicines list, Add medicine
    appointments/   10. Appointments
    health/         11-12. Health records, Health analytics
    sos/            13-14. SOS, Emergency contacts
    caregiver/      15. Caregiver dashboard
    profile/        16-17. Profile, Settings
supabase/
  schema.sql        Full DB schema + RLS policies
```

## 5. Design tokens used

| Token | Value |
|---|---|
| Primary | `#2E7D6B` |
| Secondary | `#7CC9A5` |
| Accent green | `#4CAF50` |
| Danger / SOS | `#E53935` |
| Warning | `#FFB300` |
| Background | `#F7F9FB` |
| Dark text | `#1F2937` |
| Font | Poppins (via `google_fonts`) |

## 6. What's included vs. what to extend

**Included:** full auth (sign up/login with elder/caregiver role),
CRUD for medicines/appointments/health records/emergency contacts, SOS
alert logging, a caregiver dashboard reading a linked elder's data,
health analytics chart (fl_chart), and all screens wired with real
Supabase calls (no mock data).

**You'll likely want to add before production:**
- Push notifications for medicine/appointment reminders (the
  `flutter_local_notifications` package is already in `pubspec.yaml`;
  wire it up in `medicine_service.dart` when a medicine is saved).
- A Supabase Edge Function to fan out SMS/push when `sos_alerts` gets a
  new row (Twilio, FCM, etc.) — the client already inserts the alert.
- A "link caregiver to elder" flow (e.g. invite code) to set
  `profiles.linked_elder_id`.
- Real-time location sharing for the caregiver dashboard's map card.
- App icons / splash assets, and `flutter_launcher_icons` config.

## 7. Run

```bash
flutter pub get
flutter run
```
