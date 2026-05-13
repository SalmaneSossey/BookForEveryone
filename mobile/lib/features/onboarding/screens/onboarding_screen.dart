import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/accessible_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _selectProfile(
    BuildContext context,
    UserProfileType type,
    String route,
  ) async {
    await HiveService.saveProfile(
      UserProfile(type: type, createdAt: DateTime.now()),
    );
    if (context.mounted) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'KitabLilJamie',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 10),
              Text(
                'كتاب للجميع',
                textDirection: TextDirection.rtl,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              AccessibleButton(
                label: 'Blind mode - Samia',
                icon: Icons.record_voice_over,
                backgroundColor: AppColors.ink,
                foregroundColor: Colors.white,
                onPressed: () => _selectProfile(
                  context,
                  UserProfileType.blind,
                  '/samia',
                ),
              ),
              const SizedBox(height: 16),
              AccessibleButton(
                label: 'Deaf mode - SignBook',
                icon: Icons.sign_language,
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                onPressed: () => _selectProfile(
                  context,
                  UserProfileType.deaf,
                  '/home-deaf',
                ),
              ),
              const SizedBox(height: 16),
              AccessibleButton(
                label: 'Explore',
                icon: Icons.auto_stories,
                outlined: true,
                onPressed: () => _selectProfile(
                  context,
                  UserProfileType.explore,
                  '/explore',
                ),
              ),
              const Spacer(),
              Text(
                'Offline demo ready',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
