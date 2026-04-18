import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/quiz_session.dart';
import '../data/score_service.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final QuizSession session;
  const QuizScreen({super.key, required this.session});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _picked;
  bool _revealed = false;

  QuizQuestion get _q => widget.session.current;
  int get _index => widget.session.currentIndex;
  int get _total => widget.session.questions.length;

  void _pick(int i) {
    if (_revealed) return;
    setState(() {
      _picked = i;
      _revealed = true;
    });
  }

  Future<void> _next() async {
    widget.session.submit(_picked!);
    if (widget.session.isFinished) {
      final reward = await ScoreService().commitRun(
        correct: widget.session.correctCount,
        total: widget.session.questions.length,
        longestStreak: widget.session.longestStreak,
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            correct: widget.session.correctCount,
            total: widget.session.questions.length,
            longestStreak: widget.session.longestStreak,
            newTotalPoints: reward,
          ),
        ),
      );
    } else {
      setState(() {
        _picked = null;
        _revealed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final progress = (_index) / _total;

    return Scaffold(
      appBar: AppBar(
        title: Text('問題 ${_index + 1} / $_total'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'つぎの四字熟語の意味は?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansJp(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      _q.idiom.idiom.split('').join(' '),
                      style: AppTheme.idiomDisplay(context),
                      textAlign: TextAlign.center,
                    )
                        .animate(key: ValueKey(_q.idiom.idiom))
                        .fadeIn(duration: 350.ms),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      _q.idiom.reading,
                      style: GoogleFonts.notoSansJp(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  for (int i = 0; i < _q.choices.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ChoiceTile(
                        index: i,
                        text: _q.choices[i],
                        picked: _picked,
                        correct: _q.correctIndex,
                        revealed: _revealed,
                        onTap: () => _pick(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _revealed ? 1 : 0,
              child: FilledButton(
                onPressed: _revealed ? _next : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Text(
                  widget.session.currentIndex == _total - 1
                      ? '結果を見る'
                      : '次の問題へ',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _ChoiceTile extends StatelessWidget {
  final int index;
  final String text;
  final int? picked;
  final int correct;
  final bool revealed;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.index,
    required this.text,
    required this.picked,
    required this.correct,
    required this.revealed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Color bg = scheme.surface;
    Color border = scheme.outlineVariant;
    IconData? trailing;
    Color? trailingColor;

    if (revealed) {
      if (index == correct) {
        bg = scheme.primaryContainer;
        border = scheme.primary;
        trailing = Icons.check_circle_rounded;
        trailingColor = scheme.primary;
      } else if (index == picked) {
        bg = scheme.errorContainer;
        border = scheme.error;
        trailing = Icons.cancel_rounded;
        trailingColor = scheme.error;
      }
    } else if (picked == index) {
      border = scheme.primary;
    }

    final letter = String.fromCharCode('A'.codeUnitAt(0) + index);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: revealed ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  letter,
                  style: GoogleFonts.notoSerifJp(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.notoSansJp(
                    fontSize: 15,
                    height: 1.5,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                Icon(trailing, color: trailingColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
