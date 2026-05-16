import 'package:flutter/material.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/shared/widgets/mobile_bottom_nav.dart';
import 'package:gosir/features/dashboard/widgets/dashboard_content.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 7)) : null,
      appBar: isDesktop ? null : AppBar(title: const Text('Laporan & Statistik')),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(currentIndex: 7),
          const Expanded(
            child: DashboardContent(),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 0),
    );
  }
}
