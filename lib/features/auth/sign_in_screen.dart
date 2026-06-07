import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/enums.dart';

/// Full-screen sign-in art (logo is part of the image — no [GhLogo] overlay).
const _signInBackgroundAsset = 'assets/design/sign_in_background.png';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _signInBackgroundAsset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 5),
                  Text(
                    l10n.welcomeTo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.welcomeBrand,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SocialButton(
                    label: l10n.continueWithGoogle,
                    icon: Icons.g_mobiledata,
                    iconColor: const Color(0xFF4285F4),
                    onPressed: () => _signIn(ref, context, AuthProvider.google),
                  ),
                  const SizedBox(height: 10),
                  _SocialButton(
                    label: l10n.continueWithApple,
                    icon: Icons.apple,
                    iconColor: Colors.black,
                    onPressed: () => _signIn(ref, context, AuthProvider.apple),
                  ),
                  const SizedBox(height: 10),
                  _SocialButton(
                    label: l10n.continueWithFacebook,
                    icon: Icons.facebook,
                    iconColor: const Color(0xFF1877F2),
                    onPressed: () =>
                        _signIn(ref, context, AuthProvider.facebook),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _newFarmSetup(ref, context),
                    child: Text(
                      l10n.newFarmSetup,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signIn(
    WidgetRef ref,
    BuildContext context,
    AuthProvider provider,
  ) async {
    try {
      await ref.read(authRepositoryProvider).signInWithProvider(provider);
      refreshAllAppData(ref);
      if (context.mounted) context.go('/home');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not reach auth API (${AppConfig.authApiBaseUrl}). '
              'Check services on port 3001. $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> _newFarmSetup(WidgetRef ref, BuildContext context) async {
    try {
      await ref.read(authRepositoryProvider).signInWithProvider(AuthProvider.google);
      final store = ref.read(mockDataStoreProvider);
      store.onboardingComplete = false;
      store.forceOnboarding = true;
      refreshAllAppData(ref);
      if (context.mounted) context.go('/onboarding');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed: $e')),
        );
      }
    }
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: GhColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: GhColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
