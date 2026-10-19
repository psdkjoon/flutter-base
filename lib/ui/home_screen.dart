import 'package:flutter/material.dart' hide Text, Icon;
import 'package:{{projectName}}/app_info.dart';
import 'package:{{projectName}}/localization/localization.dart';
import 'package:{{projectName}}/theme/app_spacing.dart';
import 'package:{{projectName}}/ui/widgets/app_logo.dart';
import 'package:{{projectName}}/ui/widgets/page_frame.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _logoSize = 96;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PageFrame(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.md,
            children: [
              const AppLogo(size: _logoSize),
              Text(AppInfo.name, style: theme.textTheme.headlineSmall),
              Text(
                'Replace this screen with your app.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
