import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:provider/provider.dart";

import "theme.dart";
import "provider_app.dart";
import "provider_debts.dart";
import "provider_installments.dart";
import "screen_splash.dart";

void main() {
  runApp(const SalaryManagerApp());
}

class SalaryManagerApp extends StatelessWidget {
  const SalaryManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => InstallmentsProvider()),
        ChangeNotifierProvider(create: (_) => DebtsProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, app, _) {
          return MaterialApp(
            title: "مدير الراتب الذكي",
            debugShowCheckedModeBanner: false,
            locale: const Locale("ar"),
            supportedLocales: const [Locale("ar")],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: app.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
