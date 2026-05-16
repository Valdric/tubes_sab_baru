import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/shared/widgets/mobile_bottom_nav.dart';
import 'package:gosir/features/profile/screens/profile_screen.dart';
import 'package:gosir/core/services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() => _isLoading = true);
    try {
      // final response = await _api.get('/reports/daily');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 4)) : null,
      appBar: isDesktop ? null : AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text('Reports', style: GoogleFonts.hankenGrotesk(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(icon: const Icon(Icons.menu_open, color: AppColors.primary), onPressed: () => Scaffold.of(context).openDrawer()),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
              child: const CircleAvatar(radius: 18, backgroundColor: AppColors.surfaceContainerHigh, child: Icon(Icons.person, size: 20)),
            ),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) const Sidebar(currentIndex: 4),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error)))
                : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sales Overview', style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 16),

                  // Kartu Ringkasan
                  Row(
                    children: [
                      Expanded(child: _buildReportCard('Gross Revenue', '\$0.00', Icons.payments, Colors.green)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildReportCard('Total Orders', '0', Icons.receipt_long, AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Placeholder Grafik
                  Text('Revenue Trend', style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 16),
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart, size: 64, color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        const Text('Sales Chart Placeholder', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                        const Text('Install fl_chart package to view graphs', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text('Recent Payouts', style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 16),
                  _buildPayoutTile('May 14, 2026', '\$3,245.50', 'Processing'),
                  _buildPayoutTile('May 13, 2026', '\$2,890.00', 'Deposited'),
                  _buildPayoutTile('May 12, 2026', '\$3,100.20', 'Deposited'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(currentIndex: 4),
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.hankenGrotesk(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildPayoutTile(String date, String amount, String status) {
    final isProcessing = status == 'Processing';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        leading: Icon(isProcessing ? Icons.sync : Icons.account_balance, color: isProcessing ? Colors.orange : Colors.green),
        title: Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(status, style: TextStyle(color: isProcessing ? Colors.orange : Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
        trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
