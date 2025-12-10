import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/trip_model.dart';

class ExpenseSection extends StatelessWidget {
  final TripDetailModel trip;
  final VoidCallback onAddExpense;

  const ExpenseSection(
      {super.key, required this.trip, required this.onAddExpense});

  @override
  Widget build(BuildContext context) {
    final allExpenses = <ExpenseModel>[];
    for (final day in trip.dayPlans) {
      allExpenses.addAll(day.expenses);
    }
    allExpenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

    final formatter = NumberFormat('#,###');

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('총 지출',
                      style: TextStyle(color: AppColors.textSecondary)),
                  Text('${formatter.format(trip.totalExpense)}원',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: onAddExpense,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('지출 추가'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: allExpenses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💸', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      const Text('아직 지출 기록이 없어요'),
                      const SizedBox(height: 8),
                      const Text('여행 중 지출을 기록해보세요',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: allExpenses.length,
                  itemBuilder: (ctx, i) =>
                      _buildExpenseCard(allExpenses[i], formatter),
                ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense, NumberFormat formatter) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(expense.category).withOpacity(0.1),
          child: Icon(_getCategoryIcon(expense.category),
              color: _getCategoryColor(expense.category), size: 20),
        ),
        title: Text(expense.description,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Row(
          children: [
            Text(expense.formattedDate),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(expense.category.label,
                  style: const TextStyle(fontSize: 10)),
            ),
            const SizedBox(width: 8),
            Text(expense.paymentMethod.label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        trailing: Text('${formatter.format(expense.amount)}원',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Color _getCategoryColor(BudgetCategory category) {
    switch (category) {
      case BudgetCategory.transport:
        return Colors.blue;
      case BudgetCategory.accommodation:
        return Colors.purple;
      case BudgetCategory.food:
        return Colors.orange;
      case BudgetCategory.attraction:
        return Colors.green;
      case BudgetCategory.shopping:
        return Colors.pink;
      case BudgetCategory.other:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(BudgetCategory category) {
    switch (category) {
      case BudgetCategory.transport:
        return Icons.directions_car;
      case BudgetCategory.accommodation:
        return Icons.hotel;
      case BudgetCategory.food:
        return Icons.restaurant;
      case BudgetCategory.attraction:
        return Icons.attractions;
      case BudgetCategory.shopping:
        return Icons.shopping_bag;
      case BudgetCategory.other:
        return Icons.more_horiz;
    }
  }
}
