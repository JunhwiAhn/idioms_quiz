import 'package:flutter_test/flutter_test.dart';

import 'package:idioms_quiz/main.dart';

void main() {
  testWidgets('App builds and shows the home app bar', (tester) async {
    await tester.pumpWidget(const IdiomsQuizApp());
    await tester.pump(const Duration(seconds: 3));
    expect(find.textContaining('DELE Voca'), findsWidgets);
  });
}
