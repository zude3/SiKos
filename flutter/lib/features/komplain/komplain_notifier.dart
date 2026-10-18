import 'dart:async';

import '../../core/notifikasi_service.dart';
import 'komplain_service.dart';
import 'komplain_widgets.dart';

import 'package:flutter/foundation.dart';

// Polling status komplain (NFR-06: perubahan terdeteksi <= 1 menit saat aplikasi terbuka).
class KomplainNotifier {
  final _service = KomplainService();
  Timer? _timer;
  Map<int, String>?
  _terakhir; // id komplain -> status pada pengecekan sebelumnya
  bool _sedangCek = false;

  void mulai({Duration interval = const Duration(seconds: 30)}) {
    if (_timer != null) return;
    _cek();
    _timer = Timer.periodic(interval, (_) => _cek());
  }

  void berhenti() {
    _timer?.cancel();
    _timer = null;
    _terakhir = null;
  }

  Future<void> _cek() async {
    if (_sedangCek) return;
    _sedangCek = true;
    try {
      final daftar = await _service.daftar();
      final lama = _terakhir;
      debugPrint(
        '[notifier] cek: ${daftar.length} komplain, baseline=${lama != null}',
      );
      if (lama != null) {
        for (final k in daftar) {
          final sebelum = lama[k.id];
          final berubah = sebelum == null
              ? k.status !=
                    'diterima' // komplain baru yang sudah maju
              : sebelum != k.status;
          if (!berubah) continue;
          debugPrint('[notifier] ${k.id}: $sebelum -> ${k.status}');
          final nama = judulKategori(k.kategori);
          final isi = switch (k.status) {
            'diproses' => 'Komplain $nama sedang ditangani pemilik kos.',
            'selesai' =>
              'Komplain $nama selesai. Mohon konfirmasi dan beri penilaian.',
            _ => 'Status komplain $nama berubah menjadi ${k.status}.',
          };
          await NotifikasiService.instance.tampilkan(
            id: k.id,
            judul: 'Status komplain diperbarui',
            isi: isi,
            payload: k.id.toString(),
          );
        }
      }
      _terakhir = {for (final k in daftar) k.id: k.status};
    } catch (e) {
      debugPrint('[notifier] gagal: $e');
    } finally {
      _sedangCek = false;
    }
  }
}
