import 'package:flutter_test/flutter_test.dart';

import 'package:idioms_quiz/main.dart';

void main() {
  testWidgets('App builds and shows the home app bar', (tester) async {
    await tester.pumpWidget(const IdiomsQuizApp());
    await tester.pump();
    expect(find.text('四字熟語道場'), findsOneWidget);
  });
}
