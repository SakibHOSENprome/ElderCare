import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/routes.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_bottom_nav.dart';
import 'dashboard_screen.dart';
import '../medicines/medicines_screen.dart';
import '../appointments/appointments_screen.dart';
import '../profile/profile_screen.dart';
import '../caregiver/my_elders_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final _authService = AuthService();
  int _index = 0;
  UserRole? _role;
  bool _loading = true;

  final _elderScreens = [
    DashboardScreen(),
    MedicinesScreen(),
    AppointmentsScreen(),
    ProfileScreen(),
  ];

  final _caregiverScreens = [
    MyEldersScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final user = await _authService.fetchProfile();
    if (mounted) {
      setState(() {
        _role = user?.role ?? UserRole.elder;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_role == UserRole.caregiver) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(index: _index, children: _caregiverScreens),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withOpacity(0.15),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.groups_outlined, color: AppColors.grey),
              selectedIcon: Icon(Icons.groups_rounded, color: AppColors.primary),
              label: 'My Elders',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: AppColors.grey),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _index, children: _elderScreens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        onSOS: () => Navigator.of(context).pushNamed(AppRoutes.sos),
      ),
    );
  }
}
