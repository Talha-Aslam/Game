import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/glass_button.dart';
import '../../../widgets/neon_text.dart';
import '../../../widgets/particle_field.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Initial load redirect if already authenticated
    if (authState.status == AuthStatus.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/home');
      });
    }

    ref.listen(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/home');
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient)),
          const ParticleField(particleCount: 30),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Logo
                      const NeonText(
                        text: 'CITY\nOF LIES',
                        fontSize: 42,
                        color: AppColors.purpleNeon,
                        glowRadius: 30,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'TRUST NO ONE',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.white30,
                          letterSpacing: 6,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Email field
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      TextField(
                        controller: _passwordController,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: GlassButton(
                          label: authState.status == AuthStatus.loading
                              ? 'SIGNING IN...'
                              : 'SIGN IN',
                          onPressed: authState.status == AuthStatus.loading
                              ? null
                              : () {
                                  ref.read(authProvider.notifier).signInWithEmail(
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                                },
                          glowColor: AppColors.purpleNeon,
                          height: 52,
                        ),
                      ),

                      // Error
                      if (authState.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          authState.errorMessage!,
                          style: const TextStyle(color: AppColors.crimsonRed, fontSize: 12),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.white10)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR', style: AppTextStyles.labelSmall),
                          ),
                          Expanded(child: Divider(color: AppColors.white10)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Social login
                      SocialLoginButton(
                        label: 'Continue with Google',
                        icon: Icons.g_mobiledata,
                        onPressed: () => ref.read(authProvider.notifier).signInWithGoogle(),
                      ),
                      // Apple Login removed as per user request (no dev account)

                      const SizedBox(height: 32),

                      // Sign up link
                      GestureDetector(
                        onTap: () => context.go('/signup'),
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: AppTextStyles.bodySmall,
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.purpleNeon,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
