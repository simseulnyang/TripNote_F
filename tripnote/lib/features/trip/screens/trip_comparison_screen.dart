import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/trip_model.dart';
import '../providers/trip_provider.dart';

class TripComparisonScreen extends ConsumerWidget {
  final int tripId;
  const TripComparisonScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonAsync = ref.watch(tripComparisonProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('계획 vs 실제'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: comparisonAsync.when(
        data: (data) => _buildContent(context, data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TripComparisonModel data) {
    final formatter = NumberFormat('#,###');
    final summary = data.summary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 전체 요약 카드
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📊 전체 요약',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                _buildSummaryRow(
                    '총 예산', '${formatter.format(summary.totalBudget)}원'),
                _buildSummaryRow(
                    '총 지출', '${formatter.format(summary.totalExpense)}원'),
                _buildSummaryRow(
                    '남은 예산', '${formatter.format(summary.budgetRemaining)}원',
                    color: summary.budgetRemaining >= 0
                        ? Colors.green
                        : Colors.red),
                _buildSummaryRow('예산 사용률',
                    '${summary.budgetUsagePercent.toStringAsFixed(1)}%'),
                const Divider(),
                _buildSummaryRow('계획한 장소', '${summary.totalPlannedPlaces}곳'),
                _buildSummaryRow('방문한 장소', '${summary.totalVisitedPlaces}곳'),
                _buildSummaryRow('계획 완료율',
                    '${summary.planCompletionRate.toStringAsFixed(1)}%'),
                if (summary.averageRating != null)
                  _buildSummaryRow('평균 평점',
                      '${summary.averageRating!.toStringAsFixed(1)} ⭐'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 예산 비교
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💰 카테고리별 예산 비교',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...data.budgetComparison
                    .map((item) => _buildBudgetBar(item, formatter)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 일정 비교
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📅 일자별 일정 비교',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...data.scheduleComparison
                    .map((item) => _buildScheduleItem(item)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildBudgetBar(BudgetComparisonItem item, NumberFormat formatter) {
    final progress =
        item.budget > 0 ? (item.actual / item.budget).clamp(0.0, 1.5) : 0.0;
    final isOver = item.actual > item.budget;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.categoryDisplay,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('${item.usagePercent.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: isOver ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.toDouble(),
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                  isOver ? Colors.red : AppColors.primary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${formatter.format(item.actual)} / ${formatter.format(item.budget)}원',
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(ScheduleComparisonItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Day ${item.dayNumber}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text(DateFormat('MM/dd').format(item.date),
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatChip('계획', item.plannedCount, Colors.blue),
              const SizedBox(width: 8),
              _buildStatChip('방문', item.actualCount, Colors.green),
            ],
          ),
          if (item.visitedAsPlanned.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: item.visitedAsPlanned
                  .map((p) => Chip(
                        label: Text(p, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.green.shade50,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
          if (item.skipped.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('❌ 미방문: ${item.skipped.join(', ')}',
                style: const TextStyle(fontSize: 12, color: Colors.red)),
          ],
          if (item.unplannedVisits.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('✨ 즉흥 방문: ${item.unplannedVisits.join(', ')}',
                style: const TextStyle(fontSize: 12, color: Colors.orange)),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$label $count곳',
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }
}
