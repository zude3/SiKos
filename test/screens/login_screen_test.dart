import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tes1/main.dart';
import 'package:tes1/screens/home_screen.dart';

void main() {
  testWidgets('app starts on login and shows inline validation errors', (
    tester,
  ) async {
    await tester.pumpWidget(const SikosApp());

    expect(find.text('Masuk ke SiKos'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'abc');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      '123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();

    expect(find.text('Format email tidak valid'), findsOneWidget);
    expect(find.text('Password minimal 8 karakter'), findsOneWidget);
  });

  testWidgets('valid login replaces login route with home', (tester) async {
    await tester.pumpWidget(const SikosApp());

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'imam@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'rahasia1',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Masuk ke SiKos'), findsNothing);
    expect(
      Navigator.of(tester.element(find.byType(HomeScreen))).canPop(),
      isFalse,
    );
  });

  testWidgets('unknown named route displays the 404 screen', (tester) async {
    await tester.pumpWidget(const SikosApp());

    Navigator.of(tester.element(find.byType(TextFormField).first))
        .pushNamed('/tidak-ada');
    await tester.pumpAndSettle();

    expect(find.text('404'), findsOneWidget);
    expect(find.text('Route: /tidak-ada'), findsOneWidget);
  });
}
