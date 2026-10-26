import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_layout.dart';
import '../../domain/models/reservation_model.dart';
import '../providers/reservation_provider.dart';
import 'reservation_form_page.dart';

class ReservationDetailPage extends StatelessWidget {
  final ReservationModel reservation;
  const ReservationDetailPage({super.key, required this.reservation});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservationProvider>();
    final matches = provider.reservations.where((r) => r.id == reservation.id);
    final item = reservation.id != null && matches.isNotEmpty
        ? matches.first
        : reservation;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Reservasi')),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.bookmark_border, size: 28),
                    const SizedBox(height: 20),
                    Text(
                      item.bookTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    StatusBadge(item.status),
                    const Divider(height: 40),
                    for (final field in [
                      ('Pemesan', item.memberName),
                      ('Tanggal reservasi', item.reservationDate),
                      ('Batas pengambilan', item.pickupDeadline),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              field.$1,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              field.$2,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: provider.isSaving
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ReservationFormPage(reservation: item),
                          ),
                        ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Reservasi'),
                ),
                OutlinedButton.icon(
                  onPressed: provider.isSaving || item.id == null
                      ? null
                      : () async {
                          if (!await confirmRemoval(
                                context,
                                '${item.bookTitle} — ${item.memberName}',
                              ) ||
                              !context.mounted) {
                            return;
                          }
                          try {
                            await provider.deleteReservation(item.id!);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reservasi berhasil dihapus'),
                              ),
                            );
                            Navigator.pop(context);
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Gagal menghapus reservasi. Silakan coba lagi.',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus Reservasi'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
