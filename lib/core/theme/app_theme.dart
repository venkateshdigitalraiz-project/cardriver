import 'package:flutter/material.dart';
import 'dark_theme.dart';
import 'light_theme.dart';

/// AppTheme provides unified access to both Light and Dark themes.
class AppTheme {
  AppTheme._();

  static final ThemeData dark = createDarkTheme();
  static final ThemeData light = createLightTheme();
}
