import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/locale_provider.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'l10n/app_localizations.dart';

/// Root application widget.
class YeeTripApp extends ConsumerWidget {
  const YeeTripApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      title: 'YeeTrip',
      debugShowCheckedModeBanner: false,
      locale: activeLocale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: appRouter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
