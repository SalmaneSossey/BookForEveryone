import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/home/screens/home_deaf_screen.dart';
import 'features/home/screens/home_explore_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/samia/screens/reading_screen.dart';
import 'features/samia/screens/samia_screen.dart';
import 'features/signbook/screens/signbook_reader_screen.dart';

class KitabLilJamieApp extends StatelessWidget {
  const KitabLilJamieApp({super.key});

  static String get _initialLocation {
    final androidRoute = PlatformDispatcher.instance.defaultRouteName;
    if (androidRoute.isNotEmpty && androidRoute != '/') {
      return androidRoute;
    }

    const buildRoute = String.fromEnvironment('INITIAL_ROUTE');
    if (buildRoute.isNotEmpty && buildRoute != '/') {
      return buildRoute;
    }

    return '/samia';
  }

  static final GoRouter _router = GoRouter(
    initialLocation: _initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/samia',
        builder: (context, state) => const SamiaScreen(),
      ),
      GoRoute(
        path: '/home-deaf',
        builder: (context, state) => const HomeDeafScreen(),
      ),
      GoRoute(
        path: '/explore',
        builder: (context, state) => const HomeExploreScreen(),
      ),
      GoRoute(
        path: '/reading/:bookId',
        builder: (context, state) => ReadingScreen(
          bookId: state.pathParameters['bookId']!,
        ),
      ),
      GoRoute(
        path: '/signbook/:bookId',
        builder: (context, state) => SignBookReaderScreen(
          bookId: state.pathParameters['bookId']!,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KitabLilJamie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
    );
  }
}
