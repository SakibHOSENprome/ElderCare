import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The three supported accessibility text sizes.
/// `medium` is the app's original/default type scale.
/// `large` adds +4pt to every piece of text, `small` subtracts 4pt.
enum TextSizeOption { small, medium, large }

/// App-wide, persisted user preferences: dark mode, text size and
/// notifications. This is a singleton `ChangeNotifier` — the root
/// widget (see `main.dart`) listens to it and rebuilds the whole app
/// (theme + text scaling) whenever a setting changes, and every
/// screen that reads `AppColors` picks up the new palette automatically
/// because those are computed dynamically from `AppSettings.instance`.
class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  static const _darkModeKey = 'settings_dark_mode';
  static const _textSizeKey = 'settings_text_size';
  static const _notificationsKey = 'settings_notifications';

  bool _isDark = false;
  TextSizeOption _textSize = TextSizeOption.medium;
  bool _notificationsEnabled = true;
  bool _loaded = false;

  bool get isDark => _isDark;
  TextSizeOption get textSize => _textSize;
  bool get notificationsEnabled => _notificationsEnabled;

  /// Flat point delta applied on top of every font size in the app.
  double get fontDelta {
    switch (_textSize) {
      case TextSizeOption.large:
        return 4;
      case TextSizeOption.small:
        return -4;
      case TextSizeOption.medium:
        return 0;
    }
  }

  /// Loads persisted settings. Safe to call multiple times — only the
  /// first call actually hits disk.
  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDark = prefs.getBool(_darkModeKey) ?? false;
      _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
      final storedSize = prefs.getString(_textSizeKey);
      _textSize = TextSizeOption.values.firstWhere(
        (e) => e.name == storedSize,
        orElse: () => TextSizeOption.medium,
      );
    } catch (_) {
      // Fall back to defaults if prefs aren't available for some reason.
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> setTextSize(TextSizeOption value) async {
    if (_textSize == value) return;
    _textSize = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_textSizeKey, value.name);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    if (_notificationsEnabled == value) return;
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }
}

/// A [TextScaler] that adds a flat point delta to every font size
/// instead of multiplying by a percentage. This gives the exact
/// "+4pt / -4pt from medium" behaviour the Accessibility setting
/// promises, applied globally via `MaterialApp.builder` in `main.dart`.
class DeltaTextScaler extends TextScaler {
  const DeltaTextScaler(this.delta);

  final double delta;

  @override
  double scale(double fontSize) {
    if (fontSize <= 0) return fontSize;
    final scaled = fontSize + delta;
    return scaled < 8 ? 8 : scaled;
  }

  @override
  double get textScaleFactor => 1.0;

  @override
  bool operator ==(Object other) => other is DeltaTextScaler && other.delta == delta;

  @override
  int get hashCode => delta.hashCode;
}
