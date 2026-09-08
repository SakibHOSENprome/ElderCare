import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Bottom navigation bar with a notch and a prominent red SOS button
/// floating in the middle for one-tap emergency access.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onSOS;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onSOS,
  });

  static final _items = [
    _NavItem(Icons.home_rounded, 'Home'),
    _NavItem(Icons.medication_rounded, 'Medicine'),
    _NavItem(Icons.calendar_today_rounded, 'Appointment'),
    _NavItem(Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            padding: EdgeInsets.symmetric(vertical: 8),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navButton(0, _items[0]),
                  _navButton(1, _items[1]),
                  SizedBox(width: 56), // reserved space for the SOS button
                  _navButton(2, _items[2]),
                  _navButton(3, _items[3]),
                ],
              ),
            ),
          ),
          // Floating red SOS button, centered and raised above the bar
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: onSOS,
              child: Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger.withOpacity(0.4),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sos_rounded, color: AppColors.white, size: 22),
                    Text('SOS',
                        style: TextStyle(
                            color: AppColors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton(int index, _NavItem item) {
    final selected = index == currentIndex;
    final color = selected ? AppColors.primary : AppColors.grey;
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: color, size: 24),
            SizedBox(height: 2),
            Text(item.label,
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem(this.icon, this.label);
}
