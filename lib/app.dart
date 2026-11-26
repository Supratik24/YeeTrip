import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/locale_provider.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'core/theme_provider.dart';
import 'l10n/app_localizations.dart';

/// Root application widget.
class YeeTripApp extends ConsumerWidget {
  const YeeTripApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(appLocaleProvider);
    final activeThemeMode = ref.watch(appThemeModeProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp.router(
          title: 'YeeTrip',
          debugShowCheckedModeBanner: false,
          locale: activeLocale,
          themeMode: activeThemeMode,
          theme: AppTheme.lightTheme(dynamicColorScheme: lightDynamic),
          darkTheme: AppTheme.darkTheme(dynamicColorScheme: darkDynamic),
          routerConfig: appRouter,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}
