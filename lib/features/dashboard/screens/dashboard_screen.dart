import 'package:flutter/material.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/shared/widgets/mobile_bottom_nav.dart';
import 'package:gosir/features/dashboard/widgets/dashboard_content.dart';
import 'package:gosir/shared/widgets/profile_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 0)) : null,
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Dashboard'),
              actions: const [
                ProfileButton(),
              ],
            ),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(currentIndex: 0),
          Expanded(
            child: DashboardContent(),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 0),
    );
  }
}
