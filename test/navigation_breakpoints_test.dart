import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projekakhirpamp/core/theme/app_theme.dart';
import 'package:projekakhirpamp/features/auth/presentation/providers/auth_provider.dart';
import 'package:projekakhirpamp/features/catalog/data/book_repository.dart';
import 'package:projekakhirpamp/features/catalog/domain/models/book_model.dart';
import 'package:projekakhirpamp/features/catalog/presentation/providers/book_provider.dart';
import 'package:projekakhirpamp/features/member/presentation/providers/member_provider.dart';
import 'package:projekakhirpamp/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:projekakhirpamp/features/category_rack/presentation/providers/category_rack_provider.dart';
import 'package:projekakhirpamp/features/dashboard/presentation/pages/main_navigation_page.dart';

import 'provider_recovery_test.dart' show ReservationRepoFake, CategoryRepoFake;
import 'widget_test.dart' show FakeMemberRepository;

class NoPkceStorage extends GotrueAsyncStorage {
  const NoPkceStorage();
  @override
  Future<String?> getItem({required String key}) async => null;
  @override
  Future<void> setItem({required String key, required String value}) async {}
  @override
  Future<void> removeItem({required String key}) async {}
}

class EmptyBooks implements BookRepository {
  @override
  Future<List<BookModel>> fetchBooks() async => [];
  @override
  Future<void> addBook(BookModel book) async {}
  @override
  Future<void> updateBook(BookModel book) async {}
  @override
  Future<void> deleteBook(String id) async {}
}

Widget shell({double scale = 1, ThemeData? theme}) => MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(
      create: (_) => BookProvider(repository: EmptyBooks()),
    ),
    ChangeNotifierProvider(
      create: (_) => MemberProvider(repository: FakeMemberRepository()),
    ),
    ChangeNotifierProvider(
      create: (_) => ReservationProvider(repository: ReservationRepoFake()),
    ),
    ChangeNotifierProvider(
      create: (_) =>
          CategoryRackProvider(repository: CategoryRepoFake()..fail = false),
    ),
  ],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme ?? AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: const MainNavigationPage(),
  ),
);
Future<void> navigate(WidgetTester tester, double width, String label) async {
  if (width < 600) {
    final nav = find.byType(NavigationBar);
    if (label == 'Anggota' || label == 'Kategori & Rak') {
      await tester.tap(
        find.descendant(of: nav, matching: find.text('Lainnya')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, label).last);
    } else {
      await tester.tap(find.descendant(of: nav, matching: find.text(label)));
    }
  } else if (width < 1024) {
    await tester.tap(find.byTooltip(label));
  } else {
    await tester.tap(find.widgetWithText(ListTile, label).first);
  }
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await Supabase.initialize(
      url: 'http://localhost:54321',
      publishableKey: 'offline-test-key',
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
        pkceAsyncStorage: NoPkceStorage(),
        autoRefreshToken: false,
        detectSessionInUri: false,
      ),
    );
  });
  tearDownAll(() => Supabase.instance.dispose());
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
      testWidgets('All modules accessible at $width and scale $scale', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 900);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(shell(scale: scale));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final label in [
          'Katalog',
          'Anggota',
          'Reservasi',
          'Kategori & Rak',
          'Beranda',
        ]) {
          await navigate(tester, width, label);
          expect(
            tester.takeException(),
            isNull,
            reason: '$label at $width / $scale',
          );
        }
      });
    }
  }
  testWidgets('Catalog search survives module navigation and resizing', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(shell());
    await tester.pumpAndSettle();
    await navigate(tester, 390, 'Katalog');
    await tester.enterText(find.byType(TextField), 'judul tersimpan');
    await navigate(tester, 390, 'Beranda');
    tester.view.physicalSize = const Size(1440, 900);
    await tester.pumpAndSettle();
    await navigate(tester, 1440, 'Katalog');
    expect(find.text('judul tersimpan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Optional offline overview screenshots', (tester) async {
    final output = Platform.environment['PERPUSKU_SCREENSHOT_DIR'];
    if (output == null) return;
    final sdk = Platform.environment['FLUTTER_ROOT']!;
    await tester.runAsync(() async {
      for (final font in [
        ('Roboto', 'Roboto-Regular.ttf'),
        ('MaterialIcons', 'MaterialIcons-Regular.otf'),
      ]) {
        final bytes = await File(
          '$sdk/bin/cache/artifacts/material_fonts/${font.$2}',
        ).readAsBytes();
        await (FontLoader(
          font.$1,
        )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
      }
    });
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final size in [const Size(390, 844), const Size(1440, 1000)]) {
      tester.view.physicalSize = size;
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: shell(
            theme: AppTheme.light.copyWith(
              textTheme: AppTheme.light.textTheme.apply(fontFamily: 'Roboto'),
              appBarTheme: AppTheme.light.appBarTheme.copyWith(
                titleTextStyle: AppTheme.light.appBarTheme.titleTextStyle!
                    .copyWith(fontFamily: 'Roboto'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final rendered = await boundary.toImage(pixelRatio: 1);
        final bytes = (await rendered.toByteData(
          format: ui.ImageByteFormat.png,
        ))!;
        await Directory(output).create(recursive: true);
        await File(
          '$output/${size.width < 600 ? 'mobile' : 'desktop'}_overview.png',
        ).writeAsBytes(bytes.buffer.asUint8List());
        rendered.dispose();
      });
    }
  });
}
