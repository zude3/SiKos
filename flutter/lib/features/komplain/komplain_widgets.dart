import 'package:flutter/material.dart';

Color warnaStatus(String s) => switch (s) {
  'diterima' => Colors.orange,
  'diproses' => Colors.blue,
  'selesai' => Colors.green,
  _ => Colors.grey,
};

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = warnaStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: c, fontWeight: FontWeight.w600),
      ),
    );
  }
}

String judulKategori(String k) => k[0].toUpperCase() + k.substring(1);

String formatWaktu(DateTime? t) {
  if (t == null) return '-';
  String d(int n) => n.toString().padLeft(2, '0');
  return '${d(t.day)}/${d(t.month)}/${t.year} ${d(t.hour)}:${d(t.minute)}';
}

void tampilkanPesan(BuildContext context, String pesan) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(pesan)));
}
