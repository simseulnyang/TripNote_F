import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_card.dart';
import 'trip_create_screen.dart';
import 'trip_detail_screen.dart';

class TripListScreen extends ConsumerWidget {
  const TripListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final tripsAsync = ref.watch(tripListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('여행일정',
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                      tripsAsync.when(
                        data: (trips) => Text('${trips.length}개의 여행',
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                        loading: () => const Text('로딩 중...',
                            style: TextStyle(color: AppColors.textSecondary)),
                        error: (_, __) => const Text('0개의 여행',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      ref.refresh(tripListProvider);
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            Expanded(
              child: tripsAsync.when(
                data: (trips) {
                  if (trips.isEmpty)
                    return _buildEmpty(context, ref, authState.isLoggedIn);
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.refresh(tripListProvider);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: trips.length,
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TripCard(
                          trip: trips[i],
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      TripDetailScreen(tripId: trips[i].id))),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    _buildErrorOrEmpty(context, ref, authState.isLoggedIn, e),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: authState.isLoggedIn
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TripCreateScreen()));
                if (result == true)
                  ref.read(tripListProvider.notifier).refresh();
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label:
                  const Text('여행 만들기', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildErrorOrEmpty(
      BuildContext context, WidgetRef ref, bool isLoggedIn, Object error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('401') ||
        errorStr.contains('unauthorized') ||
        !isLoggedIn) {
      return _buildEmpty(context, ref, isLoggedIn);
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('서버에 연결할 수 없습니다.'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.invalidate(tripListProvider),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref, bool isLoggedIn) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✈️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text('아직 여행 일정이 없어요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('새로운 여행을 계획해보세요!',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          if (isLoggedIn)
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TripCreateScreen()));
                if (result == true) ref.invalidate(tripListProvider);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('여행 일정 만들기',
                  style: TextStyle(color: Colors.white)),
            )
          else
            Column(
              children: [
                const Text('로그인하고 여행을 계획해보세요',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('로그인')),
              ],
            ),
        ],
      ),
    );
  }
}
