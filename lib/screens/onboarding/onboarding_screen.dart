import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/routes.dart';

class _OnboardData {
  final IconData icon;
  final String title;
  final String description;
  _OnboardData(this.icon, this.title, this.description);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  final _pages = [
    _OnboardData(Icons.medication_rounded, 'Manage Your Medicines',
        'Never miss a medicine again. We will remind you on time.'),
    _OnboardData(Icons.calendar_month_rounded, 'Doctor Appointments',
        'Schedule and get reminders for your doctor appointments.'),
    _OnboardData(Icons.sos_rounded, 'Emergency SOS',
        'One tap can notify your loved ones instantly.'),
  ];

  void _finish() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finish,
                  child: Text('Skip', style: TextStyle(color: AppColors.grey)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page.icon, size: 76, color: AppColors.primary),
                        ),
                        SizedBox(height: 40),
                        Text(page.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppColors.dark)),
                        SizedBox(height: 12),
                        Text(page.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: AppColors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  if (_index > 0)
                    OutlinedButton(
                      onPressed: () => _controller.previousPage(
                          duration: Duration(milliseconds: 250), curve: Curves.ease),
                      style: OutlinedButton.styleFrom(minimumSize: Size(90, 52)),
                      child: Text('Back'),
                    )
                  else
                    SizedBox(width: 90),
                  Spacer(),
                  Row(
                    children: List.generate(_pages.length, (i) {
                      final active = i == _index;
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: active ? 20 : 8,
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (isLast) {
                        _finish();
                      } else {
                        _controller.nextPage(
                            duration: Duration(milliseconds: 250), curve: Curves.ease);
                      }
                    },
                    style: ElevatedButton.styleFrom(minimumSize: Size(110, 52)),
                    child: Text(isLast ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
