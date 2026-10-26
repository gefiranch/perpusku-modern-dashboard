import 'package:flutter/material.dart';

import '../../data/reservation_repository.dart';
import '../../domain/models/reservation_model.dart';

class ReservationProvider extends ChangeNotifier {
  ReservationProvider({ReservationRepository? repository})
    : _repository = repository ?? ReservationRepository();

  final ReservationRepository _repository;
  List<ReservationModel> _reservations = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  Future<void>? _fetching;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool _isGridView = false;

  List<ReservationModel> get reservations => _reservations;
  bool get isLoading => _isLoading;
  bool get isGridView => _isGridView;

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  Future<void> loadReservations() =>
      _fetching ??= _fetch().whenComplete(() => _fetching = null);
  Future<void> _fetch() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _reservations = await _repository.fetchReservations();
    } catch (_) {
      _errorMessage = 'Gagal memuat data. Periksa koneksi lalu coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _mutate(Future<void> Function() operation) async {
    if (_isSaving) throw StateError('Data sedang disimpan.');
    _isSaving = true;
    notifyListeners();
    try {
      // Wait for any previous read before mutation and refresh.
      final pending = _fetching;
      if (pending != null) await pending;
      await operation();
      await loadReservations();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> addReservation(ReservationModel reservation) async {
    await _mutate(() => _repository.addReservation(reservation));
  }

  Future<void> updateReservation(ReservationModel reservation) async {
    await _mutate(() => _repository.updateReservation(reservation));
  }

  Future<void> deleteReservation(String id) async {
    await _mutate(() => _repository.deleteReservation(id));
  }
}
