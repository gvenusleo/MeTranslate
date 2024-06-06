import "package:dynamic_color/dynamic_color.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:lex/global.dart";
import "package:lex/pages/home_page.dart";
import "package:lex/providers/theme_provider.dart";
import "package:lex/providers/window_provider.dart";
import "package:lex/theme/theme.dart";
import "package:provider/provider.dart";

Future<void> main() async {
  await init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WindowProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "lex",
        localizationsDelegates: const [
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale("en", "US"),
          Locale("zh", "CN"),
        ],
        theme: buildLightTheme(lightDynamic, context),
        darkTheme: buildDarkTheme(darkDynamic, context),
        themeMode: [
          ThemeMode.system,
          ThemeMode.light,
          ThemeMode.dark
        ][context.watch<ThemeProvider>().themeMode],
        home: const HomePage(),
      );
    });
  }
}
