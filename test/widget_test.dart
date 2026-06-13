import 'package:flutter_test/flutter_test.dart';
import 'package:tenant_management_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LumiereStayApp());
    expect(find.byType(LumiereStayApp), findsOneWidget);
  });
}
