import 'package:flutter_test/flutter_test.dart';
import 'package:blinkchat/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ChitChatApp());
    expect(find.byType(ChitChatApp), findsOneWidget);
  });
}
