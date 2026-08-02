import 'package:flutter_test/flutter_test.dart';
import 'package:idioms_quiz/data/fullscreen_ad_gate.dart';

void main() {
  test(
    'waits for fullscreen dismissal after the show request completes',
    () async {
      final gate = FullscreenAdGate();
      var completed = false;

      final waiting = gate
          .showAndWait(() async {})
          .then((_) => completed = true);
      await Future<void>.delayed(Duration.zero);

      expect(completed, isFalse);

      gate.finish();
      await waiting;

      expect(completed, isTrue);
    },
  );

  test('finish is safe when callbacks arrive more than once', () async {
    final gate = FullscreenAdGate();

    gate.finish();
    gate.finish();

    await expectLater(gate.showAndWait(() async {}), completes);
  });
}
