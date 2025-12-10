import '../../../core/network/api_client.dart';
import '../models/trip_model.dart';

class TripRepository {
  final ApiClient _apiClient;

  TripRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<TripModel>> getTrips() async {
    try {
      final response = await _apiClient.get('/trips/');
      if (response.data == null) {
        return [];
      }

      List<dynamic> data;
      if (response.data is Map && response.data['results'] != null) {
        data = response.data['results'] as List<dynamic>;
      } else if (response.data is List) {
        data = response.data as List<dynamic>;
      } else {
        return [];
      }

      return data
          .map((json) => TripModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<TripDetailModel> getTripDetail(int tripId) async {
    final response = await _apiClient.get('/trips/$tripId/');
    return TripDetailModel.fromJson(response.data);
  }

  Future<TripDetailModel> createTrip(TripCreateRequest request) async {
    final response = await _apiClient.post('/trips/', data: request.toJson());
    return TripDetailModel.fromJson(response.data);
  }

  Future<TripDetailModel> updateTrip(
      int tripId, Map<String, dynamic> data) async {
    final response = await _apiClient.patch('/trips/$tripId/', data: data);
    return TripDetailModel.fromJson(response.data);
  }

  Future<void> deleteTrip(int tripId) async {
    await _apiClient.delete('/trips/$tripId/');
  }

  Future<List<DestinationModel>> getDestinations(int tripId) async {
    final response = await _apiClient.get('/trips/$tripId/destinations/');
    final List<dynamic> data = response.data;
    return data.map((json) => DestinationModel.fromJson(json)).toList();
  }

  Future<DestinationModel> addDestination(
      int tripId, Map<String, dynamic> data) async {
    final response =
        await _apiClient.post('/trips/$tripId/destinations/', data: data);
    return DestinationModel.fromJson(response.data);
  }

  Future<DestinationModel> updateDestination(
      int destinationId, Map<String, dynamic> data) async {
    final response = await _apiClient
        .patch('/trips/destinations/$destinationId/', data: data);
    return DestinationModel.fromJson(response.data);
  }

  Future<void> deleteDestination(int destinationId) async {
    await _apiClient.delete('/trips/destinations/$destinationId/');
  }

  Future<List<DayPlanModel>> getDayPlans(int tripId) async {
    final response = await _apiClient.get('/trips/$tripId/days/');
    final List<dynamic> data = response.data;
    return data.map((json) => DayPlanModel.fromJson(json)).toList();
  }

  Future<DayPlanModel> updateDayPlan(
      int tripId, int dayNumber, String memo) async {
    final response = await _apiClient.patch(
      '/trips/$tripId/days/$dayNumber/',
      data: {'memo': memo},
    );
    return DayPlanModel.fromJson(response.data);
  }

  Future<List<BudgetModel>> getBudgets(int tripId) async {
    final response = await _apiClient.get('/trips/$tripId/budgets/');
    final List<dynamic> data = response.data;
    return data.map((json) => BudgetModel.fromJson(json)).toList();
  }

  Future<BudgetModel> setBudget(int tripId, Map<String, dynamic> data) async {
    final response =
        await _apiClient.post('/trips/$tripId/budgets/', data: data);
    return BudgetModel.fromJson(response.data);
  }

  Future<Map<String, dynamic>> getBudgetSummary(int tripId) async {
    final response = await _apiClient.get('/trips/$tripId/budgets/summary/');
    return response.data;
  }

  Future<List<ExpenseModel>> getExpenses(int tripId) async {
    final response = await _apiClient.get('/trips/$tripId/expenses/');
    final List<dynamic> data = response.data;
    return data.map((json) => ExpenseModel.fromJson(json)).toList();
  }

  Future<ExpenseModel> addExpense(int tripId, Map<String, dynamic> data) async {
    final response =
        await _apiClient.post('/trips/$tripId/expenses/', data: data);
    return ExpenseModel.fromJson(response.data);
  }

  Future<ExpenseModel> updateExpense(
      int expenseId, Map<String, dynamic> data) async {
    final response =
        await _apiClient.patch('/trips/expenses/$expenseId/', data: data);
    return ExpenseModel.fromJson(response.data);
  }

  Future<void> deleteExpense(int expenseId) async {
    await _apiClient.delete('/trips/expenses/$expenseId/');
  }

  Future<Map<String, dynamic>> getExpenseSummary(int tripId) async {
    final response = await _apiClient.get('/trips/$tripId/expenses/summary/');
    return response.data;
  }

  Future<List<TripLogModel>> getTripLogs(int tripId) async {
    final response = await _apiClient.get('/trips/$tripId/logs/');
    final List<dynamic> data = response.data;
    return data.map((json) => TripLogModel.fromJson(json)).toList();
  }

  Future<TripLogModel> addTripLog(int tripId, Map<String, dynamic> data) async {
    final response = await _apiClient.post('/trips/$tripId/logs/', data: data);
    return TripLogModel.fromJson(response.data);
  }

  Future<TripLogModel> updateTripLog(
      int logId, Map<String, dynamic> data) async {
    final response = await _apiClient.patch('/trips/logs/$logId/', data: data);
    return TripLogModel.fromJson(response.data);
  }

  Future<void> deleteTripLog(int logId) async {
    await _apiClient.delete('/trips/logs/$logId/');
  }

  Future<TripComparisonModel> getComparison(int tripId) async {
    final response = await _apiClient.get('/trips/$tripId/comparison/');
    return TripComparisonModel.fromJson(response.data);
  }
}
