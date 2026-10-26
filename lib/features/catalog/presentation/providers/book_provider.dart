import 'package:flutter/material.dart';

import '../../data/book_repository.dart';
import '../../domain/models/book_model.dart';

class BookProvider extends ChangeNotifier {
  BookProvider({BookRepository? repository})
    : _repository = repository ?? BookRepository();

  final BookRepository _repository;

  List<BookModel> _books = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool get isSaving => _isSaving;
  Future<void>? _fetching;
  String? _errorMessage;
  bool _isGridView = false;

  List<BookModel> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isGridView => _isGridView;

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  BookModel? getBookById(String id) {
    try {
      return _books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchBooks() =>
      _fetching ??= _fetch().whenComplete(() => _fetching = null);

  Future<void> _fetch() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _books = await _repository.fetchBooks();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _mutate(Future<void> Function() operation) async {
    if (_isSaving) return false;
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final pending = _fetching;
      if (pending != null) await pending;
      await operation();
      await fetchBooks();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> addBook(BookModel book) =>
      _mutate(() => _repository.addBook(book));
  Future<bool> updateBook(BookModel book) =>
      _mutate(() => _repository.updateBook(book));
  Future<bool> deleteBook(String id) =>
      _mutate(() => _repository.deleteBook(id));
}
