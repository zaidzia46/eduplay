import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'models/question_model.dart';
import 'models/question_opt_model.dart';
import 'quiz_controller.dart';
import 'quiz_repo.dart';

class QuizScreen extends StatelessWidget {
  QuizScreen({super.key});

  final vm = Get.find<QuizController>();
  final _repo = QuizRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: SafeArea(
        child: Obx(() {
          if (vm.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage.isNotEmpty && !vm.isFinished.value) {
            return Center(child: Text(vm.errorMessage.value));
          }

          if (vm.isFinished.value) {
            return _ResultsView(vm: vm);
          }

          return _QuestionView(vm: vm, repo: _repo);
        }),
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  final QuizController vm;
  final QuizRepository repo;
  const _QuestionView({required this.vm, required this.repo});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final question = vm.currentQuestion;

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress
            LinearProgressIndicator(
              value: (vm.currentIndex.value + 1) / vm.questions.length,
            ),
            const SizedBox(height: 8),
            Text(
              'Question ${vm.currentIndex.value + 1} of ${vm.questions.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            if (question.questionImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: repo.getPublicImageUrl(question.questionImage!),
                  height: 160,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) => const SizedBox(
                    height: 160,
                    child: Icon(Icons.broken_image_outlined, size: 48),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            Text(
              question.questionText,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: _buildAnswerArea(context, question),
              ),
            ),

            if (vm.hasAnswered.value)
              _FeedbackBanner(vm: vm, question: question),
          ],
        ),
      );
    });
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

class _OptionsList extends StatelessWidget {
  final QuizController vm;
  final List<QuestionOptionModel> options;
  final QuizRepository repo;
  const _OptionsList({
    required this.vm,
    required this.options,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: options.map((option) {
          final isSelected = vm.selectedOptionId.value == option.id;
          final showCorrectness = vm.hasAnswered.value;
          final isThisCorrect = option.isCorrect;

          Color? borderColor;
          if (showCorrectness) {
            if (isThisCorrect) {
              borderColor = Colors.green;
            } else if (isSelected) {
              borderColor = Colors.red;
            }
          } else if (isSelected) {
            borderColor = Theme.of(context).primaryColor;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: vm.hasAnswered.value
                  ? null
                  : () => vm.selectOption(option.id),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: borderColor ?? Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: option.type == 'image'
                    ? _ImageOptionContent(option: option, repo: repo)
                    : Text(
                        option.value,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

/// Renders the option's image repeated `count` times — e.g. 5 cats — rather
/// than expecting one pre-made "5 cats" image per option.
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
        (_) => CachedNetworkImage(
          imageUrl: url,
          width: 32,
          height: 32,
          placeholder: (_, __) => const SizedBox(width: 32, height: 32),
          errorWidget: (_, __, ___) =>
              const Icon(Icons.broken_image_outlined, size: 32),
        ),
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
            style: Theme.of(context).textTheme.headlineSmall,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Type your answer',
            ),
            onSubmitted: (_) => vm.submitFillBlank(),
          ),
          const SizedBox(height: 12),
          if (!vm.hasAnswered.value)
            ElevatedButton(
              onPressed: vm.submitFillBlank,
              child: const Text('Check Answer'),
            ),
        ],
      );
    });
  }
}

class _FeedbackBanner extends StatelessWidget {
  final QuizController vm;
  final QuestionModel question;
  const _FeedbackBanner({required this.vm, required this.question});

  @override
  Widget build(BuildContext context) {
    final isCorrect = vm.isCurrentAnswerCorrect.value;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isCorrect ? 'Correct!' : 'Not quite!',
            style: TextStyle(
              color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (!isCorrect && question.explanation != null) ...[
            const SizedBox(height: 6),
            Text(question.explanation!),
          ],
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: vm.nextQuestion,
            child: Text(
              vm.currentIndex.value < vm.questions.length - 1
                  ? 'Continue'
                  : 'Finish Quiz',
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  final QuizController vm;
  const _ResultsView({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              '${vm.correctCount.value} / ${vm.questions.length} correct',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (vm.starsAwarded.value != null)
              Text(
                '⭐ ${vm.starsAwarded.value} stars earned!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            if (vm.errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                vm.errorMessage.value,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
