import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import '/ui/splash.dart';
import '/ui/style/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Certifique-se de inicializar o binding

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Trava a tela na vertical
  ]).then((_) {
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
  });
}
