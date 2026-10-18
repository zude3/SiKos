// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tes1/models/invoice.dart';
import 'package:tes1/screens/billing_screen.dart';
import 'package:tes1/screens/home_screen.dart';
import 'package:tes1/services/tagihan_service.dart';

void main() {
  testWidgets('renders the Sikos home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(tagihanService: _FakeTagihanService())),
    );

    expect(find.text('Hai, Imam Zuhdi'), findsOneWidget);
    expect(find.text('Kos Populer'), findsOneWidget);
    expect(find.text('Terdekat dari Kampusmu'), findsOneWidget);
    expect(find.text('Kontrakan Ghozi'), findsOneWidget);
  });

  testWidgets('opens billing from the bottom navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(tagihanService: _FakeTagihanService())),
    );

    await tester.tap(find.text('Tagihan'));
    await tester.pumpAndSettle();

    expect(find.text('Daftar tagihan'), findsOneWidget);
  });

  testWidgets('shows invoice list and filters by late status', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: BillingScreen(tagihanService: _FakeTagihanService())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daftar tagihan'), findsOneWidget);
    expect(find.text('Belum bayar'), findsWidgets);
    expect(find.text('Menunggu'), findsOneWidget);

    await tester.tap(find.text('Terlambat').first);
    await tester.pumpAndSettle();

    expect(find.text('Kost Wafa'), findsOneWidget);
    expect(find.text('Kost Nopal'), findsNothing);
  });

  testWidgets('billing screen only exposes renter actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: BillingScreen(tagihanService: _FakeTagihanService())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daftar tagihan'), findsOneWidget);
    expect(find.text('Simulasi pemilik'), findsNothing);
    expect(find.text('Simulasikan booking disetujui'), findsNothing);
    expect(find.text('Verifikasi lunas'), findsNothing);
    expect(find.text('Unggah bukti pembayaran'), findsNothing);
  });

  testWidgets('shows upcoming due-date reminders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: BillingScreen(tagihanService: _FakeTagihanService())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Notifikasi'));
    await tester.pumpAndSettle();

    expect(find.text('Pengingat jatuh tempo'), findsOneWidget);
    expect(find.textContaining('Kost Nopal'), findsOneWidget);
  });

  testWidgets('opens invoice detail from the list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: BillingScreen(tagihanService: _FakeTagihanService())),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Kost Nopal'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Kost Nopal').first);
    await tester.pumpAndSettle();

    expect(find.text('Detail tagihan'), findsOneWidget);
    expect(find.text('Unggah bukti pembayaran'), findsOneWidget);
    expect(find.text('Kamar 203'), findsOneWidget);
  });

  testWidgets('pending proof can be changed or deleted before verification', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: BillingScreen(tagihanService: _FakeTagihanService())),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Griya Anggrek Executive'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Griya Anggrek Executive').first);
    await tester.pumpAndSettle();

    expect(find.text('Detail tagihan'), findsOneWidget);
    expect(find.text('Menunggu verifikasi'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Ganti bukti pembayaran'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Ganti bukti pembayaran'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Hapus bukti pembayaran'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Hapus bukti pembayaran'), findsOneWidget);
    await tester.tap(find.text('Hapus bukti pembayaran'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus').last);
    await tester.pumpAndSettle();

    expect(find.text('Griya Anggrek Executive'), findsOneWidget);
    expect(find.text('Belum bayar'), findsWidgets);
  });
}

class _FakeTagihanService extends TagihanService {
  _FakeTagihanService() {
    final today = DateTime.now();
    _rows = [
      _row(1, 'Kost Nopal', 203, 850000, today.add(const Duration(days: 2))),
      _row(
        2,
        'Griya Anggrek Executive',
        12,
        1200000,
        today.add(const Duration(days: 2)),
        status: 'menunggu_verifikasi',
        proof: true,
      ),
      _row(
        3,
        'Kost Wafa',
        '08',
        1500000,
        today.subtract(const Duration(days: 4)),
      ),
      _row(
        4,
        'Kontrakan Ghozi',
        'A',
        3950000,
        today.add(const Duration(days: 5)),
        status: 'lunas',
        paidAt: today.subtract(const Duration(days: 1)),
      ),
    ];
  }

  late final List<Map<String, dynamic>> _rows;

  static Map<String, dynamic> _row(
    int id,
    String property,
    Object room,
    int amount,
    DateTime dueDate, {
    String status = 'belum_bayar',
    bool proof = false,
    DateTime? paidAt,
  }) {
    final now = DateTime.now();
    final period = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    final due =
        '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}';
    return {
      'id': id,
      'booking_id': id + 10,
      'periode': period,
      'jumlah': amount,
      'jatuh_tempo': due,
      'status': status,
      'tgl_lunas': paidAt == null
          ? null
          : '${paidAt.year}-${paidAt.month.toString().padLeft(2, '0')}-${paidAt.day.toString().padLeft(2, '0')}',
      'kos': property,
      'nomor_kamar': room,
      'bukti': proof
          ? {
              'url': '/tagihan/$id/bukti',
              'catatan_penolakan': null,
              'dibuat': now.toUtc().toIso8601String(),
            }
          : null,
    };
  }

  @override
  Future<List<Invoice>> getTagihan() async =>
      _rows.map(Invoice.fromJson).toList();

  @override
  Future<Invoice> getTagihanDetail(String id) async =>
      Invoice.fromJson(_rows.firstWhere((row) => '${row['id']}' == id));

  @override
  Future<void> uploadBukti(String id, Uint8List bytes, String fileName) async {
    final row = _rows.firstWhere((item) => '${item['id']}' == id);
    row['status'] = 'menunggu_verifikasi';
    row['bukti'] = {
      'url': '/tagihan/$id/bukti',
      'catatan_penolakan': null,
      'dibuat': DateTime.now().toUtc().toIso8601String(),
    };
  }

  @override
  Future<void> deleteBukti(String id) async {
    final row = _rows.firstWhere((item) => '${item['id']}' == id);
    row['status'] = 'belum_bayar';
    row['bukti'] = null;
  }

  @override
  Future<Uint8List> getBukti(String id) async => Uint8List.fromList([
    0x89,
    0x50,
    0x4e,
    0x47,
    0x0d,
    0x0a,
    0x1a,
    0x0a,
    0x00,
    0x00,
    0x00,
    0x0d,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x04,
    0x00,
    0x00,
    0x00,
    0xb5,
    0x1c,
    0x0c,
    0x02,
    0x00,
    0x00,
    0x00,
    0x0b,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0xda,
    0x63,
    0xfc,
    0xff,
    0x1f,
    0x00,
    0x03,
    0x03,
    0x02,
    0x00,
    0xef,
    0x9a,
    0xe6,
    0x2a,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4e,
    0x44,
    0xae,
    0x42,
    0x60,
    0x82,
  ]);
}
