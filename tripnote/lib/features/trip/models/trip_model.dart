import 'package:intl/intl.dart';

/// 예산/지출 카테고리
enum BudgetCategory {
  transport('transport', '교통'),
  accommodation('accommodation', '숙소'),
  food('food', '식비'),
  attraction('attraction', '관광/입장료'),
  shopping('shopping', '쇼핑'),
  other('other', '기타');

  final String value;
  final String label;
  const BudgetCategory(this.value, this.label);

  static BudgetCategory fromString(String value) {
    return BudgetCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BudgetCategory.other,
    );
  }
}

/// 여행지 카테고리
enum DestinationCategory {
  attraction('attraction', '관광지'),
  restaurant('restaurant', '음식점'),
  cafe('cafe', '카페'),
  accommodation('accommodation', '숙소'),
  shopping('shopping', '쇼핑'),
  transport('transport', '교통'),
  other('other', '기타');

  final String value;
  final String label;
  const DestinationCategory(this.value, this.label);

  static DestinationCategory fromString(String value) {
    return DestinationCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DestinationCategory.other,
    );
  }
}

/// 결제 수단
enum PaymentMethod {
  cash('cash', '현금'),
  card('card', '카드'),
  other('other', '기타');

  final String value;
  final String label;
  const PaymentMethod(this.value, this.label);

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethod.card,
    );
  }
}

/// 여행 상태
enum TripStatus {
  planning('planning', '계획 중'),
  ongoing('ongoing', '여행 중'),
  completed('completed', '완료');

  final String value;
  final String label;
  const TripStatus(this.value, this.label);

  static TripStatus fromString(String value) {
    return TripStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TripStatus.planning,
    );
  }
}

/// 방문 상태
enum VisitStatus {
  planned('planned', '계획대로 방문'),
  unplanned('unplanned', '계획에 없던 방문'),
  skipped('skipped', '계획했지만 미방문');

  final String value;
  final String label;
  const VisitStatus(this.value, this.label);

  static VisitStatus fromString(String value) {
    return VisitStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => VisitStatus.planned,
    );
  }
}

