import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/lessons_cubit.dart';
import '../l10n/l10n.dart';
import '../services/lessons.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// A list of lessons, each opening a [LessonScreen].
class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key, required this.title, required this.lessons});

  final String title;
  final List<Lesson> lessons;

  static Route<void> route(
    String title,
    List<Lesson> lessons, {
    String? name,
  }) => MaterialPageRoute(
    settings: RouteSettings(name: name),
    builder: (_) => LessonsScreen(title: title, lessons: lessons),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      children: [for (final lesson in lessons) LessonCard(lesson)],
    ),
  );
}

class LessonCard extends StatelessWidget {
  const LessonCard(this.lesson, {super.key});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final lang = context.lang;
    final stars = context.select((LessonsCubit c) => c.state.stars[lesson.id]);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => Navigator.push(context, LessonScreen.route(lesson)),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Palette.greenSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(lesson.icon, color: Palette.green),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title.of(lang),
                    style: Fonts.body(16, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lesson.subtitle.of(lang),
                    style: Fonts.body(12.5, color: Palette.inkSoft),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (lesson.steps.length > 1)
                        l.lessonSteps(context.n(lesson.steps.length)),
                      if (lesson.quiz.isNotEmpty)
                        l.lessonQuestions(context.n(lesson.quiz.length)),
                    ].join(' · '),
                    style: Fonts.body(12, color: Palette.inkSoft),
                  ),
                ],
              ),
            ),
            if (stars != null) Stars(stars, size: 16),
            Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
          ],
        ),
      ),
    );
  }
}

class Stars extends StatelessWidget {
  const Stars(this.count, {super.key, this.size = 20, this.of = 3});

  final int count;
  final int of;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < of; i++)
        Icon(
          i < count ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: i < count ? const Color(0xFFE0A030) : Palette.inkSoft,
        ),
    ],
  );
}

