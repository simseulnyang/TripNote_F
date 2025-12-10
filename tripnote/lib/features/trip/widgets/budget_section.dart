import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/trip_model.dart';

class BudgetSection extends StatelessWidget {
  final TripDetailModel trip;
  final Function(BudgetCategory, double) onSetBudget;

  const BudgetSection(
      {super.key, required this.trip, required this.onSetBudget});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem('총 예산',
                        formatter.format(trip.totalBudget), AppColors.primary),
                    _buildSummaryItem('총 지출',
                        formatter.format(trip.totalExpense), Colors.orange),
                    _buildSummaryItem(
                        '잔액',
                        formatter.format(trip.budgetRemaining),
                        trip.budgetRemaining >= 0 ? Colors.green : Colors.red),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: trip.totalBudget > 0
                        ? (trip.totalExpense / trip.totalBudget).clamp(0.0, 1.0)
                        : 0,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                        trip.budgetUsagePercent > 100
                            ? Colors.red
                            : AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text('${trip.budgetUsagePercent.toStringAsFixed(1)}% 사용',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 카테고리별 예산
        const Text('카테고리별 예산',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...BudgetCategory.values.map((cat) {
          final budget =
              trip.budgets.where((b) => b.category == cat).firstOrNull;
          return _buildCategoryCard(context, cat, budget, formatter);
        }),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text('$value원',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, BudgetCategory category,
      BudgetModel? budget, NumberFormat formatter) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showBudgetDialog(context, category, budget?.amount ?? 0),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(category.label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                  if (budget != null)
                    Text('${budget.usagePercent.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: budget.usagePercent > 100
                              ? Colors.red
                              : Colors.green,
                        )),
                ],
              ),
              const SizedBox(height: 8),
              if (budget != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('예산: ${formatter.format(budget.amount)}원',
                        style: const TextStyle(color: AppColors.textSecondary)),
                    Text('지출: ${formatter.format(budget.spentAmount)}원',
                        style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: budget.amount > 0
                        ? (budget.spentAmount / budget.amount).clamp(0.0, 1.0)
                        : 0,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(budget.usagePercent > 100
                        ? Colors.red
                        : AppColors.primary),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    const Icon(Icons.add_circle_outline,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    const Text('예산 설정하기',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showBudgetDialog(
      BuildContext context, BudgetCategory category, double currentAmount) {
    final controller = TextEditingController(
        text: currentAmount > 0 ? currentAmount.toStringAsFixed(0) : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${category.label} 예산 설정'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '예산 금액',
            suffixText: '원',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              final amount =
                  double.tryParse(controller.text.replaceAll(',', '')) ?? 0;
              onSetBudget(category, amount);
              Navigator.pop(ctx);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
