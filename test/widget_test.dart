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
  testWidgets('starts at login and validates required fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SikosApp());

    expect(find.text('Masuk'), findsNWidgets(2));
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
  });

  testWidgets('loads an item and returns a saved note to detail', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SikosApp());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'user@example.com');
    await tester.enterText(fields.at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Kos Ghozi'), findsNWidgets(2));
    expect(find.text('kos jelek pinggiran kota'), findsNWidgets(2));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 900));
    await tester.pump(const Duration(milliseconds: 400));

    final firstItem = find.text('Kos Nopal').first;
    await tester.ensureVisible(firstItem);
    await tester.tap(firstItem);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Deskripsi lengkap kos nopal.'), findsOneWidget);

    await tester.tap(find.text('Tulis Catatan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextFormField), 'Kamar bersih');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Catatan: Kamar bersih'), findsOneWidget);
  });
}
