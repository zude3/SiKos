import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/config.dart';
import 'komplain_detail_page.dart';
import 'komplain_form_page.dart';
import 'komplain_model.dart';
import 'komplain_service.dart';
import 'komplain_widgets.dart';

// D2: daftar komplain + filter status
class KomplainListPage extends StatefulWidget {
  const KomplainListPage({super.key});
  @override
  State<KomplainListPage> createState() => _KomplainListPageState();
}

class _KomplainListPageState extends State<KomplainListPage> {
  final _service = KomplainService();
  String? _filter; // null = semua
  late Future<List<Komplain>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.daftar();
  }

  void _muat() {
    setState(() {
      _future = _service.daftar(status: _filter);
    });
  }

  Future<void> _buka(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) _muat(); // selalu muat ulang saat kembali
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Komplain & Maintenance')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _buka(const KomplainFormPage()),
        icon: const Icon(Icons.add),
        label: const Text('Ajukan'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final s in <String?>[null, ...statusKomplain])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(s ?? 'Semua'),
                      selected: _filter == s,
                      onSelected: (_) {
                        _filter = s;
                        _muat();
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _muat();
                await _future;
              },
              child: FutureBuilder<List<Komplain>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Text(
                                pesanError(snap.error!),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: _muat,
                                child: const Text('Coba lagi'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  final data = snap.data!;
                  if (data.isEmpty) {
                    return ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(48),
                          child: Center(child: Text('Belum ada komplain')),
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) => _Item(
                      data[i],
                      onTap: () => _buka(KomplainDetailPage(id: data[i].id)),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final Komplain k;
  final VoidCallback onTap;
  const _Item(this.k, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 56,
          height: 56,
          child: k.fotoUtama == null
              ? Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.build_outlined),
                )
              : Image.network(
                  AppConfig.fotoUrl(k.fotoUtama!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image_outlined),
                ),
        ),
      ),
      title: Text(judulKategori(k.kategori)),
      subtitle: Text(k.deskripsi, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          StatusChip(k.status),
          const SizedBox(height: 4),
          Text(
            formatWaktu(k.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
