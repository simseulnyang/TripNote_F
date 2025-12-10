import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip_model.dart';
import '../repositories/trip_repository.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository();
});

final tripListProvider =
    AsyncNotifierProvider<TripListNotifier, List<TripModel>>(() {
  return TripListNotifier();
});

class TripListNotifier extends AsyncNotifier<List<TripModel>> {
  @override
  Future<List<TripModel>> build() async {
    try {
      final result = await _loadTrips();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  TripRepository get _repository {
    return ref.read(tripRepositoryProvider);
  }

  Future<List<TripModel>> _loadTrips() async {
    try {
      final trips = await _repository.getTrips();
      return trips;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadTrips());
  }

  void addTrip(TripModel trip) {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data([trip, ...currentData]);
    }
  }

  void updateTrip(TripModel updatedTrip) {
    final currentData = state.value;
    if (currentData != null) {
      final index = currentData.indexWhere((t) => t.id == updatedTrip.id);
      if (index != -1) {
        final newList = [...currentData];
        newList[index] = updatedTrip;
        state = AsyncValue.data(newList);
      }
    }
  }

  void removeTrip(int tripId) {
    final currentData = state.value;
    if (currentData != null) {
      state =
          AsyncValue.data(currentData.where((t) => t.id != tripId).toList());
    }
  }
}

final tripDetailProvider =
    FutureProvider.family<TripDetailModel?, int>((ref, tripId) async {
  final repository = ref.watch(tripRepositoryProvider);
  try {
    final detail = await repository.getTripDetail(tripId);
    return detail;
  } catch (e) {
    rethrow;
  }
});

class TripDetailNotifier extends AsyncNotifier<TripDetailModel?> {
  TripDetailNotifier(this.tripId);

  final int tripId;

  @override
  Future<TripDetailModel?> build() async {
    return _loadDetail();
  }

  TripRepository get _repository => ref.read(tripRepositoryProvider);

  Future<TripDetailModel?> _loadDetail() async {
    final detail = await _repository.getTripDetail(tripId);
    return detail;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadDetail());
  }

  Future<void> addDestination(Map<String, dynamic> data) async {
    try {
      await _repository.addDestination(tripId, data);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDestination(int destinationId) async {
    try {
      await _repository.deleteDestination(destinationId);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setBudget(Map<String, dynamic> data) async {
    try {
      await _repository.setBudget(tripId, data);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addExpense(Map<String, dynamic> data) async {
    try {
      await _repository.addExpense(tripId, data);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  // 지출 삭제
  Future<void> deleteExpense(int expenseId) async {
    try {
      await _repository.deleteExpense(expenseId);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  // 여행 기록 추가
  Future<void> addTripLog(Map<String, dynamic> data) async {
    try {
      await _repository.addTripLog(tripId, data);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  // 여행 기록 삭제
  Future<void> deleteTripLog(int logId) async {
    try {
      await _repository.deleteTripLog(logId);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }
}

// ==================== 비교 분석 ====================

final tripComparisonProvider =
    FutureProvider.family<TripComparisonModel, int>((ref, tripId) async {
  final repository = ref.watch(tripRepositoryProvider);
  return repository.getComparison(tripId);
});

// ==================== 지출 요약 ====================

final expenseSummaryProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, tripId) async {
  final repository = ref.watch(tripRepositoryProvider);
  return repository.getExpenseSummary(tripId);
});

// ==================== 선택된 탭/일자 ====================

class SelectedDayNotifier extends Notifier<int> {
  @override
  int build() => 1;

  void setDay(int day) => state = day;
}

final selectedDayProvider = NotifierProvider<SelectedDayNotifier, int>(() {
  return SelectedDayNotifier();
});

class SelectedTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
}

final selectedTabIndexProvider =
    NotifierProvider<SelectedTabIndexNotifier, int>(() {
  return SelectedTabIndexNotifier();
});
