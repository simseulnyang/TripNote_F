import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/trip_model.dart';

class DayPlanSection extends StatefulWidget {
  final TripDetailModel trip;
  final VoidCallback onAddDestination;

  const DayPlanSection(
      {super.key, required this.trip, required this.onAddDestination});

  @override
  State<DayPlanSection> createState() => _DayPlanSectionState();
}

class _DayPlanSectionState extends State<DayPlanSection> {
  int _selectedDay = 1;

  @override
  Widget build(BuildContext context) {
    final dayPlans = widget.trip.dayPlans;
    if (dayPlans.isEmpty) {
      return const Center(child: Text('일자별 계획이 없습니다'));
    }

    final currentDayPlan = dayPlans.firstWhere(
        (d) => d.dayNumber == _selectedDay,
        orElse: () => dayPlans.first);

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: dayPlans.length,
            itemBuilder: (ctx, i) {
              final day = dayPlans[i];
              final isSelected = day.dayNumber == _selectedDay;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('Day ${day.dayNumber}'),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedDay = day.dayNumber),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // 날짜 및 예상 비용
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('MM/dd (E)').format(currentDayPlan.date),
                  style: const TextStyle(color: AppColors.textSecondary)),
              Text(
                  '예상 비용: ${NumberFormat('#,###').format(currentDayPlan.estimatedCost)}원',
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 여행지 목록
        Expanded(
          child: currentDayPlan.destinations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📍', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      const Text('아직 여행지가 없어요'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: widget.onAddDestination,
                        icon: const Icon(Icons.add),
                        label: const Text('여행지 추가'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: currentDayPlan.destinations.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == currentDayPlan.destinations.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: OutlinedButton.icon(
                          onPressed: widget.onAddDestination,
                          icon: const Icon(Icons.add),
                          label: const Text('여행지 추가'),
                        ),
                      );
                    }
                    final dest = currentDayPlan.destinations[i];
                    return _buildDestinationCard(dest, i);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDestinationCard(DestinationModel dest, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                  child: Text('${index + 1}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(dest.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(dest.category.label,
                            style: const TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                  if (dest.address != null && dest.address!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(dest.address!,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (dest.estimatedDuration != null)
                        Text('${dest.estimatedDuration}분',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                      if (dest.estimatedDuration != null &&
                          dest.estimatedCost > 0)
                        const Text(' • ',
                            style: TextStyle(color: AppColors.textSecondary)),
                      if (dest.estimatedCost > 0)
                        Text(
                            '${NumberFormat('#,###').format(dest.estimatedCost)}원',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
