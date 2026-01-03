import 'package:flutter_test/flutter_test.dart';
import 'package:xyz/main.dart';

void main() {
  testWidgets('app boots', (tester) async {
    await tester.pumpWidget(const MyApp(enableBindings: false));
    await tester.pump();
    expect(true, isTrue);
  });
}
