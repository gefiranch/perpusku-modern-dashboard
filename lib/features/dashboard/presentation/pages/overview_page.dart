import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_layout.dart';
import '../../../catalog/presentation/providers/book_provider.dart';
import '../../../member/presentation/providers/member_provider.dart';
import '../../../reservation/presentation/providers/reservation_provider.dart';
import '../../../catalog/presentation/pages/book_form_page.dart';
import '../../../member/presentation/pages/member_form_page.dart';
import '../../../reservation/presentation/pages/reservation_form_page.dart';
import '../../../reservation/presentation/pages/reservation_detail_page.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;
  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  bool _started = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    setState(() => _started = true);
    await Future.wait([
      context.read<BookProvider>().fetchBooks(),
      context.read<MemberProvider>().fetchMembers(),
      context.read<ReservationProvider>().loadReservations(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final books = context.watch<BookProvider>();
    final members = context.watch<MemberProvider>();
    final reservations = context.watch<ReservationProvider>();
    String value(bool loading, String? error, int count) => !_started || loading
        ? '…'
        : error != null
        ? '—'
        : '$count';
    final stats = [
      (
        'Judul buku',
        value(books.isLoading, books.errorMessage, books.books.length),
        Icons.menu_book_outlined,
        1,
      ),
      (
        'Anggota',
        value(members.isLoading, members.errorMessage, members.members.length),
        Icons.people_outline,
        2,
      ),
      (
        'Total reservasi',
        value(
          reservations.isLoading,
          reservations.errorMessage,
          reservations.reservations.length,
        ),
        Icons.bookmark_border,
        3,
      ),
      (
        'Menunggu',
        value(
          reservations.isLoading,
          reservations.errorMessage,
          reservations.reservations.where((r) => r.status == 'Menunggu').length,
        ),
        Icons.schedule,
        3,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: [
          IconButton(
            tooltip: 'Segarkan ringkasan',
            onPressed:
                books.isLoading || members.isLoading || reservations.isLoading
                ? null
                : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: LayoutBuilder(
          builder: (context, box) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(box.maxWidth < 600 ? 16 : 28),
            children: [
              Text(
                'Perpustakaan dalam satu pandangan',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Pantau koleksi dan layanan perpustakaan Anda.',
                style: TextStyle(color: AppTheme.muted),
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, c) {
                  final columns = c.maxWidth >= 900
                      ? 4
                      : c.maxWidth >= 340
                      ? 2
                      : 1;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: stats
                        .map(
                          (s) => SizedBox(
                            width: (c.maxWidth - 16 * (columns - 1)) / columns,
                            child: Card(
                              child: InkWell(
                                onTap: () => widget.onNavigate(s.$4),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        s.$3,
                                        color: AppTheme.blue,
                                        size: 22,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        s.$2,
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.navy,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        s.$1,
                                        style: const TextStyle(
                                          color: AppTheme.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              if (books.errorMessage != null ||
                  members.errorMessage != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Sebagian ringkasan belum tersedia. Segarkan untuk mencoba lagi.',
                ),
              ],
              const SizedBox(height: 28),
              Text(
                'Akses cepat',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReservationFormPage(),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Reservasi Baru'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BookFormPage()),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Buku'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MemberFormPage()),
                    ),
                    icon: const Icon(Icons.person_add_outlined),
                    label: const Text('Tambah Anggota'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                children: [
                  Text(
                    'Reservasi terkini',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton.icon(
                    onPressed: () => widget.onNavigate(3),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Lihat semua'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!_started || reservations.isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (reservations.errorMessage != null)
                FeedbackState(
                  title: 'Reservasi belum dapat dimuat',
                  action: _load,
                )
              else if (reservations.reservations.isEmpty)
                const FeedbackState(
                  title: 'Belum ada reservasi',
                  message:
                      'Gunakan Reservasi Baru untuk menambahkan pemesanan.',
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (final r in reservations.reservations.take(5))
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          title: Text(
                            r.bookTitle,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${r.memberName} · ${r.reservationDate}'),
                                const SizedBox(height: 8),
                                StatusBadge(r.status),
                              ],
                            ),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ReservationDetailPage(reservation: r),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
