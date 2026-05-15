import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/theme/app_colors.dart';

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
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 24, left: 28, right: 28, bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: const [
                  Text(
                    'KITAB LIL JAMIE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      letterSpacing: 1.2,
                      color: AppColors.muted,
                    ),
                  ),
                  Text(
                    'كتاب للجميع',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'sans-serif',
                    fontWeight: FontWeight.w400,
                    fontSize: 38,
                    height: 1.1,
                    letterSpacing: -1.2,
                    color: AppColors.ink,
                  ),
                  children: [
                    TextSpan(text: 'Chaque livre,\n'),
                    TextSpan(
                      text: 'pour chacun.',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Choisissez votre porte d\'entrée vers la bibliothèque.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.ink2,
                ),
              ),
              const Spacer(),
              _ModuleCard(
                n: '01',
                title: 'Samia',
                sub: 'Lecture vocale · arabe, français, darija',
                tag: 'Mal-voyants',
                primary: true,
                onTap: () => _selectProfile(context, UserProfileType.blind, '/samia'),
              ),
              const SizedBox(height: 14),
              _ModuleCard(
                n: '02',
                title: 'SignBook',
                sub: "Livres en langue des signes marocaine",
                tag: 'Sourds & malentendants',
                primary: false,
                onTap: () => _selectProfile(context, UserProfileType.deaf, '/home-deaf'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String n;
  final String title;
  final String sub;
  final String tag;
  final bool primary;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.n,
    required this.title,
    required this.sub,
    required this.tag,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = primary ? AppColors.ink : AppColors.card;
    final textColor = primary ? AppColors.bg : AppColors.ink;
    final mutedColor = primary ? AppColors.bg.withOpacity(0.55) : AppColors.muted;
    final subColor = primary ? AppColors.bg.withOpacity(0.7) : AppColors.faint;
    final borderColor = primary ? Colors.transparent : AppColors.hair;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Text(
              n,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: mutedColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.4,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '· ${tag.toUpperCase()}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          letterSpacing: 0.8,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 13,
                      color: subColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: textColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
