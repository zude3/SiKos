import 'package:flutter/material.dart';

import 'core/notifikasi_service.dart';
import 'features/komplain/komplain_detail_page.dart';
import 'features/komplain/komplain_list_page.dart';
import 'features/komplain/komplain_notifier.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotifikasiService.instance.onTap = (payload) {
    final id = int.tryParse(payload ?? '');
    if (id == null) return;
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => KomplainDetailPage(id: id)),
    );
  };
  await NotifikasiService.instance.init();
  await NotifikasiService.instance.tampilkan(
    id: 0,
    judul: 'Tes notifikasi',
    isi: 'Kalau ini muncul, notifikasi berfungsi.',
  );
  KomplainNotifier().mulai(interval: const Duration(seconds: 2));
  runApp(const _DemoApp());
}

class _DemoApp extends StatelessWidget {
  const _DemoApp();
  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: navigatorKey,
    title: 'SiKos - Komplain',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
    home: const KomplainListPage(),
  );
}
