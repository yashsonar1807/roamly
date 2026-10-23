import 'package:flutter/material.dart';

import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/destination_detail_screen.dart';
import '../screens/upload_post_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/rank_progress_screen.dart';
import '../screens/public_profile_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/community_journeys_screen.dart';
import '../screens/travel_circles_screen.dart';
import '../screens/rank_journey_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String destinationDetail = '/destination-detail';
  static const String uploadPost = '/upload-post';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String rankProgress = '/rank-progress';
  static const String publicProfile = '/public-profile';
  static const String communityJourneys = '/community-journeys';
  static const String travelCircles = '/travel-circles';
  static const String rankJourney = '/rank-journey';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );
      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        );
      case destinationDetail:
        final rawDest = routeSettings.arguments;
        final Map<String, dynamic> destination = rawDest is Map ? Map<String, dynamic>.from(rawDest) : {};
        return MaterialPageRoute(
          builder: (_) => DestinationDetailScreen(destination: destination),
        );
      case uploadPost:
        return MaterialPageRoute(
          builder: (_) => const UploadPostScreen(),
        );
      case notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );
      case settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      case rankProgress:
        final rawRank = routeSettings.arguments;
        final args = rawRank is Map ? Map<String, dynamic>.from(rawRank) : <String, dynamic>{};
        return MaterialPageRoute(
          builder: (_) => RankProgressScreen(
            currentRank: args['currentRank']?.toString() ?? 'Explorer',
            points: (args['points'] is num) ? (args['points'] as num).toInt() : 0,
          ),
        );
      case publicProfile:
        final rawUser = routeSettings.arguments;
        final String userId = (rawUser is Map ? (rawUser['_id'] ?? rawUser['id']) : rawUser)?.toString() ?? '';
        return MaterialPageRoute(
          builder: (_) => PublicProfileScreen(userId: userId),
        );
      case communityJourneys:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: CommunityJourneysScreen(),
          ),
        );
      case travelCircles:
        return MaterialPageRoute(
          builder: (_) => const TravelCirclesScreen(),
        );
      case rankJourney:
        return MaterialPageRoute(
          builder: (_) => const RankJourneyScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}
