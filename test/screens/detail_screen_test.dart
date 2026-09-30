import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tes1/models/item.dart';
import 'package:tes1/routes/app_routes.dart';
import 'package:tes1/screens/catatan_form_screen.dart';
import 'package:tes1/screens/detail_screen.dart';

const _item = Item(
  id: 'test',
  title: 'Kos Uji',
  subtitle: 'Dekat kampus',
  description: 'Deskripsi kos untuk pengujian.',
  price: 'Rp 900.000',
  rating: '4.5',
  imageUrl: '',
  isMale: false,
  isPopular: true,
);

void main() {
  testWidgets('note form validates and returns text to detail', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const DetailScreen(item: _item),
        onGenerateRoute: AppRoutes.onGenerateRoute,
        onUnknownRoute: AppRoutes.onUnknownRoute,
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Tulis Catatan'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Tulis Catatan'));
    await tester.pumpAndSettle();

    expect(find.byType(CatatanFormScreen), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pump();
    expect(find.text('Catatan wajib diisi'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Catatan'),
      'abc',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pump();
    expect(find.text('Catatan minimal 5 karakter'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Catatan'),
      'Dekat dengan halte kampus',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan: Dekat dengan halte kampus'), findsOneWidget);
    expect(find.text('Catatan berhasil disimpan'), findsOneWidget);
  });

  testWidgets('cancelling the note form keeps the previous note', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const DetailScreen(item: _item),
        onGenerateRoute: AppRoutes.onGenerateRoute,
        onUnknownRoute: AppRoutes.onUnknownRoute,
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Tulis Catatan'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Tulis Catatan'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Catatan'),
      'Catatan awal',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Tulis Catatan'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Catatan'),
      'Catatan yang dibatalkan',
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Catatan: Catatan awal'), findsOneWidget);
    expect(find.textContaining('dibatalkan'), findsNothing);
  });
}
