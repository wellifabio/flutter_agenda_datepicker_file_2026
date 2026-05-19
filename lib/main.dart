import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '/ui/splash.dart';
import '/ui/style/theme.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Agenda',
      locale: Locale('pt', 'BR'),
      supportedLocales: [Locale('pt', 'BR')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.appTheme,
      home: Splash(),
    ),
  );
}
