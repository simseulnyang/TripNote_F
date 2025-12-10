import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/trip_model.dart';
import '../providers/trip_provider.dart';
import '../repositories/trip_repository.dart';
import '../widgets/budget_section.dart';
import '../widgets/expense_section.dart';
import '../widgets/day_plan_section.dart';
import 'trip_comparison_screen.dart';
import 'add_destination_screen.dart';
import 'add_expense_screen.dart';
import 'add_log_screen.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final int tripId;
  const TripDetailScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripDetailProvider(widget.tripId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: tripAsync.when(
        data: (trip) => trip == null
            ? const Center(child: Text('여행을 찾을 수 없습니다'))
            : _buildContent(trip),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 16),
          Text('오류: $e'),
          TextButton(
            onPressed: () => ref.invalidate(tripDetailProvider(widget.tripId)),
            child: const Text('다시 시도'),
          ),
        ])),
      ),
    );
  }

  Widget _buildContent(TripDetailModel trip) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: innerBoxIsScrolled ? Text(trip.title) : null,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8)
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Colors.white70, size: 16),
                          const SizedBox(width: 8),
                          Text(trip.formattedDateRange,
                              style: const TextStyle(color: Colors.white70)),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('${trip.durationDays}일',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _buildBudgetSummary(trip),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TripComparisonScreen(tripId: trip.id))),
              tooltip: '계획 vs 실제 비교',
            ),
            PopupMenuButton<String>(
              onSelected: (v) => _handleMenuAction(v, trip),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('수정')),
                const PopupMenuItem(
                    value: 'delete',
                    child: Text('삭제', style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: '일정'),
                Tab(text: '예산'),
                Tab(text: '지출'),
                Tab(text: '기록'),
              ],
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          DayPlanSection(
              trip: trip, onAddDestination: () => _addDestination(trip)),
          BudgetSection(trip: trip, onSetBudget: _setBudget),
          ExpenseSection(trip: trip, onAddExpense: () => _addExpense(trip)),
          _buildLogsTab(trip),
        ],
      ),
    );
  }

  Widget _buildBudgetSummary(TripDetailModel trip) {
    final formatter = NumberFormat('#,###');
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('예산',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text('${formatter.format(trip.totalBudget)}원',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(width: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('지출',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text('${formatter.format(trip.totalExpense)}원',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(width: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('사용률',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text('${trip.budgetUsagePercent.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: trip.budgetUsagePercent > 100
                      ? Colors.red.shade200
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildLogsTab(TripDetailModel trip) {
    final logs = <TripLogModel>[];
    for (final day in trip.dayPlans) {
      logs.addAll(day.logs);
    }

    if (logs.isEmpty) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('📝', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        const Text('아직 여행 기록이 없어요'),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _addLog(trip),
          icon: const Icon(Icons.add),
          label: const Text('기록 추가'),
        ),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: () => _addLog(trip),
              icon: const Icon(Icons.add),
              label: const Text('기록 추가'),
            ),
          );
        }
        final log = logs[i - 1];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(log.rating?.toString() ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(log.placeName),
            subtitle: Text('${log.formattedDate} • ${log.visitStatus.label}'),
            trailing: log.rating != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                        5,
                        (idx) => Icon(
                              idx < log.rating!
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            )),
                  )
                : null,
          ),
        );
      },
    );
  }

  void _handleMenuAction(String action, TripDetailModel trip) async {
    if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('여행 삭제'),
          content: const Text('정말로 이 여행을 삭제하시겠습니까?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('취소')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('삭제', style: TextStyle(color: Colors.red))),
          ],
        ),
      );
      if (confirm == true) {
        try {
          final repo = TripRepository();
          await repo.deleteTrip(trip.id);
          if (mounted) {
            Navigator.pop(context);
            ref.read(tripListProvider.notifier).removeTrip(trip.id);
          }
        } catch (e) {
          if (mounted)
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
        }
      }
    }
  }

  void _addDestination(TripDetailModel trip) async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (_) => AddDestinationScreen(trip: trip)));
    if (result == true) ref.invalidate(tripDetailProvider(widget.tripId));
  }

  void _setBudget(BudgetCategory category, double amount) async {
    try {
      final repo = ref.read(tripRepositoryProvider);
      await repo.setBudget(widget.tripId, {
        'category': category.value,
        'amount': amount,
      });
      ref.invalidate(tripDetailProvider(widget.tripId));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('예산 설정 실패: $e')));
    }
  }

  void _addExpense(TripDetailModel trip) async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (_) => AddExpenseScreen(trip: trip)));
    if (result == true) ref.invalidate(tripDetailProvider(widget.tripId));
  }

  void _addLog(TripDetailModel trip) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => AddLogScreen(trip: trip)));
    if (result == true) ref.invalidate(tripDetailProvider(widget.tripId));
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
