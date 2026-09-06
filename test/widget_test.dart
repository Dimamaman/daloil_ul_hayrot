import 'package:flutter_test/flutter_test.dart';
import 'package:daloil_ul_hayrot/app.dart';

void main() {
  testWidgets('App renders reader page', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('Daloil ul-Hayrot'), findsOneWidget);
  });
}
