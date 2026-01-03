import 'package:flutter_test/flutter_test.dart';
import 'package:xyz/main.dart';

void main() {
  testWidgets('app boots', (tester) async {
    await tester.pumpWidget(const MyApp());

    // One pump to let initial build complete
    await tester.pump();

    // If we reach here, app did not throw during build.
    expect(true, isTrue);
  });
}
