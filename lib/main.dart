import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:{{projectName}}/app.dart';
import 'package:{{projectName}}/core/kv_store.dart';
import 'package:{{projectName}}/platform/launcher_icon_service.dart';
import 'package:{{projectName}}/settings/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = await KvStore.open();
  final settings = AppSettings.load(store);

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
}
