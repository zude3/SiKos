import 'package:flutter/material.dart';

import '../models/item.dart';
import '../routes/app_routes.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.item});

  final Item item;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? _catatan;

  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );
    if (!mounted || hasil == null) return;
    setState(() => _catatan = hasil);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Catatan berhasil disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 220,
                color: const Color(0xFFE2E8F0),
                alignment: Alignment.center,
                child: const Icon(Icons.home_work_outlined, size: 48),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(item.subtitle),
          const SizedBox(height: 16),
          Text(item.description),
          const SizedBox(height: 12),
          Text('${item.price}/bln'),
          const Divider(height: 32),
          Text(_catatan == null ? 'Belum ada catatan.' : 'Catatan: $_catatan'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _bukaFormCatatan,
            icon: const Icon(Icons.edit_note),
            label: const Text('Tulis Catatan'),
          ),
        ],
      ),
    );
  }
}
