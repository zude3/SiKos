import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/invoice.dart';
import '../services/api_client.dart';
import '../services/tagihan_service.dart';
import '../widgets/state_views.dart';

const _ink = Color(0xFF1E293B);
const _muted = Color(0xFF64748B);
const _line = Color(0xFFE2E8F0);
const _teal = Color(0xFF0D9488);
const _canvas = Color(0xFFF7FBFB);

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key, this.tagihanService});

  final TagihanService? tagihanService;

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  TagihanService? get _tagihanService => widget.tagihanService;
  List<Invoice> _invoices = [];
  final List<_PaymentNotice> _notices = [];
  String _filter = 'Semua';
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (_tagihanService == null) {
      _invoices = _sampleInvoices();
      _loading = false;
    } else {
      _reloadInvoices();
    }
  }

  Future<void> _reloadInvoices() async {
    if (_tagihanService == null) return;
    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final invoices = await _tagihanService!.getTagihan();
      if (!mounted) return;
      setState(() => _invoices = invoices);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = ApiClient.exceptionFrom(error).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Invoice> get _visibleInvoices {
    final invoices = [..._invoices]
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return invoices.where((invoice) {
      switch (_filter) {
        case 'Belum bayar':
          return invoice.status == InvoiceStatus.unpaid ||
              invoice.status == InvoiceStatus.rejected;
        case 'Menunggu':
          return invoice.status == InvoiceStatus.pending;
        case 'Lunas':
          return invoice.status == InvoiceStatus.paid;
        case 'Terlambat':
          return invoice.isOverdue;
        default:
          return true;
      }
    }).toList();
  }

  int get _outstandingAmount => _invoices
      .where((invoice) => invoice.status != InvoiceStatus.paid)
      .fold(0, (total, invoice) => total + invoice.amount);

  Future<void> _openInvoice(Invoice invoice) async {
    try {
      final detail = _tagihanService == null
          ? invoice
          : await _tagihanService!.getTagihanDetail(invoice.id);
      if (_tagihanService != null && detail.hasProof) {
        detail.proofBytes = await _tagihanService!.getBukti(detail.id);
      }
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => _InvoiceDetailScreen(
            invoice: detail,
            onUpload: (updatedInvoice) => _openUpload(updatedInvoice),
            onDeleteProof: () => _deleteProof(detail),
          ),
        ),
      );
      await _reloadInvoices();
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _openUpload(Invoice invoice) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _ProofUploadScreen(
          invoice: invoice,
          onSubmit: (bytes, fileName) async {
            if (_tagihanService == null) {
              invoice
                ..proofBytes = bytes
                ..proofName = fileName
                ..hasProof = true
                ..submittedAt = DateTime.now()
                ..rejectionReason = null
                ..status = InvoiceStatus.pending;
            } else {
              await _tagihanService!.uploadBukti(invoice.id, bytes, fileName);
            }
          },
        ),
      ),
    );
    if (changed == true && mounted) {
      await _reloadInvoices();
      if (!mounted) return;
      if (_tagihanService != null) {
        try {
          final updatedInvoice = await _tagihanService!.getTagihanDetail(
            invoice.id,
          );
          if (updatedInvoice.hasProof) {
            updatedInvoice.proofBytes = await _tagihanService!.getBukti(
              invoice.id,
            );
          }
          invoice
            ..status = updatedInvoice.status
            ..hasProof = updatedInvoice.hasProof
            ..proofUrl = updatedInvoice.proofUrl
            ..proofBytes = updatedInvoice.proofBytes
            ..submittedAt = updatedInvoice.submittedAt
            ..rejectionReason = updatedInvoice.rejectionReason;
        } catch (error) {
          _showError(error);
        }
      }
      if (!mounted) return;
      setState(() {
        _notices.insert(
          0,
          _PaymentNotice(
            title: 'Bukti pembayaran dikirim',
            message: '${invoice.period} menunggu verifikasi pemilik.',
            time: DateTime.now(),
          ),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bukti berhasil dikirim untuk verifikasi.'),
        ),
      );
    }
  }

  Future<bool> _deleteProof(Invoice invoice) async {
    try {
      if (_tagihanService == null) {
        invoice
          ..proofBytes = null
          ..proofName = null
          ..hasProof = false
          ..proofUrl = null
          ..submittedAt = null
          ..status = invoice.rejectionReason == null
              ? InvoiceStatus.unpaid
              : InvoiceStatus.rejected;
      } else {
        await _tagihanService!.deleteBukti(invoice.id);
      }
      await _reloadInvoices();
      if (mounted) setState(() {});
      return true;
    } catch (error) {
      _showError(error);
      return false;
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ApiClient.exceptionFrom(error).message)),
    );
  }

  void _openHistory() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _PaymentHistoryScreen(
          invoices: _invoices,
          onOpenInvoice: _openInvoice,
        ),
      ),
    );
  }

  void _openNotices() {
    final reminders = _invoices
        .where((invoice) {
          final unpaid =
              invoice.status == InvoiceStatus.unpaid ||
              invoice.status == InvoiceStatus.rejected;
          return unpaid &&
              invoice.dueDate.difference(DateTime.now()).inDays <= 3;
        })
        .map((invoice) {
          final overdue = invoice.dueDate.isBefore(DateTime.now());
          return _PaymentNotice(
            title: overdue ? 'Tagihan terlambat' : 'Pengingat jatuh tempo',
            message: overdue
                ? 'Tagihan ${invoice.property} (${invoice.period}) telah melewati jatuh tempo ${_formatDate(invoice.dueDate)}.'
                : 'Tagihan ${invoice.property} (${invoice.period}) jatuh tempo ${_formatDate(invoice.dueDate)}.',
            time: DateTime.now(),
          );
        });
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            _NotificationsScreen(notices: [..._notices, ...reminders]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: _loading
            ? const LoadingView()
            : _errorMessage != null
            ? ErrorView(
                message: _errorMessage!,
                onRetry: () {
                  _reloadInvoices();
                },
              )
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: _ScreenHeader(
                        title: 'Tagihan',
                        onBack: () => Navigator.of(context).maybePop(),
                        onNotifications: _openNotices,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _OutstandingCard(
                        amount: _outstandingAmount,
                        onHistory: _openHistory,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Daftar tagihan',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _StatusFilters(
                      selected: _filter,
                      onSelected: (filter) => setState(() => _filter = filter),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    sliver: _visibleInvoices.isEmpty
                        ? SliverFillRemaining(
                            hasScrollBody: false,
                            child: EmptyView(
                              message: _invoices.isEmpty
                                  ? 'Belum ada tagihan untuk ditampilkan.'
                                  : 'Tidak ada tagihan pada filter ini.',
                            ),
                          )
                        : SliverList.separated(
                            itemCount: _visibleInvoices.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) => _InvoiceCard(
                              invoice: _visibleInvoices[index],
                              onTap: () =>
                                  _openInvoice(_visibleInvoices[index]),
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({
    required this.title,
    required this.onBack,
    required this.onNotifications,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
        ),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: onNotifications,
          tooltip: 'Notifikasi',
          icon: const Icon(Icons.notifications_none_rounded, color: _ink),
        ),
      ],
    );
  }
}

class _OutstandingCard extends StatelessWidget {
  const _OutstandingCard({required this.amount, required this.onHistory});

  final int amount;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF0EA5A0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260D9488),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Total tagihan belum lunas',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              IconButton(
                onPressed: onHistory,
                tooltip: 'Riwayat pembayaran',
                icon: const Icon(Icons.history_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih tagihan untuk melihat rincian dan pembayaran.',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const filters = ['Semua', 'Belum bayar', 'Menunggu', 'Lunas', 'Terlambat'];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < filters.length; index++) ...[
            if (index > 0) const SizedBox(width: 8),
            ChoiceChip(
              label: Text(filters[index]),
              selected: selected == filters[index],
              onSelected: (_) => onSelected(filters[index]),
              selectedColor: _teal,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected == filters[index] ? _teal : _line,
              ),
              labelStyle: TextStyle(
                color: selected == filters[index] ? Colors.white : _muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 5),
            ),
          ],
        ],
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice, required this.onTap});

  final Invoice invoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _statusPresentation(invoice);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F7F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.home_work_outlined, color: _teal),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.property,
                          style: const TextStyle(
                            color: _ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${invoice.room}  •  ${invoice.period}',
                          style: const TextStyle(color: _muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(label: status.label, color: status.color),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Divider(height: 1, color: _line),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total tagihan',
                          style: TextStyle(color: _muted, fontSize: 10),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _formatCurrency(invoice.amount),
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Jatuh tempo',
                        style: TextStyle(color: _muted, fontSize: 10),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatDate(invoice.dueDate),
                        style: TextStyle(
                          color: invoice.isOverdue
                              ? const Color(0xFFDC2626)
                              : _ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 7),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
              if (invoice.rejectionReason != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Alasan ditolak: ${invoice.rejectionReason}',
                  style: const TextStyle(
                    color: Color(0xFFB91C1C),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InvoiceDetailScreen extends StatefulWidget {
  const _InvoiceDetailScreen({
    required this.invoice,
    required this.onUpload,
    required this.onDeleteProof,
  });

  final Invoice invoice;
  final Future<void> Function(Invoice) onUpload;
  final Future<bool> Function() onDeleteProof;

  @override
  State<_InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<_InvoiceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final status = _statusPresentation(invoice);
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        title: const Text('Detail tagihan'),
        leading: const BackButton(),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _line),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Periode tagihan',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ),
                    _StatusBadge(label: status.label, color: status.color),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  invoice.period,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Total tagihan',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(invoice.amount),
                  style: const TextStyle(
                    color: _teal,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Divider(height: 28, color: _line),
                _DetailRow(label: 'Nama kos', value: invoice.property),
                _DetailRow(label: 'Kamar', value: invoice.room),
                _DetailRow(
                  label: 'Jatuh tempo',
                  value: _formatDate(invoice.dueDate),
                ),
                _DetailRow(label: 'Nomor tagihan', value: invoice.id),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (invoice.rejectionReason != null)
            _InfoCard(
              icon: Icons.error_outline_rounded,
              title: 'Bukti perlu diperbaiki',
              message: invoice.rejectionReason!,
              color: const Color(0xFFFEF2F2),
              foreground: const Color(0xFFB91C1C),
            ),
          if (invoice.hasProof) ...[
            const SizedBox(height: 14),
            _ProofPreview(invoice: invoice),
          ],
          if (invoice.status == InvoiceStatus.pending) ...[
            const SizedBox(height: 8),
            const Text(
              'Bukti masih menunggu verifikasi. Kamu masih bisa mengganti atau menghapusnya.',
              style: TextStyle(color: _muted, fontSize: 12),
            ),
          ],
          if (invoice.status == InvoiceStatus.paid && invoice.paidAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _InfoCard(
                icon: Icons.check_circle_outline_rounded,
                title: 'Pembayaran lunas',
                message: 'Diverifikasi pada ${_formatDate(invoice.paidAt!)}.',
                color: const Color(0xFFECFDF5),
                foreground: const Color(0xFF047857),
              ),
            ),
          const SizedBox(height: 20),
          if (invoice.canSubmitProof || invoice.status == InvoiceStatus.pending)
            FilledButton.icon(
              onPressed: () async {
                await widget.onUpload(invoice);
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(
                invoice.status == InvoiceStatus.pending
                    ? 'Ganti bukti pembayaran'
                    : invoice.rejectionReason == null && !invoice.hasProof
                    ? 'Unggah bukti pembayaran'
                    : 'Unggah ulang bukti',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _teal,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          if (invoice.canManageProof && invoice.hasProof) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _confirmDelete(context),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Hapus bukti pembayaran'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
          if (invoice.status == InvoiceStatus.pending)
            const _InfoCard(
              icon: Icons.hourglass_top_rounded,
              title: 'Menunggu verifikasi',
              message: 'Pemilik kos akan memeriksa bukti pembayaran yang kamu kirim.',
              color: Color(0xFFFFFBEB),
              foreground: Color(0xFFB45309),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus bukti pembayaran?'),
        content: const Text(
          'Bukti hanya dapat dihapus sebelum diverifikasi oleh pemilik.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: _teal),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final deleted = await widget.onDeleteProof();
      if (deleted && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}

class _ProofUploadScreen extends StatefulWidget {
  const _ProofUploadScreen({required this.invoice, required this.onSubmit});

  final Invoice invoice;
  final Future<void> Function(Uint8List bytes, String fileName) onSubmit;

  @override
  State<_ProofUploadScreen> createState() => _ProofUploadScreenState();
}

class _ProofUploadScreenState extends State<_ProofUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  String? _fileName;
  bool _isPicking = false;
  bool _isSubmitting = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isPicking = true);
    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1800,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _fileName = image.name;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $error')));
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _imageBytes = widget.invoice.proofBytes;
    _fileName = widget.invoice.proofName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        title: Text(
          !widget.invoice.hasProof ? 'Unggah bukti' : 'Ganti bukti pembayaran',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        children: [
          _InfoCard(
            icon: Icons.receipt_long_outlined,
            title: '${widget.invoice.property} • ${widget.invoice.period}',
            message:
                'Total yang harus dibayar ${_formatCurrency(widget.invoice.amount)}',
            color: const Color(0xFFE6F7F5),
            foreground: _teal,
          ),
          const SizedBox(height: 22),
          const Text(
            'Pilih sumber bukti pembayaran',
            style: TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SourceButton(
                  icon: Icons.photo_camera_outlined,
                  title: 'Kamera',
                  onTap: _isPicking
                      ? null
                      : () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SourceButton(
                  icon: Icons.photo_library_outlined,
                  title: 'Galeri',
                  onTap: _isPicking
                      ? null
                      : () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Pratinjau bukti',
            style: TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 260,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _line),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: _isPicking
                ? const CircularProgressIndicator(color: _teal)
                : _imageBytes == null
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 45,
                        color: Color(0xFF94A3B8),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Foto bukti pembayaran akan tampil di sini',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  )
                : Image.memory(
                    _imageBytes!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
          ),
          if (_fileName != null) ...[
            const SizedBox(height: 7),
            Text(
              _fileName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _muted, fontSize: 11),
            ),
          ],
          const SizedBox(height: 18),
          const _InfoCard(
            icon: Icons.info_outline_rounded,
            title: 'Pastikan bukti terlihat jelas',
            message: 'Nama penerima, nominal, dan waktu transaksi perlu terbaca agar pemilik dapat memverifikasi.',
            color: Color(0xFFEFF6FF),
            foreground: Color(0xFF1D4ED8),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _imageBytes == null || _isPicking || _isSubmitting
                ? null
                : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: _teal,
              minimumSize: const Size.fromHeight(50),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Kirim untuk verifikasi'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final bytes = _imageBytes;
    if (bytes == null) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(bytes, _fileName ?? 'bukti-pembayaran.jpg');
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiClient.exceptionFrom(error).message)),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _PaymentHistoryScreen extends StatefulWidget {
  const _PaymentHistoryScreen({
    required this.invoices,
    required this.onOpenInvoice,
  });

  final List<Invoice> invoices;
  final ValueChanged<Invoice> onOpenInvoice;

  @override
  State<_PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<_PaymentHistoryScreen> {
  int? _year;

  @override
  Widget build(BuildContext context) {
    final paidInvoices =
        widget.invoices
            .where(
              (invoice) =>
                  invoice.status == InvoiceStatus.paid &&
                  (_year == null ||
                      invoice.paidAt?.year == _year ||
                      invoice.dueDate.year == _year),
            )
            .toList()
          ..sort(
            (a, b) => (b.paidAt ?? b.dueDate).compareTo(a.paidAt ?? a.dueDate),
          );
    final total = paidInvoices.fold<int>(
      0,
      (sum, invoice) => sum + invoice.amount,
    );
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        title: const Text('Riwayat pembayaran'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _line),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total pembayaran lunas',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(total),
                  style: const TextStyle(
                    color: _teal,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${paidInvoices.length} pembayaran terverifikasi',
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              _HistoryYearChip(
                label: 'Semua',
                selected: _year == null,
                onTap: () => setState(() => _year = null),
              ),
              for (final year in _availableYears(widget.invoices))
                _HistoryYearChip(
                  label: '$year',
                  selected: _year == year,
                  onTap: () => setState(() => _year = year),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (paidInvoices.isEmpty)
            const _InfoCard(
              icon: Icons.history_rounded,
              title: 'Belum ada riwayat',
              message: 'Tagihan yang sudah lunas akan tersimpan di sini.',
              color: Color(0xFFEFF6FF),
              foreground: Color(0xFF1D4ED8),
            )
          else
            ...paidInvoices.map(
              (invoice) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _HistoryCard(
                  invoice: invoice,
                  onTap: () => widget.onOpenInvoice(invoice),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryYearChip extends StatelessWidget {
  const _HistoryYearChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: _teal,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : _muted,
        fontSize: 11,
      ),
      showCheckmark: false,
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.invoice, required this.onTap});

  final Invoice invoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFECFDF5),
                child: Icon(Icons.check_rounded, color: Color(0xFF047857)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.property,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${invoice.period} · Lunas ${_formatDate(invoice.paidAt ?? invoice.dueDate)}',
                      style: const TextStyle(color: _muted, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(invoice.amount),
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_outward_rounded,
                color: Color(0xFF94A3B8),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentNotice {
  const _PaymentNotice({
    required this.title,
    required this.message,
    required this.time,
  });

  final String title;
  final String message;
  final DateTime time;
}

class _NotificationsScreen extends StatelessWidget {
  const _NotificationsScreen({required this.notices});

  final List<_PaymentNotice> notices;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        title: const Text('Notifikasi pembayaran'),
      ),
      body: notices.isEmpty
          ? const _EmptyInvoices(
              title: 'Belum ada notifikasi',
              message: 'Pengingat dan hasil verifikasi akan muncul di sini.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notices.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notice = notices[index];
                return _InfoCard(
                  icon: notice.title.contains('Pengingat')
                      ? Icons.notifications_active_outlined
                      : Icons.mark_email_read_outlined,
                  title: notice.title,
                  message: '${notice.message}\n${_formatDate(notice.time)}',
                  color: const Color(0xFFEFF6FF),
                  foreground: const Color(0xFF1D4ED8),
                );
              },
            ),
    );
  }
}

class _ProofPreview extends StatelessWidget {
  const _ProofPreview({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bukti pembayaran',
            style: TextStyle(
              color: _ink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (invoice.proofBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                invoice.proofBytes!,
                height: 210,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          if (invoice.proofName != null) ...[
            const SizedBox(height: 7),
            Text(
              invoice.proofName!,
              style: const TextStyle(color: _muted, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _muted, fontSize: 12),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _ink,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    required this.foreground,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: foreground.withValues(alpha: .9),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: _teal,
        backgroundColor: Colors.white,
        side: const BorderSide(color: _line),
        padding: const EdgeInsets.symmetric(vertical: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 7),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyInvoices extends StatelessWidget {
  const _EmptyInvoices({
    this.title = 'Tagihan tidak ditemukan',
    this.message = 'Belum ada tagihan dengan status ini.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xFF94A3B8),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: _ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

({String label, Color color}) _statusPresentation(Invoice invoice) {
  if (invoice.isOverdue) {
    return (label: 'Terlambat', color: const Color(0xFFDC2626));
  }
  return switch (invoice.status) {
    InvoiceStatus.unpaid => (
      label: 'Belum bayar',
      color: const Color(0xFFB45309),
    ),
    InvoiceStatus.pending => (
      label: 'Menunggu verifikasi',
      color: const Color(0xFFB45309),
    ),
    InvoiceStatus.paid => (label: 'Lunas', color: const Color(0xFF047857)),
    InvoiceStatus.rejected => (
      label: 'Ditolak',
      color: const Color(0xFFB91C1C),
    ),
  };
}

String _formatCurrency(int amount) {
  final digits = amount.toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
  return 'Rp $grouped';
}

String _formatDate(DateTime date) =>
    '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

List<int> _availableYears(List<Invoice> invoices) {
  final years =
      invoices
          .where((invoice) => invoice.status == InvoiceStatus.paid)
          .map((invoice) => invoice.paidAt?.year ?? invoice.dueDate.year)
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));
  return years;
}

List<Invoice> _sampleInvoices() {
  final today = DateTime.now();
  return [
    Invoice(
      id: 'demo-1',
      period: '${_monthNames[today.month - 1]} ${today.year}',
      property: 'Kost Nopal',
      room: 'Kamar 203',
      amount: 850000,
      dueDate: DateTime(today.year, today.month, today.day + 2),
    ),
    Invoice(
      id: 'demo-2',
      period: '${_monthNames[today.month - 1]} ${today.year}',
      property: 'Griya Anggrek Executive',
      room: 'Kamar 12',
      amount: 1200000,
      dueDate: DateTime(today.year, today.month, today.day + 2),
      status: InvoiceStatus.pending,
      proofBytes: _demoReceiptBytes,
      proofName: 'bukti_transfer.jpg',
      hasProof: true,
      submittedAt: today.subtract(const Duration(hours: 3)),
    ),
    Invoice(
      id: 'demo-3',
      period:
          '${_monthNames[(today.month - 2 + 12) % 12]} ${today.month == 1 ? today.year - 1 : today.year}',
      property: 'Kost Wafa',
      room: 'Kamar 08',
      amount: 1500000,
      dueDate: today.subtract(const Duration(days: 4)),
    ),
    Invoice(
      id: 'demo-4',
      period: '${_monthNames[today.month - 1]} ${today.year}',
      property: 'Kontrakan Ghozi',
      room: 'Unit A',
      amount: 3950000,
      dueDate: DateTime(today.year, today.month, today.day + 5),
      status: InvoiceStatus.paid,
      paidAt: today.subtract(const Duration(days: 1)),
    ),
  ];
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

final Uint8List _demoReceiptBytes = Uint8List.fromList([
  0x89,
  0x50,
  0x4e,
  0x47,
  0x0d,
  0x0a,
  0x1a,
  0x0a,
  0x00,
  0x00,
  0x00,
  0x0d,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x04,
  0x00,
  0x00,
  0x00,
  0xb5,
  0x1c,
  0x0c,
  0x02,
  0x00,
  0x00,
  0x00,
  0x0b,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0xda,
  0x63,
  0xfc,
  0xff,
  0x1f,
  0x00,
  0x03,
  0x03,
  0x02,
  0x00,
  0xef,
  0x9a,
  0xe6,
  0x2a,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4e,
  0x44,
  0xae,
  0x42,
  0x60,
  0x82,
]);
