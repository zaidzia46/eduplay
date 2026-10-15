import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'models/question_model.dart';
import 'models/question_opt_model.dart';
import 'quiz_controller.dart';
import 'quiz_repo.dart';

const _purple = Color(0xFF6C5CE7);
const _purpleDark = Color(0xFF4834D4);
const _orange = Color(0xFFFF7A45);

const _bgTop = Color(0xFFF3F1FE);
const _bgBottom = Color(0xFFE9E4FF);

class QuizScreen extends StatelessWidget {
  QuizScreen({super.key});

  final vm = Get.find<QuizController>();
  final _repo = QuizRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (vm.isLoading.value) {
              return const _PreparingQuizView();
            }

            if (vm.errorMessage.isNotEmpty && !vm.isFinished.value) {
              return Center(child: Text(vm.errorMessage.value));
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
                  child: child,
                ),
              ),
              child: vm.isFinished.value
                  ? _ResultsView(key: const ValueKey('results'), vm: vm)
                  : _QuestionView(
                      key: const ValueKey('question'),
                      vm: vm,
                      repo: _repo,
                    ),
            );
          }),
        ),
      ),
    );
  }
}

class _PreparingQuizView extends StatefulWidget {
  const _PreparingQuizView();

  @override
  State<_PreparingQuizView> createState() => _PreparingQuizViewState();
}

