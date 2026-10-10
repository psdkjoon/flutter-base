import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:{{projectName}}/app_info.dart';
import 'package:{{projectName}}/localization/localization.dart';
import 'package:{{projectName}}/settings/app_settings.dart';
import 'package:{{projectName}}/theme/app_theme.dart';
import 'package:{{projectName}}/ui/app_shell.dart';

class {{projectNameUpperCamelCase}}App extends StatelessWidget {
  const {{projectNameUpperCamelCase}}App({required this.settings, super.key});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: AppInfo.name,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          scrollBehavior: const _NoScrollbarBehavior(),
          locale: L10n.locale,
          supportedLocales: [
            for (final language in L10n.languages) Locale(language.code),
          ],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: KeyedSubtree(
            key: ValueKey(L10n.code),
            child: AppShell(settings: settings),
          ),
        );
      },
    );
  }
}

class _NoScrollbarBehavior extends MaterialScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}
