import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:{{projectName}}/app.dart';
import 'package:{{projectName}}/core/diagnostics.dart';
import 'package:{{projectName}}/core/kv_store.dart';
import 'package:{{projectName}}/platform/launcher_icon_service.dart';
import 'package:{{projectName}}/platform/theme_sync_service.dart';
import 'package:{{projectName}}/settings/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Diagnostics.init();

  final store = await KvStore.open();
  final settings = AppSettings.load(store);

  // A sibling app may have changed the look while this app was closed. Take it before
  // the first frame, so the UI never opens in the old accent or theme.
  await ThemeSyncService.adoptStored(settings);

  runApp({{projectNameUpperCamelCase}}App(settings: settings));

  unawaited(_initPlatform(settings));
}

Future<void> _initPlatform(AppSettings settings) async {
  try {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  } on Object {
    debugPrint('edge-to-edge unavailable');
  }

  LauncherIconService.init(settings);
  await ThemeSyncService.init(settings);
}
