import 'package:flutter_test/flutter_test.dart';
import 'package:health_flow/main.dart';

void main() {
  testWidgets('HealthFlow démarre correctement', (WidgetTester tester) async {
    await tester.pumpWidget(const HealthFlowApp());

    expect(find.text('HealthFlow'), findsOneWidget);
  });
}