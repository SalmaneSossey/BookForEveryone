import 'package:flutter_test/flutter_test.dart';

import 'package:kitab_lil_jamie/app.dart';

void main() {
  testWidgets('Onboarding exposes the three accessible reading paths', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KitabLilJamieApp());

    expect(find.text('KitabLilJamie'), findsOneWidget);
    expect(find.text('كتاب للجميع'), findsOneWidget);
    expect(find.text('Blind mode - Samia'), findsOneWidget);
    expect(find.text('Deaf mode - SignBook'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
  });
}
