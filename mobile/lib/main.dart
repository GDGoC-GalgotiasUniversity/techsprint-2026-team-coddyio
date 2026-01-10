import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void
main() {
  runApp(
    const KisanGuideApp(),
  );
}

class KisanGuideApp
    extends
        StatelessWidget {
  const KisanGuideApp({
    super.key,
  });

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return MaterialApp(
      title: 'KisanGuide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(
            0xFF2E7D32,
          ), // Deep green for agriculture
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              16,
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
