import 'package:flutter/material.dart';
import 'package:my_app/core/theme/colorTheme_Type.dart';
import 'package:my_app/core/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeTokens? _tokens;
  ColorTheme _currentThemeType = ColorTheme.system;

  ThemeTokens? get root => _tokens;
  ColorTheme get currentTheme => _currentThemeType;
  ThemeMode get themeMode => _themeModes[_currentThemeType]!;

  static final Map<ColorTheme, ThemeMode> _themeModes = {
    ColorTheme.light: ThemeMode.light,
    ColorTheme.dark: ThemeMode.dark,
    ColorTheme.system: ThemeMode.system,
  };

  /// Initialize with saved theme (called in main.dart before runApp)
  Future<void> init(ColorTheme theme) async {
    _currentThemeType = theme;
    await _loadThemeFiles();
  }

  Future<void> setTheme(ColorTheme theme) async {
    _currentThemeType = theme;
    await _loadThemeFiles();
    await _saveTheme();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_currentThemeType == ColorTheme.light) {
      await setTheme(ColorTheme.dark);
    } else {
      await setTheme(ColorTheme.light);
    }
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('color_theme', _currentThemeType.name);
  }

  Future<void> _loadThemeFiles() async {
    switch (_currentThemeType) {
      case ColorTheme.light:
        _tokens = await ThemeTokens.fromAsset("assets/themes/lightTheme.json");
        break;
      case ColorTheme.dark:
        _tokens = await ThemeTokens.fromAsset("assets/themes/darkTheme.json");
        break;
      case ColorTheme.system:
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        final isDark = brightness == Brightness.dark;
        _tokens = await ThemeTokens.fromAsset(
          isDark
              ? "assets/themes/darkTheme.json"
              : "assets/themes/lightTheme.json",
        );
        break;
    }
  }
}
