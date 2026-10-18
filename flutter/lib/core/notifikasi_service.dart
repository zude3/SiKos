import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Pembungkus flutter_local_notifications. Dipakai semua modul (bagian fondasi).
class NotifikasiService {
  NotifikasiService._();
  static final NotifikasiService instance = NotifikasiService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  // Dipanggil saat notifikasi diketuk; isinya payload yang dikirim saat tampilkan().
  void Function(String? payload)? onTap;

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (r) => onTap?.call(r.payload),
    );
    // Android 13+ butuh izin notifikasi dari pengguna.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> tampilkan({
    required int id,
    required String judul,
    required String isi,
    String? payload,
  }) {
    return _plugin.show(
      id: id,
      title: judul,
      body: isi,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'status_komplain',
          'Status komplain',
          channelDescription: 'Pemberitahuan perubahan status komplain',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: payload,
    );
  }
}