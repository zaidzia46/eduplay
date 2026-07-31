import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/child_profile_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ProfileCard extends StatefulWidget {
  final ChildProfileModel child;
  final int stars;
  final int streak;
  final VoidCallback onTap;

  const ProfileCard({
    super.key,
    required this.child,
    required this.stars,
    required this.streak,
    required this.onTap,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard>
    with SingleTickerProviderStateMixin {
  static const _scaleDownMs = 120;
  static const _ringMs = 900;
  static const _scaleUpMs = 120;
  static const _totalMs = _scaleDownMs + _ringMs + _scaleUpMs;

  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _ringProgress;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.96,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: _scaleDownMs.toDouble(),
      ),
      TweenSequenceItem(tween: ConstantTween(0.96), weight: _ringMs.toDouble()),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.96,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: _scaleUpMs.toDouble(),
      ),
    ]).animate(_controller);

    _ringProgress = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: _scaleDownMs.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: _ringMs.toDouble(),
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: _scaleUpMs.toDouble(),
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onTap(); // navigate now, after the sequence finishes
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_controller.isAnimating) return; // ignore double taps mid-animation
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 62;

    return GestureDetector(
      onTap: () {
        _handleTap();
        HapticFeedback.selectionClick();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: CustomPaint(
              foregroundPainter: _ringProgress.value > 0
                  ? _CardProgressRingPainter(
                      progress: _ringProgress.value,
                      color: AppColors.primary,
                      margin: EdgeInsets.only(bottom: 10),
                    )
                  : null,
              child: child,
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white, width: 2),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/profile_sec_bg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                      ),
                      child: CircleAvatar(
                        radius: avatarSize / 2,
                        backgroundColor: const Color(0xffFFD84E),
                        child: ClipOval(
                          child: widget.child.avatar != null
                              ? Image.asset(
                                  widget.child.avatar!,
                                  fit: BoxFit.cover,
                                  width: avatarSize,
                                  height: avatarSize,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    size: 45,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 45,
                                  color: AppColors.primary,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppColors.star,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.child.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.h4.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              widget.child.standard.standard,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.school,
                                size: 15,
                                color: AppColors.primaryDark,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.child.institution.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: widget.child.overallPercent / 100,
                                    minHeight: 6,
                                    backgroundColor: Colors.white,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          AppColors.primary,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.child.overallPercent}%',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.star,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.stars}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.local_fire_department,
                                color: AppColors.error,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.streak} day streak',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final double borderRadius;
  final EdgeInsets margin; // NEW

  _CardProgressRingPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 3,
    this.borderRadius = 15,
    this.margin = EdgeInsets.zero, // NEW
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2 + margin.left,
        strokeWidth / 2 + margin.top,
        size.width - strokeWidth - margin.left - margin.right,
        size.height - strokeWidth - margin.top - margin.bottom,
      ),
      Radius.circular(borderRadius),
    );

    final fullPath = Path()..addRRect(rrect);
    final metric = fullPath.computeMetrics().first;
    final drawPath = metric.extractPath(0, metric.length * progress);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(drawPath, paint);
  }

  @override
  bool shouldRepaint(covariant _CardProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.margin != margin;
  }
}
