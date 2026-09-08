import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/routes.dart';
import 'core/supabase_config.dart';
import 'core/app_settings.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/main_navigation.dart';
import 'screens/medicines/medicines_screen.dart';
import 'screens/medicines/add_medicine_screen.dart';
import 'screens/appointments/appointments_screen.dart';
import 'screens/health/health_records_screen.dart';
import 'screens/health/health_analytics_screen.dart';
import 'screens/sos/sos_screen.dart';
import 'screens/sos/emergency_contacts_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/profile/accessibility_screen.dart';
import 'screens/profile/help_support_screen.dart';
import 'screens/caregiver/find_caregiver_screen.dart';
import 'screens/caregiver/my_elders_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  await AppSettings.instance.load();
  runApp(const ElderCareApp());
}

class ElderCareApp extends StatelessWidget {
  const ElderCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds the whole app (theme + text scaling) whenever Dark Mode,
    // text size, or notifications change in Settings — AppColors reads
    // AppSettings.instance directly, so every screen repaints correctly.
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'ElderCare',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeData,
          initialRoute: AppRoutes.splash,
          builder: (context, child) {
            // Applies the app-wide accessibility text size as a flat
            // point delta (±4pt from Medium) on top of every font size.
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: DeltaTextScaler(AppSettings.instance.fontDelta),
              ),
              child: child!,
            );
          },
          routes: {
            AppRoutes.splash: (context) => const SplashScreen(),
            AppRoutes.onboarding: (context) => const OnboardingScreen(),
            AppRoutes.login: (context) => const LoginScreen(),
            AppRoutes.register: (context) => const RegisterScreen(),
            AppRoutes.main: (context) => const MainNavigation(),
            AppRoutes.medicines: (context) => const MedicinesScreen(),
            AppRoutes.addMedicine: (context) => const AddMedicineScreen(),
            AppRoutes.appointments: (context) => const AppointmentsScreen(),
            AppRoutes.healthRecords: (context) => const HealthRecordsScreen(),
            AppRoutes.healthAnalytics: (context) => const HealthAnalyticsScreen(),
            AppRoutes.sos: (context) => const SOSScreen(),
            AppRoutes.emergencyContacts: (context) => const EmergencyContactsScreen(),
            AppRoutes.profile: (context) => const ProfileScreen(),
            AppRoutes.settings: (context) => const SettingsScreen(),
            AppRoutes.accessibility: (context) => const AccessibilityScreen(),
            AppRoutes.helpSupport: (context) => const HelpSupportScreen(),
            AppRoutes.findCaregiver: (context) => const FindCaregiverScreen(),
            AppRoutes.myElders: (context) => const MyEldersScreen(),
          },
        );
      },
    );
  }
}
