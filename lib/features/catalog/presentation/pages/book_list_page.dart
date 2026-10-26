import 'package:projekakhirpamp/core/widgets/app_layout.dart';
import 'package:projekakhirpamp/core/widgets/record_collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/book_model.dart';
import '../providers/book_provider.dart';
import 'book_detail_page.dart';
import 'book_form_page.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BookProvider>().fetchBooks();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, BookModel book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Hapus Buku'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus buku "${book.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = Provider.of<BookProvider>(
                context,
                listen: false,
              );
              final success = await provider.deleteBook(book.id!);
              if (!context.mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Buku "${book.title}" berhasil dihapus.'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      provider.errorMessage ?? 'Gagal menghapus buku.',
                    ),
                    backgroundColor: Colors.red.shade800,
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final theme = Theme.of(context);

    // Kumpulkan daftar kategori yang tersedia
    final Set<String> categoriesSet = {'Semua'};
    for (var b in bookProvider.books) {
      if (b.category.trim().isNotEmpty) {
        categoriesSet.add(b.category.trim());
      }
    }
    final categoriesList = categoriesSet.toList();

    // Filter buku berdasarkan pencarian & kategori
    final filteredBooks = bookProvider.books.where((book) {
      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch =
          query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.bookCode.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query) ||
          book.rackLocation.toLowerCase().contains(query) ||
          book.publisher.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == 'Semua' ||
          book.category.trim().toLowerCase() ==
              _selectedCategory.trim().toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();

    // Hitung statistik ringkas
    final totalTitles = bookProvider.books.length;
    final totalStock = bookProvider.books.fold<int>(
      0,
      (sum, item) => sum + item.stock,
    );
    final outOfStockCount = bookProvider.books
        .where((b) => b.stock <= 0)
        .length;

    return WorkspacePage(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Katalog Buku',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Text(
              'Katalog & Koleksi Buku',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: bookProvider.isGridView
                ? 'Tampilan List'
                : 'Tampilan Grid',
            icon: Icon(
              bookProvider.isGridView
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
              color: Colors.black87,
            ),
            onPressed: () => bookProvider.toggleViewMode(),
          ),
          IconButton(
            tooltip: 'Segarkan Data',
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
            onPressed: () => bookProvider.fetchBooks(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Pencarian & Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input Pencarian
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari judul, penulis, kode, atau rak...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Colors.grey,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: Colors.grey,
                            ),
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
                const SizedBox(height: 10),

                // Kategori Chips
                if (categoriesList.length > 1)
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoriesList.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final cat = categoriesList[idx];
                        final isSelected = _selectedCategory == cat;
                        final count = cat == 'Semua'
                            ? bookProvider.books.length
                            : bookProvider.books
                                  .where(
                                    (b) =>
                                        b.category.trim().toLowerCase() ==
                                        cat.trim().toLowerCase(),
                                  )
                                  .length;

                        return ChoiceChip(
                          label: Text('$cat ($count)'),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade800,
                          ),
                          selected: isSelected,
                          selectedColor: theme.colorScheme.primary,
                          backgroundColor: const Color(0xFFF5F7FA),
                          showCheckmark: false,
                          visualDensity: VisualDensity.standard,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.grey.shade300,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Baris Ringkasan Statistik Singkat
          if (bookProvider.books.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade50,
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Menampilkan ${filteredBooks.length} dari $totalTitles judul buku',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Total Stok: $totalStock',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.indigo.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (outOfStockCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Habis: $outOfStockCount',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Area Konten Utama
          Expanded(
            child: bookProvider.isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Memuat katalog buku...'),
                      ],
                    ),
                  )
                : bookProvider.errorMessage != null
                ? _buildErrorView(bookProvider)
                : filteredBooks.isEmpty
                ? _buildEmptyView(bookProvider.books.isEmpty)
                : RefreshIndicator(
                    onRefresh: () => bookProvider.fetchBooks(),
                    child: bookProvider.isGridView
                        ? _buildGridView(filteredBooks, theme)
                        : _buildListView(filteredBooks, theme),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Tambah Buku'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookFormPage()),
        ),
      ),
    );
  }

  Widget _buildErrorView(BookProvider provider) => FeedbackState(
    title: 'Gagal Memuat Katalog',
    message: 'Periksa koneksi lalu coba lagi.',
    action: provider.fetchBooks,
  );
  Widget _buildEmptyView(bool isEmpty) => FeedbackState(
    title: isEmpty ? 'Belum Ada Buku di Katalog' : 'Buku Tidak Ditemukan',
    message: isEmpty
        ? 'Tambahkan buku pertama ke koleksi perpustakaan.'
        : 'Coba kata kunci atau kategori lainnya.',
    actionLabel: isEmpty ? 'Tambah Buku Sekarang' : 'Reset Pencarian & Filter',
    action: () {
      if (isEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookFormPage()),
        );
      } else {
        _searchController.clear();
        setState(() {
          _searchQuery = '';
          _selectedCategory = 'Semua';
        });
      }
    },
  );

  Widget _buildListView(List<BookModel> books, ThemeData theme) =>
      _collection(books, false);
  Widget _buildGridView(List<BookModel> books, ThemeData theme) =>
      _collection(books, true);
  Widget _collection(List<BookModel> books, bool grid) => RecordCollection(
    grid: grid,
    headers: const ['Buku', 'Penulis', 'Kategori', 'Rak', 'Stok'],
    items: books
        .map(
          (book) => RecordItem(
            title: book.title,
            subtitle:
                '${book.author} · ${book.bookCode}\n${book.category} · ${book.rackLocation}\nStok: ${book.stock}',
            cells: [
              book.title,
              book.author,
              book.category,
              book.rackLocation,
              '${book.stock}',
            ],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BookDetailPage(book: book)),
            ),
            actions: [
              IconButton(
                tooltip: 'Detail Buku',
                icon: const Icon(Icons.open_in_new),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookDetailPage(book: book)),
                ),
              ),
              IconButton(
                tooltip: 'Edit Buku',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookFormPage(book: book)),
                ),
              ),
              IconButton(
                tooltip: 'Hapus Buku',
                icon: const Icon(Icons.delete_outline),
                onPressed:
                    context.watch<BookProvider>().isSaving || book.id == null
                    ? null
                    : () => _confirmDelete(context, book),
              ),
            ],
          ),
        )
        .toList(),
  );
}
