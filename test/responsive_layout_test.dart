import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:projekakhirpamp/core/theme/app_theme.dart';
import 'package:projekakhirpamp/core/widgets/record_collection.dart';
import 'package:projekakhirpamp/features/member/presentation/pages/member_form_page.dart';
import 'package:projekakhirpamp/features/member/presentation/providers/member_provider.dart';

import 'widget_test.dart' show FakeMemberRepository;

void main() {
  const widths = [
    320.0,
    360.0,
    390.0,
    430.0,
    600.0,
    768.0,
    900.0,
    1024.0,
    1280.0,
    1440.0,
    1920.0,
  ];
  for (final width in widths) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('Records fit $width at text scale $scale and actions work', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 900);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var edits = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 900),
                textScaler: TextScaler.linear(scale),
              ),
              child: Scaffold(
                body: RecordCollection(
                  headers: const ['Nama', 'Email'],
                  items: [
                    RecordItem(
                      title: 'Nama anggota dengan informasi yang panjang',
                      subtitle: 'AGT-001\nanggota@example.com\n081234567890',
                      cells: const [
                        'Nama anggota dengan informasi yang panjang',
                        'anggota@example.com',
                      ],
                      actions: [
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => edits++,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final edit = find.byTooltip('Edit');
        await tester.ensureVisible(edit);
        await tester.tap(edit);
        expect(edits, 1);
      });
    }
  }
  testWidgets('Member form preserves typed input across all breakpoints', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(390, 900);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MemberProvider(repository: FakeMemberRepository()),
        child: MaterialApp(theme: AppTheme.light, home: const MemberFormPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'AGT-KEEP');
    for (final width in widths) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller!
            .text,
        'AGT-KEEP',
      );
      expect(tester.takeException(), isNull);
    }
  });
}
