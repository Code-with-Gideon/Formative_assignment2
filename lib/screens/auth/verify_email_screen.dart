import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/alu_brand.dart';
import '../../widgets/custom_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isChecking = false;
  bool _isResending = false;

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);
    final authProvider = context.read<AuthProvider>();
    final isVerified = await authProvider.checkEmailVerified();

    if (!mounted) return;
    setState(() => _isChecking = false);

    if (!isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your email is not verified yet. Please click the link in your inbox or tap "Resend Verification Link".',
          ),
          backgroundColor: AppColors.statusInProgress,
        ),
      );
    }
  }

  Future<void> _resendVerification() async {
    setState(() => _isResending = true);
    final authProvider = context.read<AuthProvider>();

    try {
      await authProvider.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification email resent! Please check your ALU inbox (and spam folder).',
          ),
          backgroundColor: AppColors.statusResolved,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend email: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final email = authProvider.currentUser?.email ?? 'your ALU address';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ALU Logo Branding
                const AluHorizontalLogo(height: 38),
                const SizedBox(height: 32),

                // Icon Card
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const Icon(
                    CupertinoIcons.mail_solid,
                    size: 44,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Verify Your ALU Email',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Instruction Body
                Text(
                  'To protect the ALU campus community and satisfy institutional security policy, you must confirm ownership of your official ALU account before accessing incident reporting.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Email Address Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.aluRed.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.checkmark_shield_fill, size: 16, color: AppColors.aluRed),
                      const SizedBox(width: 8),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Primary Check Button
                CustomButton(
                  label: "I've Verified My Email",
                  isLoading: _isChecking,
                  icon: CupertinoIcons.checkmark_circle_fill,
                  onPressed: _checkVerification,
                ),
                const SizedBox(height: 12),

                // Resend Link Button
                OutlinedButton.icon(
                  onPressed: _isResending ? null : _resendVerification,
                  icon: _isResending
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(CupertinoIcons.arrow_clockwise, size: 16),
                  label: const Text('Resend Verification Link'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Out Option
                TextButton.icon(
                  onPressed: () => context.read<AuthProvider>().signOut(),
                  icon: const Icon(CupertinoIcons.arrow_left_square, size: 16),
                  label: const Text('Sign out or use a different account'),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
