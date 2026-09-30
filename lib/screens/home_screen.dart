import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../models/item.dart';
import '../routes/app_routes.dart';
import '../widgets/state_views.dart';

const _ink = Color(0xFF1E293B);
const _muted = Color(0xFF64748B);
const _line = Color(0xFFE2E8F0);
const _teal = Color(0xFF0D9488);
const _blue = Color(0xFF0EA5E9);

// Status pemuatan data pada bagian daftar kos populer.
enum ViewStatus { loading, success, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  final _repository = ItemRepository();
  ViewStatus _status = ViewStatus.loading;
  List<Item> _items = [];
  String _errorMessage = '';
  bool _isLoading = true;
  final bool _simulateError = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // Ambil data dummy dan pastikan indikator selalu berhenti di finally.
  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _status = ViewStatus.loading;
    });
    try {
      final items = await _repository.fetchItems(simulateError: _simulateError);
      if (!mounted) return;
      setState(() {
        _items = items;
        _status = ViewStatus.success;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _status = ViewStatus.error;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Data Item dikirim sebagai arguments melalui named route.
  void _openItem(Item item) {
    Navigator.pushNamed(context, AppRoutes.detail, arguments: item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(child: _Header()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(child: const _SearchBar()),
            ),
            SliverToBoxAdapter(child: _FilterRow()),
            SliverPadding(
              padding: const EdgeInsets.only(top: 8),
              sliver: SliverToBoxAdapter(
                child: _PopularSection(
                  items: _items,
                  status: _status,
                  isLoading: _isLoading,
                  errorMessage: _errorMessage,
                  onRetry: _loadItems,
                  onItemTap: _openItem,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverToBoxAdapter(
                child: _NearbySection(
                  items: _items,
                  status: _status,
                  isLoading: _isLoading,
                  errorMessage: _errorMessage,
                  onRetry: _loadItems,
                  onItemTap: _openItem,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavigation(
        selectedIndex: _selectedTab,
        onSelected: (index) => setState(() => _selectedTab = index),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [Color(0xFF0EA5E9), _teal]),
          ),
          child: const Text(
            'IZ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Pagi,',
                style: TextStyle(color: _muted, fontSize: 11),
              ),
              SizedBox(height: 2),
              Text(
                'Hai, Imam Zuhdi',
                style: TextStyle(
                  color: _ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _CircleIconButton(
          icon: Icons.notifications_none_rounded,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Notifikasi',
      icon: Icon(icon, size: 21, color: _ink),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: _line),
        fixedSize: const Size(40, 40),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: _teal, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Cari kos di sekitarmu...',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ),
          IconButton(
            onPressed: () {},
            tooltip: 'Filter pencarian',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24),
            icon: const Icon(Icons.tune_rounded, color: _muted, size: 19),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: const [
          _FilterChip(label: 'Harga', active: true),
          SizedBox(width: 8),
          _FilterChip(label: 'Lokasi'),
          SizedBox(width: 8),
          _FilterChip(label: 'Fasilitas'),
          SizedBox(width: 8),
          _FilterChip(label: 'Tipe Kamar'),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      decoration: BoxDecoration(
        color: active ? _teal : Colors.white,
        border: Border.all(color: active ? _teal : _line),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : _muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 13,
            color: active ? Colors.white : const Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }
}

class _PopularSection extends StatelessWidget {
  const _PopularSection({
    required this.items,
    required this.status,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onItemTap,
  });

  final List<Item> items;
  final ViewStatus status;
  final bool isLoading;
  final String errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<Item> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(title: 'Kos Populer', action: 'Lihat Semua'),
        const SizedBox(height: 12),
        SizedBox(height: 258, child: _buildItems()),
      ],
    );
  }

  Widget _buildItems() {
    if (isLoading) return const LoadingView();
    if (status == ViewStatus.error) {
      return ErrorView(message: errorMessage, onRetry: onRetry);
    }
    if (items.isEmpty) return const EmptyView(message: 'Belum ada data.');

    return ListView.separated(
      padding: const EdgeInsets.only(left: 20, right: 20),
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        return _PopularCard(
          item: item,
          listing: _visualDetailsFor(item),
          onTap: () => onItemTap(item),
        );
      },
    );
  }
}

// Pertahankan metadata visual lama yang cocok dengan nama kos.
Listing? _visualDetailsFor(Item item) {
  final name = item.title.toLowerCase().split(' ').last;
  for (final listing in [..._popularListings, ..._nearbyListings]) {
    if (listing.name.toLowerCase().contains(name)) return listing;
  }
  return null;
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
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
          Text(
            action,
            style: const TextStyle(
              color: _blue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularCard extends StatelessWidget {
  const _PopularCard({
    required this.item,
    required this.listing,
    required this.onTap,
  });

  final Item item;
  final Listing? listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shadowColor: const Color(0x140F172A),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _ListingImage(url: listing?.imageUrl ?? '', height: 130),
                  if (listing != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _RatingBadge(rating: listing!.rating),
                    ),
                  Positioned(top: 10, right: 10, child: _FavoriteButton()),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GenderTag(label: 'PUTRA', isMale: true),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: _muted,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: _muted, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (listing != null)
                      _Price(text: listing!.price, color: _blue),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbySection extends StatelessWidget {
  const _NearbySection({
    required this.items,
    required this.status,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onItemTap,
  });

  final List<Item> items;
  final ViewStatus status;
  final bool isLoading;
  final String errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<Item> onItemTap;

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (isLoading) {
      content = const LoadingView();
    } else if (status == ViewStatus.error) {
      content = ErrorView(message: errorMessage, onRetry: onRetry);
    } else if (items.isEmpty) {
      content = const EmptyView(message: 'Belum ada data.');
    } else {
      content = Column(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _NearbyCard(
                item: item,
                listing: _visualDetailsFor(item),
                onTap: () => onItemTap(item),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          title: 'Terdekat dari Kampusmu',
          action: 'Filter Kampus',
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }
}

class _NearbyCard extends StatelessWidget {
  const _NearbyCard({
    required this.item,
    required this.listing,
    required this.onTap,
  });

  final Item item;
  final Listing? listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _ListingImage(
                url: listing?.imageUrl ?? '',
                width: 90,
                height: 90,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _GenderTag(label: 'PUTRA', isMale: true),
                      const Spacer(),
                      if (listing != null && listing!.availability.isNotEmpty)
                        _AvailabilityTag(text: listing!.availability),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _muted, fontSize: 11),
                        ),
                      ),
                      if (listing != null) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: Color(0xFFFBBF24),
                        ),
                        Text(
                          listing!.rating,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (listing != null)
                    _Price(text: listing!.price, color: _teal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingImage extends StatelessWidget {
  const _ListingImage({required this.url, this.width, this.height});

  final String url;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: const Color(0xFFE2E8F0),
        child: const Icon(Icons.home_work_outlined, color: _muted),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFBBF24)),
          const SizedBox(width: 2),
          Text(
            rating,
            style: const TextStyle(
              color: _ink,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.favorite_border_rounded,
        color: Color(0xFFEF4444),
        size: 16,
      ),
    );
  }
}

class _GenderTag extends StatelessWidget {
  const _GenderTag({required this.label, required this.isMale});

  final String label;
  final bool isMale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isMale ? const Color(0xFFFEE2E2) : const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isMale ? const Color(0xFFEF4444) : _teal,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AvailabilityTag extends StatelessWidget {
  const _AvailabilityTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF10B981),
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Price extends StatelessWidget {
  const _Price({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        children: const [
          TextSpan(
            text: '/bln',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Beranda'),
      (Icons.search_rounded, 'Pencarian'),
      (Icons.calendar_month_outlined, 'Booking'),
      (Icons.info_outline_rounded, 'Komplain'),
      (Icons.person_outline_rounded, 'Profil'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++)
              Expanded(
                child: InkWell(
                  onTap: () => onSelected(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          items[index].$1,
                          size: 22,
                          color: index == selectedIndex
                              ? _teal
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[index].$2,
                          style: TextStyle(
                            color: index == selectedIndex ? _teal : _muted,
                            fontSize: 10,
                            fontWeight: index == selectedIndex
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Listing {
  const Listing({
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.imageUrl,
    this.availability = '',
  });

  final String name;
  final String location;
  final String price;
  final String rating;
  final String imageUrl;
  final String availability;
}

const _popularListings = [
  Listing(
    name: 'Kos Nopal',
    location: 'RB Teknik 02, Bawah Terowongan',
    price: 'Rp 850.000',
    rating: '4.8',
    imageUrl: 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=600&q=80',
  ),
  Listing(
    name: 'Griya Anggrek Executive',
    location: 'Seturan, Yogyakarta',
    price: 'Rp 1.200.000',
    rating: '4.9',
    imageUrl: 'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?w=600&q=80',
  ),
];

const _nearbyListings = [
  Listing(
    name: 'Kontrakan Ghozi',
    location: '300m dari Los Chicken',
    price: 'Rp 3.950.000',
    rating: '2.3',
    availability: 'SISA 2 KAMAR',
    imageUrl:
        'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=300&q=80',
  ),
  Listing(
    name: 'Kost Wafa',
    location: 'Belakang BC',
    price: 'Rp 1.500.000',
    rating: '4.6',
    availability: 'SISA 1 KAMAR',
    imageUrl: 'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=300&q=80',
  ),
];
