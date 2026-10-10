import 'package:flutter/material.dart';
import 'package:{{projectName}}/core/kv_store.dart';
import 'package:{{projectName}}/localization/localization.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._(this._prefs) {
    _themeMode = _byName(
      ThemeMode.values,
      _prefs.getString('themeMode'),
      _themeMode,
    );
    _language = _prefs.getString('language') ?? L10n.system;
    L10n.code = L10n.resolve(_language);
    _checkUpdates = _prefs.getBool('checkUpdates') ?? _checkUpdates;
  }

  static AppSettings load(KvStore store) => AppSettings._(store);

  static T _byName<T extends Enum>(List<T> values, String? name, T fallback) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }

  final KvStore _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  String _language = L10n.system;
  bool _checkUpdates = true;

  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  bool get checkUpdates => _checkUpdates;

  set themeMode(ThemeMode value) =>
      _set(() => _themeMode = value, 'themeMode', value.name);

  set language(String value) {
    _language = value;
    L10n.code = L10n.resolve(value);
    _prefs.setString('language', value);
    notifyListeners();
  }

  set checkUpdates(bool value) =>
      _set(() => _checkUpdates = value, 'checkUpdates', value);

  void _set(VoidCallback change, String key, Object value) {
    change();
    switch (value) {
      case final bool v:
        _prefs.setBool(key, v);
      case final int v:
        _prefs.setInt(key, v);
      case final String v:
        _prefs.setString(key, v);
    }
    notifyListeners();
  }
}
