import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tes1/main.dart';
import 'package:tes1/screens/home_screen.dart';

void main() {
  testWidgets('login matches the wide SiKos sign-in layout', (tester) async {
    tester.view.physicalSize = const Size(1600, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SikosApp());

    final frame = find.byKey(const Key('login-register'));
    expect(frame, findsOneWidget);
    expect(tester.getSize(frame), const Size(1600, 800));
    expect(tester.getTopLeft(frame), Offset.zero);

    final frameWidget = tester.widget<Container>(frame);
    expect(frameWidget.color, const Color(0xFFF7FBFB));
    expect(find.text('SiKos'), findsOneWidget);
    expect(find.text('Cari Kos Jadi Mudah'), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
    expect(find.text('Email Kampus / Umum'), findsOneWidget);
    expect(find.text('Lupa Password?'), findsOneWidget);
    expect(find.text('MASUK SEBAGAI ROLE'), findsOneWidget);
    expect(find.text('Penyewa (Mahasiswa)'), findsOneWidget);
    expect(find.text('Pemilik Kos'), findsOneWidget);
    expect(find.text('Masuk Sekarang'), findsOneWidget);
    expect(find.text('ATAU MASUK DENGAN'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Daftar Akun Baru'), findsOneWidget);

    expect(
      tester.getSize(find.byKey(const Key('login-email-field'))).width,
      greaterThan(1400),
    );
  });

  testWidgets('app starts on login and shows inline validation errors', (
    tester,
  ) async {
    await tester.pumpWidget(const SikosApp());

    expect(find.text('SiKos'), findsOneWidget);

    await tester.tap(find.byKey(const Key('login-submit-button')));
    await tester.pump();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('login-email-field')), 'abc');
    await tester.enterText(
      find.byKey(const Key('login-password-field')),
      '123',
    );
    await tester.tap(find.byKey(const Key('login-submit-button')));
    await tester.pump();

    expect(find.text('Format email tidak valid'), findsOneWidget);
    expect(find.text('Password minimal 8 karakter'), findsOneWidget);
  });

  testWidgets('valid login replaces login route with home', (tester) async {
    await tester.pumpWidget(const SikosApp());

    await tester.enterText(
      find.byKey(const Key('login-email-field')),
      'imam@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login-password-field')),
      'rahasia1',
    );
    await tester.tap(find.byKey(const Key('login-submit-button')));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byKey(const Key('login-register')), findsNothing);
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
