import 'package:flutter_test/flutter_test.dart';
import 'package:idioms_quiz/data/review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late int requested;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    requested = 0;
    ReviewService.debugIsAvailable = () async => true;
    ReviewService.debugRequestReview = () async => requested++;
  });

  tearDown(() {
    ReviewService.debugIsAvailable = null;
    ReviewService.debugRequestReview = null;
    ReviewService.debugOpenStoreListing = null;
  });

  Future<bool> ask({int? stars = 5, int clearedRounds = 5}) => ReviewService
      .instance
      .maybeAskAfterRound(stars: stars, clearedRounds: clearedRounds);

  test('asks after a strong round once enough rounds are cleared', () async {
    expect(await ask(), isTrue);
    expect(requested, 1);
  });

  test('a four-star round is good enough to ask', () async {
    expect(await ask(stars: 4), isTrue);
    expect(requested, 1);
  });

  test('stays quiet for anything below four stars', () async {
    expect(await ask(stars: 3), isFalse);
    expect(await ask(stars: 0), isFalse);
    expect(await ask(stars: null), isFalse);
    expect(requested, 0);
  });

  test('stays quiet until the learner has cleared a few rounds', () async {
    expect(await ask(clearedRounds: 2), isFalse);
    expect(requested, 0);
  });

  test('asks at most once on the same day', () async {
    expect(await ask(), isTrue);
    expect(await ask(), isFalse);
    expect(requested, 1);
  });

  test('gives up after three attempts', () async {
    for (var day = 0; day < 5; day++) {
      // Simulate a new day by clearing the date stamp the service wrote.
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('review_prompt_last_date');
      await ask();
    }
    expect(requested, 3);
  });

  test('never asks again once marked done', () async {
    await ReviewService.instance.markDone();
    expect(await ask(), isFalse);
    expect(requested, 0);
  });

  test('opening the listing on demand stops later prompts', () async {
    var opened = 0;
    ReviewService.debugOpenStoreListing = () async => opened++;
    expect(await ReviewService.instance.openStoreListing(), isTrue);
    expect(opened, 1);
    expect(await ask(), isFalse);
    expect(requested, 0);
  });

  test('reports failure when the store cannot be opened', () async {
    ReviewService.debugOpenStoreListing = () async =>
        throw Exception('no store');
    expect(await ReviewService.instance.openStoreListing(), isFalse);
  });

  test('does nothing when the platform has no review flow', () async {
    ReviewService.debugIsAvailable = () async => false;
    expect(await ask(), isFalse);
    expect(requested, 0);
  });
}
