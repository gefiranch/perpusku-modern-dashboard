import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projekakhirpamp/core/theme/app_theme.dart';
import 'package:projekakhirpamp/core/widgets/app_layout.dart';
import 'package:projekakhirpamp/features/catalog/presentation/pages/book_form_page.dart';
import 'package:projekakhirpamp/features/reservation/presentation/pages/reservation_form_page.dart';
import 'package:projekakhirpamp/features/category_rack/presentation/pages/category_rack_form_page.dart';

void main() {
  for (final width in [
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
  ]) {
    for (final scale in [1.0, 1.3]) {
      for (final entry in <String, Widget>{
        'book': const BookFormPage(),
        'reservation': const ReservationFormPage(),
        'category': const CategoryRackFormPage(),
      }.entries) {
        testWidgets(
          '${entry.key} fits $width at $scale including lower fields',
          (tester) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = Size(width, 900);
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.light,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: entry.value,
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final scroll = find.byType(Scrollable).first;
            await tester.drag(scroll, const Offset(0, -1800));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
  testWidgets('Auth form stays mounted when branding panel appears', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: AuthLayout(child: TextField())),
      ),
    );
    await tester.enterText(find.byType(TextField), 'petugas@example.com');
    tester.view.physicalSize = const Size(1440, 900);
    await tester.pumpAndSettle();
    expect(find.text('petugas@example.com'), findsOneWidget);
    tester.view.physicalSize = const Size(320, 900);
    await tester.pumpAndSettle();
    expect(find.text('petugas@example.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
