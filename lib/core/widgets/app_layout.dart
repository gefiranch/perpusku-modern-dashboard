import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Keeps the subtree in the same position when constraints change.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = 760});
  final Widget child;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => Row(
      children: [
        if (box.maxWidth >= 1024)
          Expanded(
            child: Container(
              color: AppTheme.navy,
              padding: const EdgeInsets.all(56),
              child: const Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_library_outlined,
                        size: 40,
                        color: Colors.white,
                      ),
                      SizedBox(height: 32),
                      Text(
                        'PerpusKu',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Ruang untuk buku.\nKemudahan untuk Anda.',
                        style: TextStyle(
                          fontSize: 28,
                          height: 1.3,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Kelola koleksi, anggota, dan reservasi\ndalam satu tempat yang tertata.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Color(0xFFCBD7E8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          key: const ValueKey('auth-form'),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child,
            ),
          ),
        ),
      ],
    ),
  );
}

class FeedbackState extends StatelessWidget {
  const FeedbackState({
    super.key,
    required this.title,
    this.message,
    this.action,
    this.actionLabel = 'Coba Lagi',
    this.icon = Icons.inbox_outlined,
  });
  final String title;
  final String? message;
  final VoidCallback? action;
  final String actionLabel;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: AppTheme.muted),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(message!, textAlign: TextAlign.center),
          ],
          if (action != null) ...[
            const SizedBox(height: 20),
            OutlinedButton(onPressed: action, child: Text(actionLabel)),
          ],
        ],
      ),
    ),
  );
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      'Menunggu' => const Color(0xFF8A5700),
      'Siap Diambil' => const Color(0xFF13734B),
      'Selesai' => AppTheme.blue,
      'Dibatalkan' => const Color(0xFFB42318),
      _ => AppTheme.navy,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

Future<bool> confirmRemoval(BuildContext context, String name) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus data?'),
        content: Text(
          'Hapus "$name"? Data yang dihapus tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    ) ??
    false;

class ResponsiveFields extends StatelessWidget {
  const ResponsiveFields({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final fields = children.whereType<Expanded>().toList();
      final twoColumns = box.maxWidth >= 600;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (var i = 0; i < fields.length; i++)
            SizedBox(
              key: ValueKey(i),
              width: twoColumns ? (box.maxWidth - 16) / 2 : box.maxWidth,
              child: fields[i].child,
            ),
        ],
      );
    },
  );
}

/// Moves the existing primary action into the desktop toolbar.
class WorkspacePage extends StatelessWidget {
  const WorkspacePage({
    super.key,
    required this.appBar,
    required this.body,
    this.floatingActionButton,
    this.backgroundColor,
  });
  final AppBar appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final wide =
          box.maxWidth >= 900 ||
          (MediaQuery.sizeOf(context).width >= 1024 && box.maxWidth >= 600);
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: appBar.title,
          automaticallyImplyLeading: false,
          actions: [
            ...?appBar.actions,
            if (wide && floatingActionButton != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 24, 8),
                child: floatingActionButton!,
              ),
          ],
        ),
        body: body,
        floatingActionButton: wide ? null : floatingActionButton,
      );
    },
  );
}