/// Steps one page at a time, then the quiz, then the stars earned.
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lesson});

  final Lesson lesson;

  static Route<void> route(Lesson lesson) =>
      MaterialPageRoute(builder: (_) => LessonScreen(lesson: lesson));

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _pages = PageController();
  var _page = 0;

  /// Question index → chosen option.
  final _answers = <int, int>{};

  Lesson get _lesson => widget.lesson;
  int get _count => _lesson.steps.length + _lesson.quiz.length + 1;
  bool get _onQuiz => _page >= _lesson.steps.length && _page < _count - 1;
  int get _correct => [
    for (final MapEntry(:key, :value) in _answers.entries)
      if (_lesson.quiz[key].answer == value) key,
  ].length;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int page) {
    if (page == _count - 1) {
      context.read<LessonsCubit>().finish(
        _lesson.id,
        LessonsCubit.starsFor(_correct, _lesson.quiz.length),
      );
    }
    _pages.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final lang = context.lang;
    final last = _page == _count - 1;
    final waiting =
        _onQuiz && !_answers.containsKey(_page - _lesson.steps.length);
    return Scaffold(
      appBar: AppBar(
        title: Text(_lesson.title.of(lang)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_page + 1) / _count,
            minHeight: 4,
            color: Palette.green,
            backgroundColor: Palette.green.withValues(alpha: .12),
          ),
        ),
      ),
      body: PageView(
        controller: _pages,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (p) => setState(() => _page = p),
        children: [
          for (final (i, step) in _lesson.steps.indexed)
            _StepPage(step: step, number: i + 1, of: _lesson.steps.length),
          for (final (i, q) in _lesson.quiz.indexed)
            _QuizPage(
              question: q,
              number: i + 1,
              of: _lesson.quiz.length,
              chosen: _answers[i],
              onChoose: (o) => setState(() => _answers[i] = o),
            ),
          _Finish(
            correct: _correct,
            total: _lesson.quiz.length,
            onRetry: _lesson.quiz.isEmpty
                ? null
                : () {
                    setState(_answers.clear);
                    _go(_lesson.steps.length);
                  },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              if (_page > 0 && !last)
                OutlinedButton(
                  onPressed: () => _go(_page - 1),
                  child: Text(l.lessonBack),
                ),
              const Spacer(),
              FilledButton(
                onPressed: waiting
                    ? null
                    : last
                    ? () => Navigator.pop(context)
                    : () => _go(_page + 1),
                child: Text(
                  last
                      ? l.feedbackDone
                      : _page == _lesson.steps.length - 1 &&
                            _lesson.quiz.isNotEmpty
                      ? l.lessonStartQuiz
                      : l.lessonNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepPage extends StatelessWidget {
  const _StepPage({required this.step, required this.number, required this.of});

  final LessonStep step;
  final int number;
  final int of;

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      children: [
        if (step.image case final image?)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: Palette.greenSoft,
                      child: Icon(step.icon, color: Palette.green, size: 48),
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Palette.greenSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(step.icon, color: Palette.green, size: 40),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          context.l.lessonStepOf(context.n(number), context.n(of)),
          textAlign: TextAlign.center,
          style: Fonts.body(12.5, color: Palette.inkSoft),
        ),
        const SizedBox(height: 4),
        Text(
          step.title.of(lang),
          textAlign: TextAlign.center,
          style: Fonts.display(24),
        ),
        const SizedBox(height: 14),
        Text(
          step.body.of(lang),
          textAlign: TextAlign.center,
          style: Fonts.body(15.5).copyWith(height: 1.55),
        ),
        if (step.arabic case final arabic?) ...[
          const SizedBox(height: 20),
          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  arabic,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: Fonts.arabic(22),
                ),
                if (lang != 'ar' && step.translit != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    step.translit!,
                    textAlign: TextAlign.center,
                    style: Fonts.body(
                      14,
                      color: Palette.green,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
                if (lang != 'ar' && step.meaning != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    step.meaning!,
                    textAlign: TextAlign.center,
                    style: Fonts.body(13.5, color: Palette.inkSoft),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _QuizPage extends StatelessWidget {
  const _QuizPage({
    required this.question,
    required this.number,
    required this.of,
    required this.chosen,
    required this.onChoose,
  });

  final QuizQuestion question;
  final int number;
  final int of;
  final int? chosen;
  final ValueChanged<int> onChoose;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final lang = context.lang;
    final answered = chosen != null;
    const wrong = Color(0xFFD64545);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Caption(l.lessonQuestionOf(context.n(number), context.n(of))),
        const SizedBox(height: 8),
        Text(question.question.of(lang), style: Fonts.display(21)),
        if (question.arabic case final arabic?) ...[
          const SizedBox(height: 16),
          AppCard(
            margin: EdgeInsets.zero,
            child: Text(
              arabic,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: Fonts.arabic(26),
            ),
          ),
        ],
        const SizedBox(height: 18),
        for (final (i, option) in question.options.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Builder(
              builder: (context) {
                final right = i == question.answer;
                final picked = i == chosen;
                final color = !answered
                    ? Palette.rule
                    : right
                    ? Palette.green
                    : picked
                    ? wrong
                    : Palette.rule;
                return Material(
                  color: answered && (right || picked)
                      ? color.withValues(alpha: .1)
                      : Palette.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: color, width: answered ? 1.6 : .8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: answered ? null : () => onChoose(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.of(lang),
                              style: Fonts.body(15.5, weight: FontWeight.w500),
                            ),
                          ),
                          if (answered && right)
                            Icon(Icons.check_circle_rounded, color: color)
                          else if (answered && picked)
                            Icon(Icons.cancel_rounded, color: color),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        if (answered) ...[
          const SizedBox(height: 4),
          Text(
            chosen == question.answer ? l.lessonRight : l.lessonWrong,
            style: Fonts.body(
              15,
              weight: FontWeight.w600,
              color: chosen == question.answer ? Palette.green : wrong,
            ),
          ),
          if (question.explain case final explain?) ...[
            const SizedBox(height: 4),
            Text(
              explain.of(lang),
              style: Fonts.body(14, color: Palette.inkSoft),
            ),
          ],
        ],
      ],
    );
  }
}

class _Finish extends StatelessWidget {
  const _Finish({
    required this.correct,
    required this.total,
    required this.onRetry,
  });

  final int correct;
  final int total;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final stars = LessonsCubit.starsFor(correct, total);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      children: [
        Icon(Icons.celebration_rounded, color: Palette.green, size: 64),
        const SizedBox(height: 16),
        Center(child: Stars(stars, size: 40)),
        const SizedBox(height: 16),
        Text(
          l.lessonDone,
          textAlign: TextAlign.center,
          style: Fonts.display(24),
        ),
        if (total > 0) ...[
          const SizedBox(height: 8),
          Text(
            l.lessonScore(context.n(correct), context.n(total)),
            textAlign: TextAlign.center,
            style: Fonts.body(15, color: Palette.inkSoft),
          ),
        ],
        if (onRetry != null && correct < total) ...[
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.replay_rounded),
              label: Text(l.lessonRetryQuiz),
            ),
          ),
        ],
      ],
    );
  }
}
