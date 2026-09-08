import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/routes.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;
    final loggedIn = _authService.isLoggedIn;
    Navigator.of(context).pushReplacementNamed(
      loggedIn ? AppRoutes.main : AppRoutes.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(Icons.favorite_rounded, color: AppColors.white, size: 56),
            ),
            SizedBox(height: 20),
            Text('ElderCare',
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary)),
            SizedBox(height: 4),
            Text('Care With Love',
                style: TextStyle(fontSize: 14, color: AppColors.grey)),
            SizedBox(height: 48),
            SizedBox(
              width: 140,
              child: LinearProgressIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
