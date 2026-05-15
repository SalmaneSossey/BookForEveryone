import 'package:flutter_test/flutter_test.dart';

import 'package:kitab_lil_jamie/app.dart';

void main() {
  testWidgets('App opens Samia voice mode first', (WidgetTester tester) async {
    await tester.pumpWidget(const KitabLilJamieApp());
    await tester.pumpAndSettle();

    expect(find.text('Samia'), findsOneWidget);
    expect(find.text('Start listening'), findsOneWidget);
    expect(find.text('Stop'), findsOneWidget);
    expect(find.textContaining('Try saying:'), findsOneWidget);
  });
}
