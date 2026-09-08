import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/app_settings.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        final settings = AppSettings.instance;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: Text('Accessibility')),
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                Text('Text Size',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 6),
                Text(
                  'Choose how large text appears throughout the app.',
                  style: TextStyle(color: AppColors.grey, fontSize: 13),
                ),
                SizedBox(height: 16),
                _sizeOption(
                  context,
                  settings,
                  option: TextSizeOption.small,
                  title: 'Small',
                  subtitle: 'Slightly smaller than the default text',
                  sampleFontSize: 14,
                ),
                _sizeOption(
                  context,
                  settings,
                  option: TextSizeOption.medium,
                  title: 'Medium',
                  subtitle: 'The default text size',
                  sampleFontSize: 18,
                ),
                _sizeOption(
                  context,
                  settings,
                  option: TextSizeOption.large,
                  title: 'Large',
                  subtitle: 'Slightly bigger than the default text',
                  sampleFontSize: 22,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sizeOption(
    BuildContext context,
    AppSettings settings, {
    required TextSizeOption option,
    required String title,
    required String subtitle,
    required double sampleFontSize,
  }) {
    final selected = settings.textSize == option;
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: selected ? AppColors.primary : AppColors.cardBorder, width: selected ? 1.5 : 1),
      ),
      child: ListTile(
        onTap: () => settings.setTextSize(option),
        leading: Text('Aa', style: TextStyle(fontSize: sampleFontSize, fontWeight: FontWeight.w600)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: AppColors.grey, fontSize: 12)),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? AppColors.primary : AppColors.grey,
        ),
      ),
    );
  }
}