/// 여행 일정 모델
class TripModel {
  final int id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String? thumbnail;
  final TripStatus status;
  final bool isPublic;
  final List<String> destinationNames;
  final int destinationCount;
  final double totalBudget;
  final double totalExpense;
  final double budgetUsagePercent;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TripModel({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.thumbnail,
    required this.status,
    required this.isPublic,
    required this.destinationNames,
    required this.destinationCount,
    required this.totalBudget,
    required this.totalExpense,
    required this.budgetUsagePercent,
    required this.createdAt,
    this.updatedAt,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      thumbnail: json['thumbnail'] as String?,
      status: TripStatus.fromString(json['status'] ?? 'planning'),
      isPublic: json['is_public'] as bool? ?? false,
      destinationNames: List<String>.from(json['destination_names'] ?? []),
      destinationCount: (json['destination_count'] as int?) ?? 0,
      totalBudget: _parseDouble(json['total_budget']),
      totalExpense: _parseDouble(json['total_expense']),
      budgetUsagePercent: _parseDouble(json['budget_usage_percent']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// null-safe double 파싱 헬퍼
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': DateFormat('yyyy-MM-dd').format(startDate),
      'end_date': DateFormat('yyyy-MM-dd').format(endDate),
      'thumbnail': thumbnail,
      'status': status.value,
      'is_public': isPublic,
    };
  }

  int get durationDays => endDate.difference(startDate).inDays + 1;

  String get formattedDateRange {
    final startFormatted = DateFormat('yyyy.MM.dd').format(startDate);
    final endFormatted = DateFormat('MM.dd').format(endDate);
    return '$startFormatted - $endFormatted';
  }

  double get budgetRemaining => totalBudget - totalExpense;

  TripModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? thumbnail,
    TripStatus? status,
    bool? isPublic,
    List<String>? destinationNames,
    int? destinationCount,
    double? totalBudget,
    double? totalExpense,
    double? budgetUsagePercent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      thumbnail: thumbnail ?? this.thumbnail,
      status: status ?? this.status,
      isPublic: isPublic ?? this.isPublic,
      destinationNames: destinationNames ?? this.destinationNames,
      destinationCount: destinationCount ?? this.destinationCount,
      totalBudget: totalBudget ?? this.totalBudget,
      totalExpense: totalExpense ?? this.totalExpense,
      budgetUsagePercent: budgetUsagePercent ?? this.budgetUsagePercent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 여행 상세 모델
class TripDetailModel extends TripModel {
  final List<DestinationModel> destinations;
  final List<DayPlanModel> dayPlans;
  final List<BudgetModel> budgets;
  final double totalEstimatedCost;
  @override
  final double budgetRemaining;

  TripDetailModel({
    required super.id,
    required super.title,
    super.description,
    required super.startDate,
    required super.endDate,
    super.thumbnail,
    required super.status,
    required super.isPublic,
    required super.destinationNames,
    required super.destinationCount,
    required super.totalBudget,
    required super.totalExpense,
    required super.budgetUsagePercent,
    required super.createdAt,
    super.updatedAt,
    required this.destinations,
    required this.dayPlans,
    required this.budgets,
    required this.totalEstimatedCost,
    required this.budgetRemaining,
  });

  factory TripDetailModel.fromJson(Map<String, dynamic> json) {
    return TripDetailModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      thumbnail: json['thumbnail'] as String?,
      status: TripStatus.fromString(json['status'] ?? 'planning'),
      isPublic: json['is_public'] as bool? ?? false,
      destinationNames: (json['destinations'] as List?)
              ?.map((d) => d['name'] as String)
              .toList() ??
          [],
      destinationCount: (json['destinations'] as List?)?.length ?? 0,
      totalBudget: TripModel._parseDouble(json['total_budget']),
      totalExpense: TripModel._parseDouble(json['total_expense']),
      budgetUsagePercent: TripModel._parseDouble(json['budget_usage_percent']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      destinations: (json['destinations'] as List?)
              ?.map((d) => DestinationModel.fromJson(d))
              .toList() ??
          [],
      dayPlans: (json['day_plans'] as List?)
              ?.map((d) => DayPlanModel.fromJson(d))
              .toList() ??
          [],
      budgets: (json['budgets'] as List?)
              ?.map((b) => BudgetModel.fromJson(b))
              .toList() ??
          [],
      totalEstimatedCost: TripModel._parseDouble(json['total_estimated_cost']),
      budgetRemaining: TripModel._parseDouble(json['budget_remaining']),
    );
  }
}

/// 여행지 모델
class DestinationModel {
  final int id;
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int day;
  final int order;
  final String? plannedTime;
  final int? estimatedDuration;
  final double estimatedCost;
  final DestinationCategory category;
  final String? memo;
  final DateTime? createdAt;

  DestinationModel({
    required this.id,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    required this.day,
    required this.order,
    this.plannedTime,
    this.estimatedDuration,
    required this.estimatedCost,
    required this.category,
    this.memo,
    this.createdAt,
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    return DestinationModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      day: json['day'] as int? ?? 1,
      order: json['order'] as int? ?? 0,
      plannedTime: json['planned_time'] as String?,
      estimatedDuration: json['estimated_duration'] as int?,
      estimatedCost: TripModel._parseDouble(json['estimated_cost']),
      category: DestinationCategory.fromString(json['category'] ?? 'other'),
      memo: json['memo'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'day': day,
      'order': order,
      'planned_time': plannedTime,
      'estimated_duration': estimatedDuration,
      'estimated_cost': estimatedCost,
      'category': category.value,
      'memo': memo,
    };
  }

  DestinationModel copyWith({
    int? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? day,
    int? order,
    String? plannedTime,
    int? estimatedDuration,
    double? estimatedCost,
    DestinationCategory? category,
    String? memo,
    DateTime? createdAt,
  }) {
    return DestinationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      day: day ?? this.day,
      order: order ?? this.order,
      plannedTime: plannedTime ?? this.plannedTime,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      category: category ?? this.category,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 일자별 계획 모델
class DayPlanModel {
  final int id;
  final int dayNumber;
  final DateTime date;
  final String? memo;
  final double estimatedCost;
  final List<DestinationModel> destinations;
  final List<ExpenseModel> expenses;
  final List<TripLogModel> logs;

  DayPlanModel({
    required this.id,
    required this.dayNumber,
    required this.date,
    this.memo,
    required this.estimatedCost,
    required this.destinations,
    required this.expenses,
    required this.logs,
  });

  factory DayPlanModel.fromJson(Map<String, dynamic> json) {
    return DayPlanModel(
      id: json['id'] as int,
      dayNumber: json['day_number'] as int,
      date: DateTime.parse(json['date'] as String),
      memo: json['memo'] as String?,
      estimatedCost: TripModel._parseDouble(json['estimated_cost']),
      destinations: (json['destinations'] as List?)
              ?.map((d) => DestinationModel.fromJson(d))
              .toList() ??
          [],
      expenses: (json['expenses'] as List?)
              ?.map((e) => ExpenseModel.fromJson(e))
              .toList() ??
          [],
      logs: (json['logs'] as List?)
              ?.map((l) => TripLogModel.fromJson(l))
              .toList() ??
          [],
    );
  }

  String get formattedDate => DateFormat('MM/dd (E)').format(date);

  double get totalExpense => expenses.fold(0, (sum, e) => sum + e.amount);
}

/// 예산 모델
class BudgetModel {
  final int? id;
  final BudgetCategory category;
  final double amount;
  final String? memo;
  final double spentAmount;
  final double remainingAmount;
  final double usagePercent;

  BudgetModel({
    this.id,
    required this.category,
    required this.amount,
    this.memo,
    this.spentAmount = 0,
    this.remainingAmount = 0,
    this.usagePercent = 0,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as int?,
      category: BudgetCategory.fromString(json['category'] as String),
      amount: TripModel._parseDouble(json['amount']),
      memo: json['memo'] as String?,
      spentAmount: TripModel._parseDouble(json['spent_amount']),
      remainingAmount: TripModel._parseDouble(json['remaining_amount']),
      usagePercent: TripModel._parseDouble(json['usage_percent']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.value,
      'amount': amount,
      'memo': memo,
    };
  }
}

/// 지출 모델
class ExpenseModel {
  final int? id;
  final BudgetCategory category;
  final double amount;
  final String description;
  final DateTime expenseDate;
  final String? expenseTime;
  final int? dayNumber;
  final int? destinationId;
  final String? destinationName;
  final PaymentMethod paymentMethod;
  final String? receiptImage;

  ExpenseModel({
    this.id,
    required this.category,
    required this.amount,
    required this.description,
    required this.expenseDate,
    this.expenseTime,
    this.dayNumber,
    this.destinationId,
    this.destinationName,
    required this.paymentMethod,
    this.receiptImage,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as int?,
      category: BudgetCategory.fromString(json['category'] as String),
      amount: TripModel._parseDouble(json['amount']),
      description: json['description'] as String,
      expenseDate: DateTime.parse(json['expense_date'] as String),
      expenseTime: json['expense_time'] as String?,
      dayNumber: json['day_number'] as int?,
      destinationId: json['destination'] as int?,
      destinationName: json['destination_name'] as String?,
      paymentMethod: PaymentMethod.fromString(json['payment_method'] ?? 'card'),
      receiptImage: json['receipt_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.value,
      'amount': amount,
      'description': description,
      'expense_date': DateFormat('yyyy-MM-dd').format(expenseDate),
      'expense_time': expenseTime,
      'destination': destinationId,
      'payment_method': paymentMethod.value,
      'receipt_image': receiptImage,
    };
  }

  String get formattedDate => DateFormat('MM/dd').format(expenseDate);
  String get formattedAmount => NumberFormat('#,###').format(amount);
}

/// 여행 기록 사진 모델
class TripLogPhotoModel {
  final int id;
  final String imageUrl;
  final String? caption;
  final int order;

  TripLogPhotoModel({
    required this.id,
    required this.imageUrl,
    this.caption,
    required this.order,
  });

  factory TripLogPhotoModel.fromJson(Map<String, dynamic> json) {
    return TripLogPhotoModel(
      id: json['id'] as int,
      imageUrl: json['image_url'] as String,
      caption: json['caption'] as String?,
      order: json['order'] as int? ?? 0,
    );
  }
}

/// 여행 기록 모델
class TripLogModel {
  final int? id;
  final int? destinationId;
  final String? destinationName;
  final String placeName;
  final String? address;
  final double? latitude;
  final double? longitude;
  final DateTime visitDate;
  final String? visitTime;
  final int? dayNumber;
  final int? actualDuration;
  final int? rating;
  final String? review;
  final VisitStatus visitStatus;
  final List<TripLogPhotoModel> photos;

  TripLogModel({
    this.id,
    this.destinationId,
    this.destinationName,
    required this.placeName,
    this.address,
    this.latitude,
    this.longitude,
    required this.visitDate,
    this.visitTime,
    this.dayNumber,
    this.actualDuration,
    this.rating,
    this.review,
    required this.visitStatus,
    this.photos = const [],
  });

  factory TripLogModel.fromJson(Map<String, dynamic> json) {
    return TripLogModel(
      id: json['id'] as int?,
      destinationId: json['destination'] as int?,
      destinationName: json['destination_name'] as String?,
      placeName: json['place_name'] as String,
      address: json['address'] as String?,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      visitDate: DateTime.parse(json['visit_date'] as String),
      visitTime: json['visit_time'] as String?,
      dayNumber: json['day_number'] as int?,
      actualDuration: json['actual_duration'] as int?,
      rating: json['rating'] as int?,
      review: json['review'] as String?,
      visitStatus: VisitStatus.fromString(json['visit_status'] ?? 'planned'),
      photos: (json['photos'] as List?)
              ?.map((p) => TripLogPhotoModel.fromJson(p))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination': destinationId,
      'place_name': placeName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'visit_date': DateFormat('yyyy-MM-dd').format(visitDate),
      'visit_time': visitTime,
      'actual_duration': actualDuration,
      'rating': rating,
      'review': review,
      'visit_status': visitStatus.value,
    };
  }

  String get formattedDate => DateFormat('MM/dd').format(visitDate);
}

/// 비교 분석 모델
class TripComparisonModel {
  final List<BudgetComparisonItem> budgetComparison;
  final List<ScheduleComparisonItem> scheduleComparison;
  final ComparisonSummary summary;

  TripComparisonModel({
    required this.budgetComparison,
    required this.scheduleComparison,
    required this.summary,
  });

  factory TripComparisonModel.fromJson(Map<String, dynamic> json) {
    return TripComparisonModel(
      budgetComparison: (json['budget_comparison'] as List?)
              ?.map((b) => BudgetComparisonItem.fromJson(b))
              .toList() ??
          [],
      scheduleComparison: (json['schedule_comparison'] as List?)
              ?.map((s) => ScheduleComparisonItem.fromJson(s))
              .toList() ??
          [],
      summary: ComparisonSummary.fromJson(json['summary'] ?? {}),
    );
  }
}

class BudgetComparisonItem {
  final String category;
  final String categoryDisplay;
  final double budget;
  final double actual;
  final double difference;
  final double usagePercent;

  BudgetComparisonItem({
    required this.category,
    required this.categoryDisplay,
    required this.budget,
    required this.actual,
    required this.difference,
    required this.usagePercent,
  });

  factory BudgetComparisonItem.fromJson(Map<String, dynamic> json) {
    return BudgetComparisonItem(
      category: json['category'] as String,
      categoryDisplay: json['category_display'] as String,
      budget: TripModel._parseDouble(json['budget']),
      actual: TripModel._parseDouble(json['actual']),
      difference: TripModel._parseDouble(json['difference']),
      usagePercent: TripModel._parseDouble(json['usage_percent']),
    );
  }
}

class ScheduleComparisonItem {
  final int dayNumber;
  final DateTime date;
  final int plannedCount;
  final int actualCount;
  final List<String> plannedPlaces;
  final List<String> actualPlaces;
  final List<String> visitedAsPlanned;
  final List<String> skipped;
  final List<String> unplannedVisits;

  ScheduleComparisonItem({
    required this.dayNumber,
    required this.date,
    required this.plannedCount,
    required this.actualCount,
    required this.plannedPlaces,
    required this.actualPlaces,
    required this.visitedAsPlanned,
    required this.skipped,
    required this.unplannedVisits,
  });

  factory ScheduleComparisonItem.fromJson(Map<String, dynamic> json) {
    return ScheduleComparisonItem(
      dayNumber: json['day_number'] as int,
      date: DateTime.parse(json['date'] as String),
      plannedCount: json['planned_count'] as int? ?? 0,
      actualCount: json['actual_count'] as int? ?? 0,
      plannedPlaces: List<String>.from(json['planned_places'] ?? []),
      actualPlaces: List<String>.from(json['actual_places'] ?? []),
      visitedAsPlanned: List<String>.from(json['visited_as_planned'] ?? []),
      skipped: List<String>.from(json['skipped'] ?? []),
      unplannedVisits: List<String>.from(json['unplanned_visits'] ?? []),
    );
  }
}

class ComparisonSummary {
  final double totalBudget;
  final double totalExpense;
  final double budgetRemaining;
  final double budgetUsagePercent;
  final double totalEstimatedCost;
  final double estimatedVsActualDiff;
  final int totalPlannedPlaces;
  final int totalVisitedPlaces;
  final int plannedAndVisited;
  final int unplannedVisits;
  final double planCompletionRate;
  final double? averageRating;

  ComparisonSummary({
    required this.totalBudget,
    required this.totalExpense,
    required this.budgetRemaining,
    required this.budgetUsagePercent,
    required this.totalEstimatedCost,
    required this.estimatedVsActualDiff,
    required this.totalPlannedPlaces,
    required this.totalVisitedPlaces,
    required this.plannedAndVisited,
    required this.unplannedVisits,
    required this.planCompletionRate,
    this.averageRating,
  });

  factory ComparisonSummary.fromJson(Map<String, dynamic> json) {
    return ComparisonSummary(
      totalBudget: TripModel._parseDouble(json['total_budget']),
      totalExpense: TripModel._parseDouble(json['total_expense']),
      budgetRemaining: TripModel._parseDouble(json['budget_remaining']),
      budgetUsagePercent: TripModel._parseDouble(json['budget_usage_percent']),
      totalEstimatedCost: TripModel._parseDouble(json['total_estimated_cost']),
      estimatedVsActualDiff:
          TripModel._parseDouble(json['estimated_vs_actual_diff']),
      totalPlannedPlaces: json['total_planned_places'] as int? ?? 0,
      totalVisitedPlaces: json['total_visited_places'] as int? ?? 0,
      plannedAndVisited: json['planned_and_visited'] as int? ?? 0,
      unplannedVisits: json['unplanned_visits'] as int? ?? 0,
      planCompletionRate: TripModel._parseDouble(json['plan_completion_rate']),
      averageRating: json['average_rating'] != null
          ? TripModel._parseDouble(json['average_rating'])
          : null,
    );
  }
}

/// 여행 생성 요청 모델
class TripCreateRequest {
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String? thumbnail;
  final bool isPublic;
  final List<Map<String, dynamic>>? destinations;
  final List<Map<String, dynamic>>? budgets;

  TripCreateRequest({
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.thumbnail,
    this.isPublic = false,
    this.destinations,
    this.budgets,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'start_date': DateFormat('yyyy-MM-dd').format(startDate),
      'end_date': DateFormat('yyyy-MM-dd').format(endDate),
      'is_public': isPublic,
    };

    // null이 아닌 경우에만 포함
    if (description != null && description!.isNotEmpty) {
      map['description'] = description;
    }
    if (thumbnail != null && thumbnail!.isNotEmpty) {
      map['thumbnail'] = thumbnail;
    }
    if (destinations != null && destinations!.isNotEmpty) {
      map['destinations'] = destinations;
    }
    if (budgets != null && budgets!.isNotEmpty) {
      map['budgets'] = budgets;
    }

    return map;
  }
}
