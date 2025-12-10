import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../models/trip_model.dart';
import '../repositories/trip_repository.dart';

class AddDestinationScreen extends ConsumerStatefulWidget {
  final TripDetailModel trip;
  const AddDestinationScreen({super.key, required this.trip});

  @override
  ConsumerState<AddDestinationScreen> createState() =>
      _AddDestinationScreenState();
}

class _AddDestinationScreenState extends ConsumerState<AddDestinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _memoController = TextEditingController();
  final _costController = TextEditingController();

  int _selectedDay = 1;
  DestinationCategory _category = DestinationCategory.attraction;
  int? _duration;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _memoController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('여행지 추가'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '장소명 *',
                hintText: '예: 성산일출봉',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '장소명을 입력해주세요' : null,
            ),
            const SizedBox(height: 16),

            // 일차 선택
            DropdownButtonFormField<int>(
              initialValue: _selectedDay,
              decoration: InputDecoration(
                  labelText: '일차',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
              items: List.generate(
                  widget.trip.durationDays,
                  (i) => DropdownMenuItem(
                      value: i + 1, child: Text('Day ${i + 1}'))),
              onChanged: (v) => setState(() => _selectedDay = v ?? 1),
            ),
            const SizedBox(height: 16),

            // 카테고리
            DropdownButtonFormField<DestinationCategory>(
              initialValue: _category,
              decoration: InputDecoration(
                  labelText: '카테고리',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
              items: DestinationCategory.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                  .toList(),
              onChanged: (v) => setState(
                  () => _category = v ?? DestinationCategory.attraction),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: '주소 (선택)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _costController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '예상 비용',
                      suffixText: '원',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    initialValue: _duration,
                    decoration: InputDecoration(
                        labelText: '체류 시간',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12))),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('선택안함')),
                      const DropdownMenuItem(value: 30, child: Text('30분')),
                      const DropdownMenuItem(value: 60, child: Text('1시간')),
                      const DropdownMenuItem(value: 90, child: Text('1시간 30분')),
                      const DropdownMenuItem(value: 120, child: Text('2시간')),
                      const DropdownMenuItem(value: 180, child: Text('3시간')),
                    ],
                    onChanged: (v) => setState(() => _duration = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _memoController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '메모 (선택)',
                hintText: '예약 정보, 팁 등',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),

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
      final cost =
          (double.tryParse(_costController.text.replaceAll(',', '')) ?? 0)
              .toInt();
      final repo = TripRepository();
      await repo.addDestination(widget.trip.id, {
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'day': _selectedDay,
        'order':
            widget.trip.destinations.where((d) => d.day == _selectedDay).length,
        'category': _category.value,
        'estimated_cost': cost,
        'estimated_duration': _duration,
        'memo': _memoController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('여행지가 추가되었습니다'), backgroundColor: Colors.green));
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
