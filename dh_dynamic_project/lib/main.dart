import 'package:flutter/material.dart';
import 'package:daggerheart_dynamic_dice/core/theme/app_theme.dart';
import 'package:daggerheart_dynamic_dice/pages/home_page.dart';
import 'package:daggerheart_dynamic_dice/providers/dice_color_provider.dart';
import 'package:daggerheart_dynamic_dice/providers/tap_provider.dart';
import 'package:daggerheart_dynamic_dice/providers/theme_provider.dart';
import 'package:daggerheart_dynamic_dice/testing_field.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.loadThemeModePreference();

  runApp(
    // torna o ThemeProvider disponível em toda a aplicação
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => StatTapProvider()),
        ChangeNotifierProvider(create: (context) => DiceColorProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<ThemeProvider>().loadThemeModePreference(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              theme: AppTheme.lightThemeMode,
              darkTheme: AppTheme.darkThemeMode,
              themeMode: themeProvider.themeModeValue,
              initialRoute: '/home',
              routes: {
                '/home': (context) => HomePage(),
                '/debug': (context) => TestingField(),
              },
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}
