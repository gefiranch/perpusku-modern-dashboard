import 'package:flutter/material.dart';

import '../../data/category_rack_repository.dart';
import '../../domain/models/category_rack_model.dart';

class CategoryRackProvider with ChangeNotifier {
  CategoryRackProvider({CategoryRackRepository? repository})
    : _repository = repository ?? CategoryRackRepository();

  final CategoryRackRepository _repository;

  List<CategoryRackModel> _categories = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  Future<void>? _fetching;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  List<CategoryRackModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() =>
      _fetching ??= _fetch().whenComplete(() => _fetching = null);
  Future<void> _fetch() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _categories = await _repository.getCategories();
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
      await fetchCategories();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(String name, String location) async {
    await _mutate(() => _repository.addCategory(name, location));
  }

  Future<void> updateCategory(String id, String name, String location) async {
    await _mutate(() => _repository.updateCategory(id, name, location));
  }

  Future<void> deleteCategory(String id) async {
    await _mutate(() => _repository.deleteCategory(id));
  }
}
