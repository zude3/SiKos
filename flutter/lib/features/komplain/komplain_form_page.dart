import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api_client.dart';
import '../../core/config.dart';
import 'komplain_model.dart';
import 'komplain_service.dart';
import 'komplain_widgets.dart';

// D1 (buat, foto dari kamera/galeri maks 3) dan D4 (ubah, bila [awal] diisi).
class KomplainFormPage extends StatefulWidget {
  final Komplain? awal;
  const KomplainFormPage({super.key, this.awal});
  @override
  State<KomplainFormPage> createState() => _KomplainFormPageState();
}

class _KomplainFormPageState extends State<KomplainFormPage> {
  static const _maksFoto = 3;
  final _service = KomplainService();
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _deskripsi;
  String? _kategori;
  final List<XFile> _foto = [];
  bool _kirim = false;

  bool get _mengubah => widget.awal != null;

  @override
  void initState() {
    super.initState();
    _deskripsi = TextEditingController(text: widget.awal?.deskripsi ?? '');
    _kategori = widget.awal?.kategori;
  }

  @override
  void dispose() {
    _deskripsi.dispose();
    super.dispose();
  }

  Future<void> _ambil(ImageSource sumber) async {
    try {
      if (sumber == ImageSource.camera) {
        final f = await _picker.pickImage(source: sumber, imageQuality: 80, maxWidth: 1600);
        if (f != null) setState(() => _foto.add(f));
      } else {
        final list = await _picker.pickMultiImage(imageQuality: 80, maxWidth: 1600);
        final sisa = _maksFoto - _foto.length;
        setState(() => _foto.addAll(list.take(sisa)));
        if (list.length > sisa && mounted) {
          tampilkanPesan(context, 'Maksimal $_maksFoto foto');
        }
      }
    } catch (e) {
      if (mounted) tampilkanPesan(context, 'Tidak bisa mengambil foto: $e');
    }
  }

  void _pilihSumber() {
    if (_foto.length >= _maksFoto) {
      tampilkanPesan(context, 'Maksimal $_maksFoto foto');
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Kamera'),
            onTap: () {
              Navigator.pop(context);
              _ambil(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galeri'),
            onTap: () {
              Navigator.pop(context);
              _ambil(ImageSource.gallery);
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _kirim = true);
    try {
      if (_mengubah) {
        await _service.ubah(widget.awal!.id,
            kategori: _kategori!, deskripsi: _deskripsi.text.trim());
      } else {
        await _service.buat(
          bookingId: AppConfig.bookingIdSementara,
          kategori: _kategori!,
          deskripsi: _deskripsi.text.trim(),
          pathFoto: _foto.map((f) => f.path).toList(),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _kirim = false);
        tampilkanPesan(context, pesanError(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_mengubah ? 'Ubah Komplain' : 'Ajukan Komplain')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          DropdownButtonFormField<String>(
            initialValue: _kategori,
            decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
            items: [
              for (final k in kategoriKomplain)
                DropdownMenuItem(value: k, child: Text(judulKategori(k))),
            ],
            onChanged: (v) => setState(() => _kategori = v),
            validator: (v) => v == null ? 'Pilih kategori' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _deskripsi,
            maxLines: 5,
            maxLength: 1000,
            decoration: const InputDecoration(labelText: 'Deskripsi masalah', border: OutlineInputBorder()),
            validator: (v) {
              final t = (v ?? '').trim();
              if (t.length < 10) return 'Deskripsi minimal 10 karakter';
              return null;
            },
          ),
          if (!_mengubah) ...[
            const SizedBox(height: 8),
            Text('Foto (opsional, maks $_maksFoto)', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (var i = 0; i < _foto.length; i++)
                Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(_foto[i].path), width: 96, height: 96, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: InkWell(
                      onTap: () => setState(() => _foto.removeAt(i)),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ]),
              if (_foto.length < _maksFoto)
                InkWell(
                  onTap: _pilihSumber,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_a_photo_outlined),
                  ),
                ),
            ]),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _kirim ? null : _simpan,
            child: _kirim
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_mengubah ? 'Simpan perubahan' : 'Kirim komplain'),
          ),
        ]),
      ),
    );
  }
}
