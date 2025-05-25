import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  ThemeMode _themeModeValue = ThemeMode.system;
  String _themeModeLabel = 'system';
  String themeButtonTooltip = 'Modo claro';
  int modeIndex = 0;

  ThemeProvider() {
    // Registrando ThemeProvider como binding observer, permitindo detectar mudanças no sistema
    WidgetsBinding.instance.addObserver(this);
    loadThemeModePreference();
  }

  // Getters
  ThemeMode get themeModeValue => _themeModeValue;
  String get themeModeLabel => _themeModeLabel;
  bool get isDarkModeOn {
    if (_themeModeValue == ThemeMode.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    } else {
      return _themeModeValue == ThemeMode.dark;
    }
  }

  Future<void> saveThemeModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int indexToSave = 0;

    if (_themeModeValue == ThemeMode.light) {
      indexToSave = 1;
    } else if (_themeModeValue == ThemeMode.dark) {
      indexToSave = 2;
    }

    await prefs.setInt('themeModeIndex', indexToSave);
    await prefs.setString('themeModeLabel', _themeModeLabel);
    await prefs.setString('themeButtonTooltip', themeButtonTooltip);
  }

  Future<void> loadThemeModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    modeIndex = prefs.getInt('themeModeIndex') ?? 0;

    if (modeIndex == 0) {
      _themeModeValue = ThemeMode.system;
      _themeModeLabel = 'system';
      themeButtonTooltip = 'Modo claro';
    } else if (modeIndex == 1) {
      _themeModeValue = ThemeMode.light;
      _themeModeLabel = 'light';
      themeButtonTooltip = 'Modo escuro';
    } else {
      _themeModeValue = ThemeMode.dark;
      _themeModeLabel = 'dark';
      themeButtonTooltip = 'Padrão do sistema';
    }

    notifyListeners();
  }

  void changeThemeMode() {
    modeIndex = (modeIndex + 1) % 3;

    if (modeIndex == 0) {
      _themeModeValue = ThemeMode.system;
      _themeModeLabel = 'system';
      themeButtonTooltip = 'Padrão do sistema';
    } else if (modeIndex == 1) {
      _themeModeValue = ThemeMode.light;
      _themeModeLabel = 'light';
      themeButtonTooltip = 'Modo claro';
    } else {
      _themeModeValue = ThemeMode.dark;
      _themeModeLabel = 'dark';
      themeButtonTooltip = 'Modo escuro';
    }

    saveThemeModePreference();
    notifyListeners();
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeModeValue == ThemeMode.system) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}