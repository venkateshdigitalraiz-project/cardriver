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

    // Verify Passenger Login header and widgets exist
    expect(find.text('SAFE & VERIFIED DRIVERS NEARBY'), findsOneWidget);
    expect(find.text('Where to next?'), findsOneWidget);
    expect(find.text('QUICK DEMO RIDER ACCOUNTS'), findsOneWidget);
  });
}
