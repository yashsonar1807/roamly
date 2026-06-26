import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'config/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RomalyApp());
}

class RomalyApp extends StatelessWidget {
  const RomalyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider is prepared here for state management
    return MultiProvider(
      providers: [
        // Placeholder for future providers
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // Standard iPhone screen size reference
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Romaly',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system, // Uses system theme (light/dark)
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}

// Simple AppStateProvider as a placeholder for provider setup
class AppStateProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
