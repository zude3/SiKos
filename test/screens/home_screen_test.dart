import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tes1/data/item_repository.dart';
import 'package:tes1/routes/app_routes.dart';
import 'package:tes1/screens/detail_screen.dart';
import 'package:tes1/screens/home_screen.dart';

void main() {
  testWidgets('home shows loading before rendering repository items', (
    tester,
  ) async {
    final repository = ItemRepository(delay: const Duration(seconds: 1));

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(repository: repository)),
    );

    expect(find.text('Memuat data...'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text('Kos Populer'), findsOneWidget);
    expect(find.text('Kos Nopal'), findsOneWidget);
    expect(find.text('Kontrakan Ghozi'), findsOneWidget);
  });

  testWidgets('home shows an empty state when the repository has no items', (
    tester,
  ) async {
    final repository = ItemRepository(delay: Duration.zero, items: const []);

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada data kos.'), findsOneWidget);
  });

  testWidgets('home shows an error state and retry action', (tester) async {
    final repository = ItemRepository(delay: Duration.zero);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(repository: repository, simulateError: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Oops, terjadi kesalahan'), findsOneWidget);
    expect(
      find.text('Gagal memuat data. Periksa koneksi internet.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Coba Lagi'), findsOneWidget);
  });

  testWidgets('tapping a listing sends its data to detail', (tester) async {
    final repository = ItemRepository(delay: Duration.zero);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(repository: repository),
        onGenerateRoute: AppRoutes.onGenerateRoute,
        onUnknownRoute: AppRoutes.onUnknownRoute,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kos Nopal'));
    await tester.pumpAndSettle();

    expect(find.byType(DetailScreen), findsOneWidget);
    expect(find.text('Kos Nopal'), findsWidgets);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Kos putri yang nyaman dan dekat'),
      findsOneWidget,
    );
  });
}
