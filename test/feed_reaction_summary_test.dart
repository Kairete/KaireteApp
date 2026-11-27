import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairete/features/feed/widgets/feed_reaction_summary.dart';

void main() {
  test('parses real usernames without duplicates and limits to two', () {
    final users = parseReactionNames({
      'reaction_users': [
        {'username': 'Pippo'},
        {'username': 'Pluto'},
        {'username': 'Pippo'},
      ],
    });
    expect(users, ['Pippo', 'Pluto']);
  });

  testWidgets('shows two names and only the remaining reactions', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: FeedReactionSummary(total: 8, names: ['Pippo', 'Pluto']),
      ),
    ));
    expect(find.text('Pippo, Pluto e altre 6 persone'), findsOneWidget);
  });

  testWidgets('shows real count without inventing users', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: FeedReactionSummary(total: 8)),
    ));
    expect(find.text('8 persone hanno reagito'), findsOneWidget);
  });

  testWidgets('opens summary on tap', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: FeedReactionSummary(total: 2, names: ['Pippo', 'Pluto']),
      ),
    ));
    await tester.tap(find.text('Pippo e Pluto'));
    await tester.pumpAndSettle();
    expect(find.text('Reazioni (2)'), findsOneWidget);
  });
}
