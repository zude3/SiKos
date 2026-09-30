// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tes1/data/item_repository.dart';
import 'package:tes1/routes/app_routes.dart';
import 'package:tes1/screens/home_screen.dart';
import 'package:tes1/main.dart';

void main() {
  testWidgets('starts at login and validates credentials', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SikosApp());

    expect(find.text('SiKos'), findsOneWidget);
    expect(find.text('Email Kampus / Umum'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk Sekarang'));
    await tester.pumpAndSettle();
    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'abc');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.pump();
    expect(find.text('Format email tidak valid'), findsOneWidget);
    expect(find.text('Password minimal 8 karakter'), findsOneWidget);
  });

  testWidgets('logs in, opens a kos, and saves a note', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SikosApp());
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'mahasiswa@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk Sekarang'));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Kos Populer'), findsOneWidget);
    expect(find.text('Terdekat dari Kampusmu'), findsOneWidget);
    expect(find.text('Kontrakan Ghozi'), findsOneWidget);

    await tester.ensureVisible(find.text('Kontrakan Ghozi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kontrakan Ghozi'));
    await tester.pumpAndSettle();
    expect(find.text('300m dari Los Chicken'), findsOneWidget);

    await tester.tap(find.text('Tulis Catatan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Catatan wajib diisi'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Dekat kampus');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Catatan: Dekat kampus'), findsOneWidget);
    expect(find.text('Catatan berhasil disimpan'), findsOneWidget);
  });

  testWidgets('switches to registration mode and toggles password visibility', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SikosApp());

    await tester.tap(find.text('Daftar').first);
    await tester.pumpAndSettle();
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Daftar Sekarang'), findsOneWidget);

    await tester.tap(find.byTooltip('Tampilkan password'));
    await tester.pump();
    expect(find.byTooltip('Sembunyikan password'), findsOneWidget);
  });

  testWidgets('shows an error state with a retry action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(simulateError: true)),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Oops, terjadi kesalahan'), findsOneWidget);
    expect(
      find.text('Gagal memuat data. Periksa koneksi internet.'),
      findsOneWidget,
    );
    expect(find.text('Coba Lagi'), findsOneWidget);

    await tester.tap(find.text('Coba Lagi'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Oops, terjadi kesalahan'), findsOneWidget);
  });

  testWidgets('shows the empty view when the repository has no items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(repository: ItemRepository(items: const [])),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Belum ada data.'), findsOneWidget);
  });

  testWidgets('shows a fallback page for unknown routes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/tidak-ada'),
              child: const Text('Buka route'),
            ),
          ),
        ),
        onGenerateRoute: AppRoutes.onGenerateRoute,
        onUnknownRoute: AppRoutes.onUnknownRoute,
      ),
    );
    await tester.tap(find.text('Buka route'));
    await tester.pumpAndSettle();

    expect(find.text('404'), findsOneWidget);
    expect(find.text('Route: /tidak-ada'), findsOneWidget);
  });
}
