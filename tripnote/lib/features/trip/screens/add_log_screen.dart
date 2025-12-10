import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/trip_model.dart';
import '../repositories/trip_repository.dart';

class AddLogScreen extends ConsumerStatefulWidget {
  final TripDetailModel trip;
  const AddLogScreen({super.key, required this.trip});

  @override
  ConsumerState<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends ConsumerState<AddLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placeNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _reviewController = TextEditingController();

  late DateTime _visitDate;
  VisitStatus _visitStatus = VisitStatus.planned;
  int? _selectedDestinationId;
  int _rating = 0;
  int? _duration;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _visitDate = DateTime.now().isBefore(widget.trip.startDate)
        ? widget.trip.startDate
        : DateTime.now().isAfter(widget.trip.endDate)
            ? widget.trip.endDate
            : DateTime.now();
  }

  @override
  void dispose() {
    _placeNameController.dispose();
    _addressController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('여행 기록 추가'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (widget.trip.destinations.isNotEmpty) ...[
              const Text('계획했던 여행지와 연결',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                initialValue: _selectedDestinationId,
                decoration: InputDecoration(
                  hintText: '선택하면 장소 정보가 자동 입력됩니다',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('직접 입력')),
                  ...widget.trip.destinations.map((d) => DropdownMenuItem(
                      value: d.id, child: Text('Day${d.day} - ${d.name}'))),
                ],
                onChanged: (v) {
                  setState(() => _selectedDestinationId = v);
                  if (v != null) {
                    final dest =
                        widget.trip.destinations.firstWhere((d) => d.id == v);
                    _placeNameController.text = dest.name;
                    _addressController.text = dest.address ?? '';
                    _visitStatus = VisitStatus.planned;
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
            TextFormField(
              controller: _placeNameController,
              decoration: InputDecoration(
                labelText: '장소명 *',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '장소명을 입력해주세요' : null,
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
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _visitDate,
                  firstDate: widget.trip.startDate,
                  lastDate: widget.trip.endDate,
                );
                if (picked != null) setState(() => _visitDate = picked);
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
                    Text(
                        '방문일: ${DateFormat('yyyy.MM.dd (E)').format(_visitDate)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<VisitStatus>(
              initialValue: _visitStatus,
              decoration: InputDecoration(
                  labelText: '방문 상태',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
              items: VisitStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _visitStatus = v ?? VisitStatus.planned),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _duration,
              decoration: InputDecoration(
                  labelText: '실제 체류 시간',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
              items: [
                const DropdownMenuItem(value: null, child: Text('선택안함')),
                const DropdownMenuItem(value: 30, child: Text('30분')),
                const DropdownMenuItem(value: 60, child: Text('1시간')),
                const DropdownMenuItem(value: 90, child: Text('1시간 30분')),
                const DropdownMenuItem(value: 120, child: Text('2시간')),
                const DropdownMenuItem(value: 180, child: Text('3시간')),
                const DropdownMenuItem(value: 240, child: Text('4시간 이상')),
              ],
              onChanged: (v) => setState(() => _duration = v),
            ),
            const SizedBox(height: 20),
            const Text('평점', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  5,
                  (i) => IconButton(
                        onPressed: () => setState(() => _rating = i + 1),
                        icon: Icon(
                          i < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                      )),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: '후기 (선택)',
                hintText: '이 장소에 대한 소감을 적어보세요',
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
                    : const Text('기록하기',
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
      final repo = TripRepository();
      await repo.addTripLog(widget.trip.id, {
        'place_name': _placeNameController.text.trim(),
        'address': _addressController.text.trim(),
        'visit_date': DateFormat('yyyy-MM-dd').format(_visitDate),
        'visit_status': _visitStatus.value,
        'actual_duration': _duration,
        'rating': _rating > 0 ? _rating : null,
        'review': _reviewController.text.trim(),
        'destination': _selectedDestinationId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('기록이 추가되었습니다'), backgroundColor: Colors.green));
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
