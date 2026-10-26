import 'package:projekakhirpamp/core/widgets/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/reservation_model.dart';
import '../providers/reservation_provider.dart';

class ReservationFormPage extends StatefulWidget {
  final ReservationModel? reservation;

  const ReservationFormPage({super.key, this.reservation});

  @override
  State<ReservationFormPage> createState() => _ReservationFormPageState();
}

class _ReservationFormPageState extends State<ReservationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _memberNameController = TextEditingController();
  final _bookTitleController = TextEditingController();
  final _reservationDateController = TextEditingController();
  final _pickupDeadlineController = TextEditingController();
  String _status = 'Menunggu';
  bool _saving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    if (widget.reservation != null) {
      _memberNameController.text = widget.reservation!.memberName;
      _bookTitleController.text = widget.reservation!.bookTitle;
      _reservationDateController.text = widget.reservation!.reservationDate;
      _pickupDeadlineController.text = widget.reservation!.pickupDeadline;
      _status = widget.reservation!.status;
    } else {
      _reservationDateController.text = DateTime.now().toString().split(' ')[0];
      _pickupDeadlineController.text = DateTime.now()
          .add(const Duration(days: 3))
          .toString()
          .split(' ')[0];
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final selected = DateTime.tryParse(controller.text) ?? DateTime.now();
    final first = DateTime(2020);
    final last = DateTime(2030);
    final initial = selected.isBefore(first)
        ? first
        : selected.isAfter(last)
        ? last
        : selected;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && mounted) {
      setState(() {
        controller.text = picked.toString().split(' ')[0];
      });
    }
  }

  void _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });

    final provider = context.read<ReservationProvider>();
    final newReservation = ReservationModel(
      id: widget.reservation?.id,
      memberName: _memberNameController.text.trim(),
      bookTitle: _bookTitleController.text.trim(),
      reservationDate: _reservationDateController.text.trim(),
      pickupDeadline: _pickupDeadlineController.text.trim(),
      status: _status,
    );

    try {
      if (widget.reservation == null) {
        await provider.addReservation(newReservation);
      } else {
        await provider.updateReservation(newReservation);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservasi berhasil disimpan')),
        );
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _saveError =
              'Gagal menyimpan reservasi. Periksa koneksi lalu coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _memberNameController.dispose();
    _bookTitleController.dispose();
    _reservationDateController.dispose();
    _pickupDeadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.reservation != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Data Reservasi' : 'Tambah Reservasi Baru'),
      ),
      body: ContentWidth(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  enabled: !_saving,
                  controller: _memberNameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Pemesan / Anggota',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Nama pemesan wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  enabled: !_saving,
                  controller: _bookTitleController,
                  decoration: InputDecoration(
                    labelText: 'Judul Buku',
                    prefixIcon: const Icon(Icons.menu_book_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Judul buku wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  enabled: !_saving,
                  controller: _reservationDateController,
                  readOnly: true,
                  onTap: () => _selectDate(_reservationDateController),
                  decoration: InputDecoration(
                    labelText: 'Tanggal Pemesanan',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  enabled: !_saving,
                  controller: _pickupDeadlineController,
                  readOnly: true,
                  onTap: () => _selectDate(_pickupDeadlineController),
                  decoration: InputDecoration(
                    labelText: 'Batas Akhir Pengambilan',
                    prefixIcon: const Icon(Icons.event_available_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _status,
                  decoration: InputDecoration(
                    labelText: 'Status Reservasi',
                    prefixIcon: const Icon(Icons.info_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ['Menunggu', 'Siap Diambil', 'Selesai', 'Dibatalkan']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: _saving
                      ? null
                      : (val) {
                          if (val != null) setState(() => _status = val);
                        },
                ),
                if (_saveError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        _saveError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _saving
                          ? 'Menyimpan...'
                          : isEdit
                          ? 'Simpan Perubahan'
                          : 'Simpan Reservasi',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
