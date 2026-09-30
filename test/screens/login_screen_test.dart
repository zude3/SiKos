import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tes1/main.dart';
import 'package:tes1/screens/home_screen.dart';

void main() {
  testWidgets('login uses the 402 by 844 responsive design frame', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SikosApp());

    final frame = find.byKey(const Key('login-register'));
    expect(frame, findsOneWidget);
    expect(tester.getSize(frame), const Size(402, 844));

    final frameWidget = tester.widget<Container>(frame);
    expect(frameWidget.color, const Color(0xFFF7FBFB));

    final layout = tester.widget<Column>(
      find.descendant(of: frame, matching: find.byType(Column)).first,
    );
    expect(layout.mainAxisAlignment, MainAxisAlignment.spaceBetween);
    expect(layout.crossAxisAlignment, CrossAxisAlignment.start);
  });

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
