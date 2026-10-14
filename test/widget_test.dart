import 'package:flutter_test/flutter_test.dart';
import 'package:cardriver/main.dart';
import 'package:cardriver/injection_container.dart';

void main() {
  setUp(() {
    InjectionContainer.init();
  });

  testWidgets('Customer login screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const CarDriverApp());
    await tester.pumpAndSettle();

    // Verify LoginPage header exists
    expect(find.text('Ready to Drive?'), findsOneWidget);
  });
}
