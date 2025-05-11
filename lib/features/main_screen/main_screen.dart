import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../drivers/presentation/screens/drivers_screen.dart';
import '../reports/presentation/screens/reports_screen.dart';
import '../backup/presentation/screens/backup_restore_screen.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedIndex = ref.watch(selectedTabProvider);

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: MenuBar(
                children: [
                  _buildTab(context, ref, 0, 'चालक यादी'),
                  _buildTab(context, ref, 1, 'अहवाल तयार करा'),
                  _buildTab(context, ref, 2, 'बॅकअप'),
                ],
              ),
            ),
          ),
          body: IndexedStack(
            index: selectedIndex,
            children: const [
              DriversScreen(),
              ReportsScreen(),
              BackupRestoreScreen(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(
      BuildContext context, WidgetRef ref, int index, String title) {
    final selectedIndex = ref.watch(selectedTabProvider);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: selectedIndex == index
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2.0,
          ),
        ),
      ),
      child: MenuItemButton(
        onPressed: () => ref.read(selectedTabProvider.notifier).state = index,
        child: Text(title),
      ),
    );
  }
}
