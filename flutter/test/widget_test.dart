// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tes1/main.dart';

void main() {
  testWidgets('renders the Sikos home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SikosApp());

    expect(find.text('Hai, Imam Zuhdi'), findsOneWidget);
    expect(find.text('Kos Populer'), findsOneWidget);
    expect(find.text('Terdekat dari Kampusmu'), findsOneWidget);
    expect(find.text('Kontrakan Ghozi'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.info_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Komplain & Maintenance'), findsOneWidget);
  });
}
