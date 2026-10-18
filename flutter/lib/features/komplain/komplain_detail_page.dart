import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/config.dart';
import 'komplain_form_page.dart';
import 'komplain_model.dart';
import 'komplain_service.dart';
import 'komplain_widgets.dart';

// D3 (detail + linimasa), D4 (ubah/hapus saat "diterima"), D5 (konfirmasi + penilaian).
class KomplainDetailPage extends StatefulWidget {
  final int id;
  const KomplainDetailPage({super.key, required this.id});
  @override
  State<KomplainDetailPage> createState() => _KomplainDetailPageState();
}

class _KomplainDetailPageState extends State<KomplainDetailPage> {
  final _service = KomplainService();
  late Future<Komplain> _future;
  bool _berubah = false; // memberi tahu halaman daftar agar memuat ulang

  @override
  void initState() {
    super.initState();
    _future = _service.detail(widget.id);
  }

  void _muat() {
    setState(() {
      _future = _service.detail(widget.id);
    });
  }

  Future<void> _jalankan(Future<void> Function() aksi, {String? sukses}) async {
    try {
      await aksi();
      _berubah = true;
      if (!mounted) return;
      if (sukses != null) tampilkanPesan(context, sukses);
      _muat();
    } catch (e) {
      if (mounted) {
        tampilkanPesan(context, pesanError(e));
        _muat(); // status mungkin sudah berubah oleh pemilik
      }
    }
  }

  Future<void> _hapus() async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus komplain?'),
        content: const Text('Komplain dan fotonya akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ya != true) return;
    try {
      await _service.hapus(widget.id);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        tampilkanPesan(context, pesanError(e));
        _muat();
      }
    }
  }

  Future<void> _ubah(Komplain k) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => KomplainFormPage(awal: k)),
    );
    if (ok == true) {
      _berubah = true;
      _muat();
    }
  }

  Future<void> _nilai() async {
    int rating = 0;
    final komentar = TextEditingController();
    final kirim = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          title: const Text('Nilai penanganan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      onPressed: () => setS(() => rating = i),
                      icon: Icon(
                        i <= rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                ],
              ),
              TextField(
                controller: komentar,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Komentar (opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: rating == 0
                  ? null
                  : () => Navigator.pop(context, true),
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
    final teks = komentar.text;
    komentar.dispose();
    if (kirim == true) {
      await _jalankan(
        () => _service.beriPenilaian(widget.id, rating: rating, komentar: teks),
        sukses: 'Terima kasih atas penilaiannya',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _berubah);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Detail Komplain')),
        body: FutureBuilder<Komplain>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(pesanError(snap.error!)),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _muat,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              );
            }
            return _isi(snap.data!);
          },
        ),
      ),
    );
  }

  Widget _isi(Komplain k) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                judulKategori(k.kategori),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            StatusChip(k.status),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Diajukan ${formatWaktu(k.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Text(k.deskripsi),
        if (k.foto.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: k.foto.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    child: InteractiveViewer(
                      child: Image.network(AppConfig.fotoUrl(k.foto[i])),
                    ),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    AppConfig.fotoUrl(k.foto[i]),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: 120,
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text('Linimasa status', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final l in k.linimasa)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.circle, size: 14, color: warnaStatus(l.status)),
            title: Text(l.status),
            subtitle: Text(
              [
                if (l.catatan != null) l.catatan!,
                formatWaktu(l.waktu),
              ].join('\n'),
            ),
            isThreeLine: l.catatan != null,
          ),
        if (k.ratingPenanganan != null) ...[
          const Divider(height: 32),
          Text(
            'Penilaian Anda',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Icon(
                  i <= k.ratingPenanganan! ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
            ],
          ),
          if (k.komentarPenanganan != null) Text(k.komentarPenanganan!),
        ],
        const SizedBox(height: 24),
        if (k.bisaDiubah)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _ubah(k),
                  icon: const Icon(Icons.edit),
                  label: const Text('Ubah'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _hapus,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus'),
                ),
              ),
            ],
          ),
        if (k.bisaDikonfirmasi)
          FilledButton.icon(
            onPressed: () => _jalankan(
              () => _service.konfirmasi(k.id),
              sukses: 'Komplain dikonfirmasi selesai',
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Konfirmasi selesai'),
          ),
        if (k.bisaDinilai)
          FilledButton.icon(
            onPressed: _nilai,
            icon: const Icon(Icons.star_outline),
            label: const Text('Beri penilaian penanganan'),
          ),
      ],
    );
  }
}
