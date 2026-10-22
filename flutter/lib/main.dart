import 'package:flutter/material.dart';

import 'core/notifikasi_service.dart';
import 'features/komplain/komplain_detail_page.dart';
import 'features/komplain/komplain_notifier.dart';
import 'screens/home_screen.dart';

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
  KomplainNotifier().mulai();
  runApp(const SikosApp());
}

class SikosApp extends StatelessWidget {
  const SikosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Sikos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D9488)),
        scaffoldBackgroundColor: const Color(0xFFF7FBFB),
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
