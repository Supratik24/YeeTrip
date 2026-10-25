import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'l10n/app_localizations.dart';

/// Root application widget.
class YeeTripApp extends StatelessWidget {
  const YeeTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'YeeTrip',
      debugShowCheckedModeBanner: false,
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