class _PreparingQuizViewState extends State<_PreparingQuizView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_purpleDark, _purple],
                ),
              ),
              child: const Icon(
                Icons.quiz_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Getting your quiz ready...',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _purpleDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text('Just a moment!', style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  final QuizController vm;
  final QuizRepository repo;
  const _QuestionView({super.key, required this.vm, required this.repo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          _QuizHeader(vm: vm),
          const SizedBox(height: 16),

          // Question card + timer + options all animate per question.
          Expanded(
            child: Obx(() {
              final question = vm.currentQuestion;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final slide =
                      Tween<Offset>(
                        begin: const Offset(0.25, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                layoutBuilder: (currentChild, previousChildren) {
                  // Fade outgoing card out behind the incoming one.
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                child: _QuestionBody(
                  key: ValueKey('q_${vm.currentIndex.value}'),
                  vm: vm,
                  repo: repo,
                  question: question,
                ),
              );
            }),
          ),

          // Feedback banner slides up from the bottom when answered.
          Obx(
            () => AnimatedSlide(
              offset: vm.hasAnswered.value ? Offset.zero : const Offset(0, 0.3),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: vm.hasAnswered.value ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: vm.hasAnswered.value
                    ? _FeedbackBanner(vm: vm, question: vm.currentQuestion)
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header with back button, animated progress bar and question counter.
class _QuizHeader extends StatelessWidget {
  final QuizController vm;
  const _QuizHeader({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = vm.currentIndex.value;
      final total = vm.questions.length;
      final progress = total == 0 ? 0.0 : (index + 1) / total;

      return Column(
        children: [
          Row(
            children: [
              _CircleIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Get.back(),
              ),
              const Spacer(),
              Text(
                'Question ${index + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _purpleDark,
                ),
              ),
              Text(
                ' / $total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 44), // balances the back button
            ],
          ),
          const SizedBox(height: 12),
          // Smooth animated quiz progress bar.
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: _purple.withOpacity(0.12),
                valueColor: const AlwaysStoppedAnimation<Color>(_purple),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: _purple.withOpacity(0.25),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: _purple, size: 20),
        ),
      ),
    );
  }
}

class _QuestionBody extends StatelessWidget {
  final QuizController vm;
  final QuizRepository repo;
  final QuestionModel question;
  const _QuestionBody({
    super.key,
    required this.vm,
    required this.repo,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question card with subtle shadow.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_purpleDark, _purple],
              ),
              boxShadow: [
                BoxShadow(
                  color: _purple.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (question.questionImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedNetworkImage(
                      imageUrl: repo.getPublicImageUrl(question.questionImage!),
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Text(
                  question.questionText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          _TimerBar(vm: vm),
          const SizedBox(height: 20),

          _buildAnswerArea(context, question),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAnswerArea(BuildContext context, QuestionModel question) {
    switch (question.questionType) {
      case QuestionType.fillBlank:
        return _FillBlankInput(vm: vm);
      case QuestionType.mcq:
      case QuestionType.trueFalse:
        return _OptionsList(
          vm: vm,
          options: question.options ?? [],
          repo: repo,
        );
    }
  }
}

class _TimerBar extends StatelessWidget {
  final QuizController vm;
  const _TimerBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final remaining = vm.remainingSeconds.value;
      final total = vm.currentQuestion.timeLimitSeconds;
      final fraction = total == 0 ? 0.0 : remaining / total;
      final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
      final seconds = (remaining % 60).toString().padLeft(2, '0');
      final isLow = fraction < 0.25;
      final color = isLow ? Colors.red : _orange;

      return Row(
        children: [
          Icon(Icons.timer_outlined, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              // TweenAnimationBuilder makes the bar glide instead of snapping
              // once per second.
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fraction.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 900),
                curve: Curves.linear,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: Colors.black.withOpacity(0.06),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Gentle pulse on the countdown when time is running out.
          AnimatedScale(
            scale: isLow && remaining % 2 == 0 ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$minutes:$seconds',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _OptionsList extends StatelessWidget {
  final QuizController vm;
  final List<QuestionOptionModel> options;
  final QuizRepository repo;
  const _OptionsList({
    required this.vm,
    required this.options,
    required this.repo,
  });

  static const _letters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: options.mapIndexed((index, option) {
          final isSelected = vm.selectedOptionId.value == option.id;
          final showCorrectness = vm.hasAnswered.value;
          final isThisCorrect = option.isCorrect;

          Color badgeColor = Colors.grey.shade300;
          Color badgeTextColor = Colors.black87;
          Color borderColor = Colors.transparent;
          Color bgColor = Colors.white;

          if (showCorrectness && isThisCorrect) {
            badgeColor = Colors.green;
            badgeTextColor = Colors.white;
            borderColor = Colors.green;
            bgColor = Colors.green.withOpacity(0.08);
          } else if (showCorrectness && isSelected && !isThisCorrect) {
            badgeColor = Colors.red;
            badgeTextColor = Colors.white;
            borderColor = Colors.red;
            bgColor = Colors.red.withOpacity(0.08);
          } else if (isSelected) {
            badgeColor = _purple;
            badgeTextColor = Colors.white;
            borderColor = _purple;
            bgColor = _purple.withOpacity(0.05);
          }

          // Staggered entrance: each option slides/fades in slightly after
          // the previous one.
          return _StaggeredFadeSlide(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionTile(
                key: ValueKey(option.id),
                enabled: !vm.hasAnswered.value,
                onTap: () {
                  HapticFeedback.selectionClick();
                  vm.selectOption(option.id);
                },
                shake: showCorrectness && isSelected && !isThisCorrect,
                borderColor: borderColor,
                bgColor: bgColor,
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          index < _letters.length
                              ? _letters[index]
                              : '${index + 1}',
                          key: ValueKey('$index-$badgeTextColor'),
                          style: TextStyle(
                            color: badgeTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: option.type == 'image'
                          ? _ImageOptionContent(option: option, repo: repo)
                          : Text(
                              option.value,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    // Check / cross icons pop in with a scale animation.
                    AnimatedScale(
                      scale: showCorrectness ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      child: showCorrectness && isThisCorrect
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : showCorrectness && isSelected && !isThisCorrect
                          ? const Icon(Icons.cancel, color: Colors.red)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

/// Option tile with press scale, animated color/border transitions and a
/// shake effect when the picked answer turns out to be wrong.
class _OptionTile extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final bool shake;
  final VoidCallback onTap;
  final Color borderColor;
  final Color bgColor;

  const _OptionTile({
    super.key,
    required this.child,
    required this.enabled,
    required this.onTap,
    required this.shake,
    required this.borderColor,
    required this.bgColor,
  });

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  bool _pressed = false;

  @override
  void didUpdateWidget(covariant _OptionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake && !oldWidget.shake) {
      HapticFeedback.mediumImpact();
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final t = _shakeController.value;
        final dx = t == 0 ? 0.0 : math.sin(t * math.pi * 6) * 8 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: GestureDetector(
        onTapDown: widget.enabled
            ? (_) => setState(() => _pressed = true)
            : null,
        onTapCancel: widget.enabled
            ? () => setState(() => _pressed = false)
            : null,
        onTapUp: widget.enabled
            ? (_) => setState(() => _pressed = false)
            : null,
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.borderColor == Colors.transparent
                    ? Colors.grey.shade200
                    : widget.borderColor,
                width: 2,
              ),
              color: widget.bgColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Simple staggered fade+slide entrance used by the options list.
class _StaggeredFadeSlide extends StatelessWidget {
  final int index;
  final Widget child;
  const _StaggeredFadeSlide({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

extension _MapIndexed<T> on List<T> {
  Iterable<R> mapIndexed<R>(R Function(int index, T item) f) sync* {
    for (var i = 0; i < length; i++) {
      yield f(i, this[i]);
    }
  }
}

class _ImageOptionContent extends StatelessWidget {
  final QuestionOptionModel option;
  final QuizRepository repo;
  const _ImageOptionContent({required this.option, required this.repo});

  @override
  Widget build(BuildContext context) {
    final url = repo.getPublicImageUrl(option.value);
    final count = option.count ?? 1;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(
        count,
        (_) => CachedNetworkImage(imageUrl: url, width: 28, height: 28),
      ),
    );
  }
}

class _FillBlankInput extends StatelessWidget {
  final QuizController vm;
  const _FillBlankInput({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: vm.fillBlankController,
            enabled: !vm.hasAnswered.value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _purple, width: 2),
              ),
              hintText: 'Type your answer',
            ),
            onSubmitted: (_) => vm.submitFillBlank(),
          ),
          const SizedBox(height: 12),
          if (!vm.hasAnswered.value)
            _GradientButton(label: 'Check Answer', onTap: vm.submitFillBlank),
        ],
      );
    });
  }
}

/// Reusable gradient button with press-scale feedback.
class _GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool busy;
  const _GradientButton({required this.label, required this.onTap, this.busy = false});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null || widget.busy;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTap: disabled ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Opacity(
          opacity: disabled ? 0.7 : 1.0,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(colors: [_purple, _purpleDark]),
              boxShadow: [
                BoxShadow(
                  color: _purple.withOpacity(0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: widget.busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  final QuizController vm;
  final QuestionModel question;
  const _FeedbackBanner({required this.vm, required this.question});

  @override
  Widget build(BuildContext context) {
    final isCorrect = vm.isCurrentAnswerCorrect.value;
    final ranOutOfTime = vm.ranOutOfTime.value;
    final color = isCorrect ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 450),
                curve: Curves.elasticOut,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCorrect
                        ? Icons.check_rounded
                        : ranOutOfTime
                        ? Icons.timer_off_outlined
                        : Icons.close_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isCorrect
                      ? 'Correct!'
                      : ranOutOfTime
                      ? "Time's up!"
                      : 'Not quite!',
                  style: TextStyle(
                    color: isCorrect
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          if (!isCorrect && question.explanation != null) ...[
            const SizedBox(height: 8),
            Text(
              question.explanation!,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
          ],
          const SizedBox(height: 12),
          Obx(() {
            final isLast = vm.currentIndex.value >= vm.questions.length - 1;
            final busy = vm.isSubmitting.value;
            return _GradientButton(
              label: isLast ? 'Finish Quiz' : 'Continue',
              busy: busy,
              onTap: busy ? null : vm.nextQuestion,
            );
          }),
        ],
      ),
    );
  }
}

class _ResultsView extends StatefulWidget {
  final QuizController vm;
  const _ResultsView({super.key, required this.vm});

  @override
  State<_ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends State<_ResultsView>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confettiController;
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Fire after the first frame — starting an animation controller
    // during initState/build itself can be flaky on some platforms.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceController.forward();
      if (widget.vm.passed) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  static _ResultTier _tier(QuizController vm) {
    final total = vm.questions.length;
    if (total == 0) return _ResultTier.average;
    final percent = (vm.correctCount.value / total) * 100;
    if (percent >= 80) return _ResultTier.good;
    if (percent >= 50) return _ResultTier.average;
    return _ResultTier.needsWork;
  }

  static String _message(_ResultTier tier) {
    switch (tier) {
      case _ResultTier.good:
        return "Amazing work! 🌟\nYou're a superstar!";
      case _ResultTier.average:
        return 'Good job! Keep practicing\nto get even better!';
      case _ResultTier.needsWork:
        return "Nice try! Let's practice\nthis one again.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final passed = vm.passed;
    // Failing always shows the encouraging "needs work" messaging (even at a
    // 50–59% score that would otherwise read as "average"); passing never shows
    // it, so the copy never contradicts the Retake button.
    final tier = passed
        ? (_tier(vm) == _ResultTier.needsWork
              ? _ResultTier.average
              : _tier(vm))
        : _ResultTier.needsWork;

    final cardAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    );
    final buttonAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Score card pops in with an elastic scale.
              ScaleTransition(
                scale: cardAnim,
                child: FadeTransition(
                  opacity: cardAnim,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_purpleDark, _purple],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _purple.withOpacity(0.4),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Correct Answer ${vm.correctCount.value}/${vm.questions.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Trophy pops with a spring.
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) =>
                              Transform.scale(scale: value, child: child),
                          child: Icon(
                            tier == _ResultTier.needsWork
                                ? Icons.emoji_emotions
                                : Icons.emoji_events,
                            size: 72,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _message(tier),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (vm.starsAwarded.value != null)
                          Text(
                            '⭐ ${vm.starsAwarded.value} stars earned!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        if (vm.errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            vm.errorMessage.value,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: buttonAnim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(buttonAnim),
                  child: passed
                      ? _ResultButton(
                          label: 'Done',
                          filled: true,
                          onPressed: () => Get.back(),
                        )
                      : Column(
                          children: [
                            _ResultButton(
                              label: 'Retake Quiz',
                              icon: Icons.refresh_rounded,
                              filled: true,
                              onPressed: () => vm.retake(),
                            ),
                            const SizedBox(height: 12),
                            _ResultButton(
                              label: 'Done',
                              filled: false,
                              onPressed: () => Get.back(),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirection: -1.5708, // straight up
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 30,
          gravity: 0.3,
        ),
      ],
    );
  }
}

enum _ResultTier { good, average, needsWork }

/// Full-width action button for the results screen. `filled` = solid orange
/// primary CTA (Done when passed / Retake when failed); otherwise a white
/// outlined secondary that reads against the purple results background.
class _ResultButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool filled;
  final VoidCallback onPressed;

  const _ResultButton({
    required this.label,
    required this.filled,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    return SizedBox(
      width: double.infinity,
      child: filled
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 6,
                shadowColor: _orange.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onPressed,
              child: child,
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.white70, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onPressed,
              child: child,
            ),
    );
  }
}
