import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:projekakhirpamp/features/reservation/data/reservation_repository.dart';
import 'package:projekakhirpamp/features/reservation/domain/models/reservation_model.dart';
import 'package:projekakhirpamp/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:projekakhirpamp/features/category_rack/data/category_rack_repository.dart';
import 'package:projekakhirpamp/features/category_rack/domain/models/category_rack_model.dart';
import 'package:projekakhirpamp/features/category_rack/presentation/providers/category_rack_provider.dart';

class ReservationRepoFake implements ReservationRepository {
  bool fail = false;
  int reads = 0;
  int deletes = 0;
  Completer<List<ReservationModel>>? pending;
  @override
  Future<List<ReservationModel>> fetchReservations() async {
    reads++;
    if (fail) throw Exception('Offline');
    return pending == null ? [] : await pending!.future;
  }

  @override
  Future<void> addReservation(ReservationModel r) async {
    if (fail) throw Exception('Offline');
  }

  @override
  Future<void> updateReservation(ReservationModel r) async {
    if (fail) throw Exception('Offline');
  }

  @override
  Future<void> deleteReservation(String id) async {
    deletes++;
    if (fail) throw Exception('Offline');
  }
}

class CategoryRepoFake implements CategoryRackRepository {
  bool fail = true;
  @override
  Future<List<CategoryRackModel>> getCategories() async {
    if (fail) throw Exception('Offline');
    return [];
  }

  @override
  Future<void> addCategory(String name, String location) async {}
  @override
  Future<void> updateCategory(String id, String name, String location) async {}
  @override
  Future<void> deleteCategory(String id) async {
    if (fail) throw Exception('Offline');
  }
}

void main() {
  test('Reservation fetch exposes errors and retry clears them', () async {
    final repo = ReservationRepoFake()..fail = true;
    final provider = ReservationProvider(repository: repo);
    await provider.loadReservations();
    expect(provider.errorMessage, isNotNull);
    expect(provider.isLoading, false);
    repo.fail = false;
    await provider.loadReservations();
    expect(provider.errorMessage, isNull);
  });
  test('Concurrent overview/list reads use a single request', () async {
    final repo = ReservationRepoFake()
      ..pending = Completer<List<ReservationModel>>();
    final provider = ReservationProvider(repository: repo);
    final first = provider.loadReservations();
    final second = provider.loadReservations();
    expect(repo.reads, 1);
    repo.pending!.complete([]);
    await Future.wait([first, second]);
    expect(provider.isLoading, false);
  });
  test('Failed delete propagates and releases saving state', () async {
    final provider = ReservationProvider(
      repository: ReservationRepoFake()..fail = true,
    );
    await expectLater(provider.deleteReservation('test'), throwsException);
    expect(provider.isSaving, false);
  });
  test('Category load and delete failures stay recoverable', () async {
    final repo = CategoryRepoFake();
    final provider = CategoryRackProvider(repository: repo);
    await provider.fetchCategories();
    expect(provider.errorMessage, isNotNull);
    await expectLater(provider.deleteCategory('test'), throwsException);
    expect(provider.isSaving, false);
    repo.fail = false;
    await provider.fetchCategories();
    expect(provider.errorMessage, isNull);
  });
}
