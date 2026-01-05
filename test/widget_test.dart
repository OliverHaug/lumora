import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xyz/main.dart';

void main() {
  testWidgets('app boots', (tester) async {
    await tester.pumpWidget(ProviderScope(child: MyApp()));

    await tester.pump();
    expect(find.byType(MyApp), findsOneWidget);
  });
}
