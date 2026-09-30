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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.home_work_outlined,
                    size: 72,
                    color: colorScheme.outline,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(item.isMale ? 'PUTRA' : 'PUTRI'),
              ),
              const Spacer(),
              const Icon(Icons.star_rounded, color: Color(0xFFFBBF24)),
              const SizedBox(width: 4),
              Text(item.rating),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(child: Text(item.subtitle)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${item.price}/bln',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Divider(height: 32),
          Text('Tentang kos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(item.description),
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
