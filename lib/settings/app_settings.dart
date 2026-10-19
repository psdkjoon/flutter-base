import 'package:flutter/material.dart';
import 'package:{{projectName}}/core/kv_store.dart';
import 'package:{{projectName}}/localization/localization.dart';
import 'package:{{projectName}}/theme/catppuccin.dart';

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
    final accent = _prefs.getString('accent');
    if (accent != null && CatppuccinPalette.accents.contains(accent)) {
      _accent = accent;
    }
    _appearanceUpdatedAt = _prefs.getInt('accentUpdatedAt') ?? _appearanceUpdatedAt;
    _syncAppearance = _prefs.getBool('syncAccent') ?? _syncAppearance;
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
  String _accent = CatppuccinPalette.defaultAccent;
  int _appearanceUpdatedAt = 0;
  bool _syncAppearance = true;

  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  bool get checkUpdates => _checkUpdates;
  String get accent => _accent;

  /// When the user last changed the accent or the theme, in milliseconds since the
  /// epoch. 0 means they never did. The newest value wins when apps sync.
  int get appearanceUpdatedAt => _appearanceUpdatedAt;
  bool get syncAppearance => _syncAppearance;

  set themeMode(ThemeMode value) {
    if (value == _themeMode) return;
    _stamp();
    _set(() => _themeMode = value, 'themeMode', value.name);
  }

  set language(String value) {
    _language = value;
    L10n.code = L10n.resolve(value);
    _prefs.setString('language', value);
    notifyListeners();
  }

  set checkUpdates(bool value) =>
      _set(() => _checkUpdates = value, 'checkUpdates', value);

  set accent(String value) {
    if (value == _accent && _appearanceUpdatedAt != 0) return;
    _stamp();
    _set(() => _accent = value, 'accent', value);
  }

  set syncAppearance(bool value) =>
      _set(() => _syncAppearance = value, 'syncAccent', value);

  void _stamp() {
    _appearanceUpdatedAt = DateTime.now().millisecondsSinceEpoch;
    _prefs.setInt('accentUpdatedAt', _appearanceUpdatedAt);
  }

  /// Takes the accent and theme chosen in another app. Keeps that app's timestamp,
  /// so it is not mistaken for a new choice made here. [mode] is null when the
  /// other app is an older version that only shares its accent.
  void adoptAppearance(String accent, String? mode, int updatedAt) {
    if (!CatppuccinPalette.accents.contains(accent)) return;
    if (updatedAt <= _appearanceUpdatedAt) return;
    _accent = accent;
    if (mode != null) _themeMode = _byName(ThemeMode.values, mode, _themeMode);
    _appearanceUpdatedAt = updatedAt;
    _prefs.setString('accent', accent);
    _prefs.setString('themeMode', _themeMode.name);
    _prefs.setInt('accentUpdatedAt', updatedAt);
    notifyListeners();
  }

  /// Completes once every change so far is saved to disk.
  Future<void> flush() => _prefs.flush();

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
