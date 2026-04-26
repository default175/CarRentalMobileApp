import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/local_app_storage.dart';

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._storage)
      : super(_modeFromName(_storage.themeModeName));

  final LocalAppStorage _storage;

  void toggle() {
    setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void setMode(ThemeMode mode) {
    state = mode;
    _storage.saveThemeModeName(mode.name);
  }

  static ThemeMode _modeFromName(String name) {
    return name == ThemeMode.dark.name ? ThemeMode.dark : ThemeMode.light;
  }
}
