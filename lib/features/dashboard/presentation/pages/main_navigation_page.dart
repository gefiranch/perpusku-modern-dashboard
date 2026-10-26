import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../catalog/presentation/pages/book_list_page.dart';
import '../../../reservation/presentation/pages/reservation_list_page.dart';
import '../../../category_rack/presentation/pages/category_rack_list_page.dart';
import '../../../member/presentation/pages/member_list_page.dart';
import 'overview_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});
  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selected = 0;
  final _visited = <int>{0};
  static const _labels = [
    'Beranda',
    'Katalog',
    'Anggota',
    'Reservasi',
    'Kategori & Rak',
  ];
  static const _icons = [
    Icons.space_dashboard_outlined,
    Icons.menu_book_outlined,
    Icons.people_outline,
    Icons.bookmark_border,
    Icons.shelves,
  ];
  void _select(int index) => setState(() {
    _selected = index;
    _visited.add(index);
  });

  Future<void> _logout() async {
    try {
      await context.read<AuthProvider>().signOut();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal keluar. Silakan coba lagi.')),
        );
      }
    }
  }

  Future<void> _more() async {
    final value = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final index in [2, 4])
                ListTile(
                  leading: Icon(_icons[index]),
                  title: Text(_labels[index]),
                  onTap: () => Navigator.pop(ctx, index),
                ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Keluar'),
                onTap: () => Navigator.pop(ctx, -1),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || value == null) return;
    if (value == -1) {
      await _logout();
    } else {
      _select(value);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final desktop = box.maxWidth >= 1024;
      final mobile = box.maxWidth < 600;
      final pages = <Widget>[
        OverviewPage(onNavigate: _select),
        const BookListPage(),
        const MemberListPage(),
        const ReservationListPage(),
        const CategoryRackListPage(),
      ];
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              if (!mobile)
                Container(
                  width: desktop ? 248 : 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(right: BorderSide(color: AppTheme.border)),
                  ),
                  child: Material(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 28,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_library_outlined,
                                color: AppTheme.navy,
                                size: 28,
                              ),
                              if (desktop) ...[
                                const SizedBox(width: 12),
                                const Flexible(
                                  child: Text(
                                    'PerpusKu',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.navy,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                if (desktop)
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      24,
                                      16,
                                      24,
                                      12,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'RUANG KERJA',
                                        style: TextStyle(
                                          fontSize: 11,
                                          letterSpacing: 1.4,
                                          color: AppTheme.muted,
                                        ),
                                      ),
                                    ),
                                  ),
                                for (var i = 0; i < _labels.length; i++)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: desktop ? 12 : 8,
                                      vertical: 4,
                                    ),
                                    child: desktop
                                        ? ListTile(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            selected: _selected == i,
                                            selectedTileColor: const Color(
                                              0xFFEAF0F8,
                                            ),
                                            leading: Icon(_icons[i]),
                                            title: Text(_labels[i]),
                                            onTap: () => _select(i),
                                          )
                                        : IconButton(
                                            tooltip: _labels[i],
                                            isSelected: _selected == i,
                                            onPressed: () => _select(i),
                                            icon: Icon(_icons[i]),
                                          ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        if (desktop)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              context
                                      .watch<AuthProvider>()
                                      .currentUser
                                      ?.email ??
                                  'Petugas perpustakaan',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.muted,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: desktop
                              ? ListTile(
                                  leading: const Icon(Icons.logout),
                                  title: const Text('Keluar'),
                                  onTap: _logout,
                                )
                              : IconButton(
                                  tooltip: 'Keluar',
                                  onPressed: _logout,
                                  icon: const Icon(Icons.logout),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                key: const ValueKey('workspace-content'),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: IndexedStack(
                      index: _selected,
                      children: [
                        for (var i = 0; i < pages.length; i++)
                          KeyedSubtree(
                            key: ValueKey(i),
                            child: _visited.contains(i)
                                ? pages[i]
                                : const SizedBox.shrink(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: mobile
            ? NavigationBar(
                selectedIndex: _selected == 0
                    ? 0
                    : _selected == 1
                    ? 1
                    : _selected == 3
                    ? 2
                    : 3,
                onDestinationSelected: (index) =>
                    index == 3 ? _more() : _select([0, 1, 3][index]),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.space_dashboard_outlined),
                    label: 'Beranda',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    label: 'Katalog',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bookmark_border),
                    label: 'Reservasi',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.more_horiz),
                    label: 'Lainnya',
                  ),
                ],
              )
            : null,
      );
    },
  );
}
