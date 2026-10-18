const kategoriKomplain = ['listrik', 'air', 'furnitur', 'kebersihan', 'lainnya'];
const statusKomplain = ['diterima', 'diproses', 'selesai'];

bool _bool(dynamic v) => v == true || v == 1 || v == '1';
DateTime? _waktu(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

class LogStatus {
  final String status;
  final String? catatan;
  final DateTime? waktu;
  LogStatus({required this.status, this.catatan, this.waktu});

  factory LogStatus.fromJson(Map<String, dynamic> j) => LogStatus(
        status: j['status'] as String,
        catatan: j['catatan'] as String?,
        waktu: _waktu(j['created_at']),
      );
}

class Komplain {
  final int id;
  final int bookingId;
  final String kategori;
  final String deskripsi;
  final String status;
  final bool dikonfirmasi;
  final int? ratingPenanganan;
  final String? komentarPenanganan;
  final DateTime? createdAt;
  final String? fotoUtama; // hanya di daftar
  final int jumlahFoto; // hanya di daftar
  final List<String> foto; // hanya di detail
  final List<LogStatus> linimasa; // hanya di detail

  Komplain({
    required this.id,
    required this.bookingId,
    required this.kategori,
    required this.deskripsi,
    required this.status,
    required this.dikonfirmasi,
    this.ratingPenanganan,
    this.komentarPenanganan,
    this.createdAt,
    this.fotoUtama,
    this.jumlahFoto = 0,
    this.foto = const [],
    this.linimasa = const [],
  });

  bool get bisaDiubah => status == 'diterima';
  bool get bisaDikonfirmasi => status == 'selesai' && !dikonfirmasi;
  bool get bisaDinilai => dikonfirmasi && ratingPenanganan == null;

  factory Komplain.fromJson(Map<String, dynamic> j) => Komplain(
        id: j['id'] as int,
        bookingId: j['booking_id'] as int,
        kategori: j['kategori'] as String,
        deskripsi: j['deskripsi'] as String,
        status: j['status'] as String,
        dikonfirmasi: _bool(j['dikonfirmasi']),
        ratingPenanganan: j['rating_penanganan'] as int?,
        komentarPenanganan: j['komentar_penanganan'] as String?,
        createdAt: _waktu(j['created_at']),
        fotoUtama: j['foto_utama'] as String?,
        jumlahFoto: (j['jumlah_foto'] as num?)?.toInt() ?? 0,
        foto: ((j['foto'] as List?) ?? []).map((e) => e.toString()).toList(),
        linimasa: ((j['linimasa'] as List?) ?? [])
            .map((e) => LogStatus.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
