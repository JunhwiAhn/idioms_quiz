import 'package:flutter/material.dart';

import '../data/app_text.dart';
import '../data/pronunciation_service.dart';

/// Set once the "no Spanish voice" notice has been shown in this app run, so
/// auto-play does not nag on every question.
bool _notifiedMissingVoice = false;

@visibleForTesting
void resetMissingVoiceNotice() => _notifiedMissingVoice = false;

/// Speaks [text] and, when the device has no Spanish voice, surfaces that
/// instead of failing silently.
///
/// Pass [oncePerRun] for playback the user did not ask for — auto-play still
/// needs to explain the first silence, but must not interrupt after that.
Future<void> pronounceWithFeedback(
  BuildContext context,
  String text,
  AppText appText, {
  bool oncePerRun = false,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final spoken = await PronunciationService.instance.speakSpanish(text);
  if (spoken) return;
  if (oncePerRun && _notifiedMissingVoice) return;
  if (messenger == null || !context.mounted) return;

  _notifiedMissingVoice = true;
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(appText.ttsMissingVoice),
      duration: const Duration(seconds: 8),
      action: SnackBarAction(
        label: appText.ttsInstallVoice,
        onPressed: () {
          if (context.mounted) showVoiceInstallGuide(context, appText);
        },
      ),
    ),
  );
}

/// Explains exactly which engine and voice to pick before handing the user to
/// the system installer — that screen lists several engines, and picking
/// Samsung TTS instead of Google's leaves them without a Spanish voice.
Future<void> showVoiceInstallGuide(
  BuildContext context,
  AppText appText,
) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final proceed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(appText.ttsDownloadVoice),
      content: SingleChildScrollView(child: Text(appText.ttsInstallSteps)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(appText.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(appText.ttsOpenInstaller),
        ),
      ],
    ),
  );
  if (proceed != true) return;

  final opened = await PronunciationService.instance.openVoiceInstall();
  if (opened || messenger == null) return;
  messenger.showSnackBar(
    SnackBar(content: Text(appText.ttsSettingsUnavailable)),
  );
}

/// Wraps a pronunciation control so it becomes a download prompt when the
/// device has no Spanish voice — a play button that silently does nothing is
/// worse than one that offers the fix.
///
/// The visual stays with the caller: [builder] receives the current state and
/// the tap handler, so each screen keeps its own button styling.
class PronounceButton extends StatefulWidget {
  final String text;
  final AppText appText;

  /// Replaces the default speak action when the voice is available. Screens
  /// that need extra bookkeeping around playback (cancelling a pending
  /// auto-play, say) pass their own handler here.
  final VoidCallback? onSpeak;
  final Widget Function(
    BuildContext context,
    bool voiceAvailable,
    VoidCallback onPressed,
  )
  builder;

  const PronounceButton({
    super.key,
    required this.text,
    required this.appText,
    required this.builder,
    this.onSpeak,
  });

  @override
  State<PronounceButton> createState() => _PronounceButtonState();
}

class _PronounceButtonState extends State<PronounceButton>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The user may have just installed the voice in system settings, so
    // re-check on the way back instead of leaving a stale download button.
    if (state == AppLifecycleState.resumed &&
        !PronunciationService.instance.spanishVoiceAvailable.value) {
      PronunciationService.instance.refreshAvailability();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PronunciationService.instance.spanishVoiceAvailable,
      builder: (context, available, _) => widget.builder(
        context,
        available,
        available ? (widget.onSpeak ?? _speak) : _install,
      ),
    );
  }

  void _speak() => pronounceWithFeedback(context, widget.text, widget.appText);

  void _install() => showVoiceInstallGuide(context, widget.appText);
}
