import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.delayMs = 0});
  final Widget child;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, t, c) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.translate(offset: Offset(0, 24 * (1 - t)), child: c),
      ),
      child: child,
    );
  }
}

/// Frosted glass container – the signature surface of the auth flow.
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.62),
                Colors.white.withOpacity(0.42),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.55),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Section title with the little accent underline you already use.
class AuthHeading extends StatelessWidget {
  const AuthHeading({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h1),
        const SizedBox(height: 6),
        Container(
          height: 5,
          width: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: AppTextStyles.bodySecondary.copyWith(
            color: AppColors.textPrimary.withOpacity(0.75),
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

/// Animated pill switch between Login / Register.
class AuthTabs extends StatelessWidget {
  const AuthTabs({
    super.key,
    required this.isLoginSelected,
    required this.onLogin,
    required this.onRegister,
  });
  final bool isLoginSelected;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = (c.maxWidth - 0) / 2;
          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: isLoginSelected
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: w,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  _tab('Login', isLoginSelected, onLogin, w),
                  _tab('Register', !isLoginSelected, onRegister, w),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap, double w) {
    return SizedBox(
      width: w,
      height: 46,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: AppTextStyles.body.copyWith(
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active
                  ? AppColors.white
                  : AppColors.textPrimary.withOpacity(0.55),
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

/// Text field that lifts + highlights on focus.
class AuthField extends StatefulWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.textInputAction,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final TextInputAction? textInputAction;

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  final FocusNode _node = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _node.addListener(() => setState(() => _focused = _node.hasFocus));
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AppTextStyles.label.copyWith(
            color: _focused ? AppColors.primaryDark : AppColors.textPrimary,
          ),
          child: Text(widget.label),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_focused ? 0.95 : 0.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _focused
                  ? AppColors.primary
                  : Colors.white.withOpacity(0.8),
              width: _focused ? 1.8 : 1.2,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _node,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: widget.hint,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              prefixIcon: Icon(
                widget.icon,
                color: _focused
                    ? AppColors.primaryDark
                    : AppColors.primaryDark.withOpacity(0.6),
                size: 20,
              ),
              suffixIcon: widget.suffix,
            ),
          ),
        ),
      ],
    );
  }
}

/// Primary CTA with press-scale feedback and loading state.
class AuthButton extends StatefulWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(enabled ? 1 : 0.5),
                AppColors.primaryDark.withOpacity(enabled ? 1 : 0.5),
              ],
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.38),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : const [],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: widget.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.4,
                      ),
                    )
                  : Text(
                      widget.label,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated inline error banner.
class AuthError extends StatelessWidget {
  const AuthError({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: message.isEmpty
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 14),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.error.withOpacity(0.35)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// "Or continue with" divider.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.text = 'Or continue with'});
  final String text;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(
        height: 1,
        color: AppColors.textPrimary.withOpacity(0.15),
      ),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary.withOpacity(0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        line,
      ],
    );
  }
}

/// Outlined social button (Google / Apple).
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom "Don't have an account? Sign up" row.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.text,
    required this.actionText,
    required this.onTap,
  });
  final String text;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: AppTextStyles.bodySecondary.copyWith(
            color: AppColors.textPrimary.withOpacity(0.8),
            fontWeight: FontWeight.w700,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: AppTextStyles.body.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w800,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }
}
