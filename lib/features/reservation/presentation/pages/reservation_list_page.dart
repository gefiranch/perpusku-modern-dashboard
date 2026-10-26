import 'package:projekakhirpamp/core/widgets/app_layout.dart';
import 'package:projekakhirpamp/core/widgets/record_collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/reservation_model.dart';
import '../providers/reservation_provider.dart';
import 'reservation_form_page.dart';
import 'reservation_detail_page.dart';

class ReservationListPage extends StatefulWidget {
  const ReservationListPage({super.key});

  @override
  State<ReservationListPage> createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ReservationProvider>().loadReservations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservationProvider>();
    final theme = Theme.of(context);

    // Filter daftar berdasarkan kata kunci pencarian
    final filteredReservations = provider.reservations.where((item) {
      return item.bookTitle.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          item.memberName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return WorkspacePage(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reservasi',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Text(
              'Manajemen Reservasi Buku',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: provider.isGridView ? 'Tampilan List' : 'Tampilan Grid',
            icon: Icon(
              provider.isGridView
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
              color: Colors.black87,
            ),
            onPressed: () => provider.toggleViewMode(),
          ),
          IconButton(
            tooltip: 'Segarkan Data',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: provider.isLoading ? null : provider.loadReservations,
          ),
        ],
      ),
      body: Column(
        children: [
          // Baris Pencarian
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari nama pemesan atau judul buku...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Konten Utama Data
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.errorMessage != null
                ? FeedbackState(
                    title: provider.errorMessage!,
                    action: provider.loadReservations,
                  )
                : filteredReservations.isEmpty
                ? FeedbackState(
                    title: _searchQuery.isEmpty
                        ? 'Belum ada data reservasi'
                        : 'Tidak ada hasil pencarian',
                    actionLabel: _searchQuery.isEmpty
                        ? 'Reservasi Baru'
                        : 'Hapus pencarian',
                    action: () {
                      if (_searchQuery.isEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReservationFormPage(),
                          ),
                        );
                      } else {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      }
                    },
                  )
                : RefreshIndicator(
                    onRefresh: () => provider.loadReservations(),
                    child: provider.isGridView
                        ? _buildGridView(filteredReservations, provider)
                        : _buildListView(filteredReservations, provider),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReservationFormPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Reservasi Baru'),
      ),
    );
  }

  Widget _buildListView(
    List<ReservationModel> list,
    ReservationProvider provider,
  ) => _collection(list, provider, false);
  Widget _buildGridView(
    List<ReservationModel> list,
    ReservationProvider provider,
  ) => _collection(list, provider, true);
  Widget _collection(
    List<ReservationModel> list,
    ReservationProvider provider,
    bool grid,
  ) => RecordCollection(
    grid: grid,
    headers: const ['Buku', 'Pemesan', 'Tanggal', 'Batas ambil', 'Status'],
    items: list
        .map(
          (item) => RecordItem(
            title: item.bookTitle,
            subtitle:
                '${item.memberName}\nDipesan: ${item.reservationDate}\nBatas ambil: ${item.pickupDeadline}',
            cells: [
              item.bookTitle,
              item.memberName,
              item.reservationDate,
              item.pickupDeadline,
              item.status,
            ],
            badge: item.status,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReservationDetailPage(reservation: item),
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Detail reservasi',
                icon: const Icon(Icons.open_in_new),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReservationDetailPage(reservation: item),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Edit reservasi',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReservationFormPage(reservation: item),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Hapus reservasi',
                icon: const Icon(Icons.delete_outline),
                onPressed: provider.isSaving || item.id == null
                    ? null
                    : () => _delete(provider, item),
              ),
            ],
          ),
        )
        .toList(),
  );
  Future<void> _delete(
    ReservationProvider provider,
    ReservationModel item,
  ) async {
    if (!await confirmRemoval(
          context,
          '${item.bookTitle} — ${item.memberName}',
        ) ||
        !mounted) {
      return;
    }
    try {
      await provider.deleteReservation(item.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservasi berhasil dihapus')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus reservasi. Silakan coba lagi.'),
          ),
        );
      }
    }
  }
}
