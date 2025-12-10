import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/trip_model.dart';
import '../repositories/trip_repository.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final TripDetailModel trip;
  const AddExpenseScreen({super.key, required this.trip});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _expenseDate;
  BudgetCategory _category = BudgetCategory.food;
  PaymentMethod _paymentMethod = PaymentMethod.card;
  int? _selectedDestinationId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _expenseDate = DateTime.now().isBefore(widget.trip.startDate)
        ? widget.trip.startDate
        : DateTime.now().isAfter(widget.trip.endDate)
            ? widget.trip.endDate
            : DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('지출 추가'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 금액
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: '금액 *',
                suffixText: '원',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return '금액을 입력해주세요';
                final amount = double.tryParse(v.replaceAll(',', ''));
                if (amount == null || amount <= 0) return '올바른 금액을 입력해주세요';
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: '내용 *',
                hintText: '예: 점심 식사',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '내용을 입력해주세요' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<BudgetCategory>(
              initialValue: _category,
              decoration: InputDecoration(
                  labelText: '카테고리',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
              items: BudgetCategory.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _category = v ?? BudgetCategory.food),
            ),
            const SizedBox(height: 16),

            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _expenseDate,
                  firstDate: widget.trip.startDate,
                  lastDate: widget.trip.endDate,
                );
                if (picked != null) setState(() => _expenseDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 12),
                    Text(DateFormat('yyyy.MM.dd (E)').format(_expenseDate)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<PaymentMethod>(
              initialValue: _paymentMethod,
              decoration: InputDecoration(
                  labelText: '결제 수단',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
              items: PaymentMethod.values
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _paymentMethod = v ?? PaymentMethod.card),
            ),
            const SizedBox(height: 16),

            if (widget.trip.destinations.isNotEmpty) ...[
              DropdownButtonFormField<int?>(
                initialValue: _selectedDestinationId,
                decoration: InputDecoration(
                    labelText: '연결된 여행지 (선택)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
                items: [
                  const DropdownMenuItem(value: null, child: Text('선택 안함')),
                  ...widget.trip.destinations.map((d) => DropdownMenuItem(
                      value: d.id, child: Text('Day${d.day} - ${d.name}'))),
                ],
                onChanged: (v) => setState(() => _selectedDestinationId = v),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('추가하기',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final amount =
          (double.parse(_amountController.text.replaceAll(',', ''))).toInt();
      final repo = TripRepository();
      await repo.addExpense(widget.trip.id, {
        'amount': amount,
        'description': _descriptionController.text.trim(),
        'category': _category.value,
        'expense_date': DateFormat('yyyy-MM-dd').format(_expenseDate),
        'payment_method': _paymentMethod.value,
        'destination': _selectedDestinationId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('지출이 추가되었습니다'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('오류: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
