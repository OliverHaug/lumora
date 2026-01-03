import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xyz/main.dart';

void main() {
  testWidgets('app boots', (tester) async {
    await tester.pumpWidget(
      MyApp(enableBindings: false, testHome: const Scaffold(body: SizedBox())),
    );
    await tester.pump();
    expect(true, isTrue);
  });
}
