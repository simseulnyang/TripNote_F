import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/trip_model.dart';
import '../repositories/trip_repository.dart';

class TripCreateScreen extends ConsumerStatefulWidget {
  const TripCreateScreen({super.key});

  @override
  ConsumerState<TripCreateScreen> createState() => _TripCreateScreenState();
}

class _TripCreateScreenState extends ConsumerState<TripCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 2));
  bool _isLoading = false;

  final Map<BudgetCategory, double> _budgets = {};

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 여행 만들기'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '여행 제목',
                hintText: '예: 제주도 가족여행',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (v) =>
                  v == null || v.trim().length < 2 ? '제목을 2자 이상 입력해주세요' : null,
            ),
            const SizedBox(height: 20),

            // 날짜 선택
            Row(
              children: [
                Expanded(
                    child: _buildDatePicker(
                        '시작일',
                        _startDate,
                        (d) => setState(() {
                              _startDate = d;
                              if (_endDate.isBefore(_startDate))
                                _endDate = _startDate;
                            }))),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildDatePicker(
                        '종료일', _endDate, (d) => setState(() => _endDate = d),
                        firstDate: _startDate)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_endDate.difference(_startDate).inDays + 1}일간의 여행',
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 설명
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '여행 설명 (선택)',
                hintText: '여행에 대한 간단한 설명을 적어보세요',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 24),

            // 예산 설정
            const Text('💰 예산 설정',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('카테고리별 예산을 설정해보세요 (선택)',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            ...BudgetCategory.values.map((cat) => _buildBudgetField(cat)),
            const SizedBox(height: 32),

            // 생성 버튼
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('여행 만들기',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(
      String label, DateTime date, Function(DateTime) onChanged,
      {DateTime? firstDate}) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: firstDate ?? DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(DateFormat('yyyy.MM.dd').format(date),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetField(BudgetCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(category.label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                suffixText: '원',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (v) {
                final amount = double.tryParse(v.replaceAll(',', '')) ?? 0;
                if (amount > 0) {
                  _budgets[category] = amount;
                } else {
                  _budgets.remove(category);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final budgetsList = _budgets.entries
          .where((e) => e.value > 0)
          .map((e) => <String, dynamic>{
                'category': e.key.value,
                'amount': e.value.round()
              })
          .toList();

      final request = TripCreateRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        startDate: _startDate,
        endDate: _endDate,
        budgets: budgetsList.isNotEmpty ? budgetsList : null,
      );

      final repo = TripRepository();
      await repo.createTrip(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('여행이 생성되었습니다! 🎉'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
