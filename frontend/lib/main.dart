import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/destination_provider.dart';
import 'providers/trip_provider.dart';
import 'providers/story_provider.dart';
import 'providers/post_provider.dart';
import 'providers/user_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/journey_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RoamlyApp());
}

class RoamlyApp extends StatelessWidget {
  const RoamlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DestinationProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => JourneyProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'Roamly',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                initialRoute: AppRoutes.splash,
                onGenerateRoute: AppRoutes.onGenerateRoute,
              );
            },
          );
        },
      ),
    );
  }
}
