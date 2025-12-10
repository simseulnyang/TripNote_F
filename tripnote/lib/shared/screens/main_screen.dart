import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/trip/screens/trip_list_screen.dart';
import '../../features/ai_recommend/screens/chat_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class CurrentTabNotifier extends Notifier<int> {
  @override
  int build() => 0; // 초기값

  void setTab(int index) => state = index;
}

final currentTabProvider = NotifierProvider<CurrentTabNotifier, int>(() {
  return CurrentTabNotifier();
});

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: const [
          TripListScreen(),
          ChatScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentTab,
        onTap: (index) {
          ref.read(currentTabProvider.notifier).setTab(index);
        },
      ),
    );
  }
}
