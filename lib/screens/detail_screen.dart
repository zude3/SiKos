import 'package:flutter/material.dart';
import '../models/item.dart';
import '../routes/app_routes.dart';

const _ink = Color(0xFF1E293B);
const _muted = Color(0xFF64748B);
const _teal = Color(0xFF0D9488);

class DetailScreen extends StatefulWidget {
  // (1) data yang DITERIMA dari Home
  final Item item;

  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // (2) menyimpan catatan yang dikirim balik dari form
  String? _catatan;

  // (3) buka form, TUNGGU hasilnya, lalu tampilkan
  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );
    if (!mounted || hasil == null) return; // null = pengguna batal

    setState(() => _catatan = hasil);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Di dalam State, data widget dibaca dengan "widget.item"
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              item.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 200,
                color: const Color(0xFFE2E8F0),
                child: const Icon(Icons.home_work_outlined, color: _muted, size: 48),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            style: const TextStyle(color: _ink, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: _muted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(item.subtitle, style: const TextStyle(color: _muted, fontSize: 13)),
              ),
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFBBF24)),
              const SizedBox(width: 2),
              Text(
                item.rating,
                style: const TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              text: item.price,
              style: const TextStyle(color: _teal, fontSize: 20, fontWeight: FontWeight.w700),
              children: const [
                TextSpan(text: '/bln', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          if (item.availability.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.availability,
              style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 16),
          Text(item.description),
          const Divider(height: 32),
          Text(
            _catatan == null ? 'Belum ada catatan.' : 'Catatan: $_catatan',
          ),
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