import 'dart:typed_data';

enum InvoiceStatus { unpaid, pending, paid, rejected }

class Invoice {
  Invoice({
    required this.id,
    required this.period,
    required this.property,
    required this.room,
    required this.amount,
    required this.dueDate,
    this.status = InvoiceStatus.unpaid,
    this.proofBytes,
    this.proofName,
    this.hasProof = false,
    this.proofUrl,
    this.submittedAt,
    this.paidAt,
    this.rejectionReason,
  });

  final String id;
  final String period;
  final String property;
  final String room;
  final int amount;
  final DateTime dueDate;
  InvoiceStatus status;
  Uint8List? proofBytes;
  String? proofName;
  bool hasProof;
  String? proofUrl;
  DateTime? submittedAt;
  DateTime? paidAt;
  String? rejectionReason;

  bool get isOverdue =>
      status == InvoiceStatus.unpaid && dueDate.isBefore(DateTime.now());

  bool get canManageProof =>
      status == InvoiceStatus.pending || status == InvoiceStatus.rejected;

  bool get canSubmitProof =>
      status == InvoiceStatus.unpaid ||
      status == InvoiceStatus.rejected ||
      isOverdue;

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final dueDate = DateTime.parse(json['jatuh_tempo'] as String);
    final periodDate = DateTime.parse(json['periode'] as String);
    final proof = json['bukti'] as Map<String, dynamic>?;
    final apiStatus = json['status'] as String;
    final status = switch (apiStatus) {
      'menunggu_verifikasi' => InvoiceStatus.pending,
      'lunas' => InvoiceStatus.paid,
      'ditolak' => InvoiceStatus.rejected,
      'belum_bayar' || 'terlambat' => InvoiceStatus.unpaid,
      _ => throw FormatException('Status tagihan tidak dikenal: $apiStatus'),
    };
    return Invoice(
      id: '${json['id']}',
      period: '${_monthNames[periodDate.month - 1]} ${periodDate.year}',
      property: json['kos'] as String,
      room: 'Kamar ${json['nomor_kamar']}',
      amount: (json['jumlah'] as num).toInt(),
      dueDate: dueDate,
      status: status,
      hasProof: proof != null,
      proofUrl: proof?['url'] as String?,
      submittedAt: proof?['dibuat'] == null
          ? null
          : DateTime.parse(proof!['dibuat'] as String),
      paidAt: json['tgl_lunas'] == null
          ? null
          : DateTime.parse(json['tgl_lunas'] as String),
      rejectionReason: proof?['catatan_penolakan'] as String?,
    );
  }
}

const _monthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];
