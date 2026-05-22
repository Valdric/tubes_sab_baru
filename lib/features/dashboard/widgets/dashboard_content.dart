import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:gosir/features/reports/models/dashboard_summary.dart';
import 'package:intl/intl.dart';
import 'package:gosir/core/utils/safe_parse.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/features/ingredients/screens/ingredients_screen.dart';
import 'package:gosir/shared/widgets/animated_entry.dart';

class UserData {
  static String name = "";
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  DashboardSummary? _summary;
  List<dynamic> _revenueTrend = [];
  List<dynamic> _peakHours = [];
  
  DateTimeRange? _globalDateRange;
  DateTimeRange? _trendDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 6)),
    end: DateTime.now(),
  );
  DateTime _peakDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchSummary();
    _fetchTrend();
    _fetchPeak();
  }

  Future<void> _fetchSummary() async {
    try {
      final Map<String, String> params = {};
      if (_globalDateRange != null) {
        params['date_from'] = DateFormat('yyyy-MM-dd').format(_globalDateRange!.start);
        params['date_to'] = DateFormat('yyyy-MM-dd').format(_globalDateRange!.end);
      }
      final summaryRes = await _api.get('/reports/dashboard', params: params);
      if (mounted) {
        setState(() {
          _summary = DashboardSummary.fromJson(summaryRes['data']);
        });
      }
    } catch (e) {
      debugPrint("Error fetching summary: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchTrend() async {
    try {
      final Map<String, String> params = {};
      if (_trendDateRange != null) {
        params['from'] = DateFormat('yyyy-MM-dd').format(_trendDateRange!.start);
        params['to'] = DateFormat('yyyy-MM-dd').format(_trendDateRange!.end);
      } else {
        params['from'] = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 6)));
        params['to'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
      }
      final trendRes = await _api.get('/reports/revenue-trend', params: params);
      if (mounted) {
        setState(() {
          _revenueTrend = trendRes['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching trend: $e");
    }
  }

  Future<void> _fetchPeak() async {
    try {
      final params = {'date': DateFormat('yyyy-MM-dd').format(_peakDate)};
      final peakRes = await _api.get('/reports/peak-hours', params: params);
      if (mounted) {
        setState(() {
          _peakHours = peakRes['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching peak: $e");
    }
  }

  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchSummary(),
      _fetchTrend(),
      _fetchPeak(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }


  void _resetFilter() {
    setState(() {
      _globalDateRange = null;
      _trendDateRange = DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 6)),
        end: DateTime.now(),
      );
      _peakDate = DateTime.now();
    });
    _fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
      );
    }

    if (_summary == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
            SizedBox(height: 16),
            Text("Gagal memuat data dashboard"),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchAllData,
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).cardColor),
              child: Text("Coba Lagi"),
            ),
          ],
        ),
      );
    }

    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMetricsGrid(currency),
            const SizedBox(height: 24),
            _buildLowStockAlertsCard(),
            _buildTrendCard(),
            const SizedBox(height: 32),
            _buildPeakHoursCard(),
            const SizedBox(height: 32),
            _buildDistributions(),
            const SizedBox(height: 32),
            _buildDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dashboard",
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 32,
                  ),
            ),
            Text(
              "Analisis performa bisnis dan pertumbuhan periode ini.",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: _resetFilter,
              icon: Icon(Icons.refresh, size: 18),
              label: Text("Reset"),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            SizedBox(width: 12),
            _buildCustomDropdown(
              label: _globalDateRange == null
                  ? "Semua Waktu"
                  : _getPresetLabel(_globalDateRange!),
              onSelected: (preset) async {
                // Small delay to let popup close fully
                await Future.delayed(const Duration(milliseconds: 50));
                if (preset == 'custom') {
                  final picked = await _showCalendar(isRange: true);
                  if (picked != null) {
                    setState(() => _globalDateRange = picked as DateTimeRange);
                    _fetchSummary();
                  }
                } else {
                  setState(() => _globalDateRange = _getRangeFromPreset(preset));
                  _fetchSummary();
                }
              },
              presets: ['today', 'yesterday', '7days', '30days', 'thisMonth', 'lastMonth'],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPercentageBadge(double change) {
    final isPositive = change > 0;
    final isNegative = change < 0;
    final color = isPositive
        ? AppColors.success
        : isNegative
            ? AppColors.destructive
            : Colors.grey;
    final bg = color.withValues(alpha: 0.12);
    final text = isPositive
        ? "+${change.toStringAsFixed(1)}%"
        : isNegative
            ? "${change.toStringAsFixed(1)}%"
            : "0.0%";
    final icon = isPositive
        ? Icons.arrow_upward_rounded
        : isNegative
            ? Icons.arrow_downward_rounded
            : Icons.trending_flat_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlertsCard() {
    final lowStock = _summary?.lowStockItems ?? [];
    if (lowStock.isEmpty) return const SizedBox.shrink();

    final outOfStock = lowStock.where((e) => e.stock <= 0).toList();
    final almostOut = lowStock.where((e) => e.stock > 0).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color cardBg = outOfStock.isNotEmpty
        ? AppColors.destructive.withValues(alpha: isDark ? 0.15 : 0.04)
        : AppColors.warning.withValues(alpha: isDark ? 0.15 : 0.04);
    
    final Color borderCol = outOfStock.isNotEmpty
        ? AppColors.destructive.withValues(alpha: 0.4)
        : AppColors.warning.withValues(alpha: 0.4);

    final Color iconColor = outOfStock.isNotEmpty ? AppColors.destructive : AppColors.warning;

    return AnimateEntry(
      delay: const Duration(milliseconds: 250),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderCol, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                outOfStock.isNotEmpty ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outOfStock.isNotEmpty ? "Peringatan! Stok Bahan Baku Habis" : "Stok Bahan Baku Menipis",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    outOfStock.isNotEmpty
                        ? "Ada ${outOfStock.length} bahan baku habis total dan ${almostOut.length} bahan baku hampir habis. Harap segera isi ulang agar produksi tidak terganggu."
                        : "Ada ${almostOut.length} bahan baku di bawah ambang batas minimal. Segera lakukan pengisian ulang.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ScaleOnTap(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const IngredientsScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  "Detail Bahan",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(NumberFormat currency) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = width > 1200 ? 4 : width > 800 ? 2 : 1;
    double aspectRatio = crossAxisCount == 4 ? 1.4 : crossAxisCount == 2 ? 1.7 : 2.2;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: aspectRatio,
      children: [
        AnimateEntry(
          delay: const Duration(milliseconds: 50),
          child: _metricCard(
            "Total Pendapatan",
            currency.format(_summary!.revenue.value),
            Icons.account_balance_wallet_outlined,
            percentageChange: _summary!.revenue.percentageChange,
            footer: "TOTAL KESELURUHAN",
          ),
        ),
        AnimateEntry(
          delay: const Duration(milliseconds: 100),
          child: _metricCard(
            "Pendapatan Bersih",
            currency.format(_summary!.nettRevenue.value),
            Icons.monetization_on_outlined,
            percentageChange: _summary!.nettRevenue.percentageChange,
            details: [
              "Pemasukan Kas: +${currency.format(_summary!.totalCashIncome)}",
              "Pengeluaran Kas: -${currency.format(_summary!.totalCashOutcome)}",
            ],
          ),
        ),
        AnimateEntry(
          delay: const Duration(milliseconds: 150),
          child: _metricCard(
            "Total Pesanan",
            "${_summary!.totalOrders.value.toInt()}",
            Icons.receipt_long_outlined,
            percentageChange: _summary!.totalOrders.percentageChange,
            footer: "TOTAL KESELURUHAN",
          ),
        ),
        AnimateEntry(
          delay: const Duration(milliseconds: 200),
          child: _metricCard(
            "Rata-rata Pesanan",
            currency.format(_summary!.averageOrderValue.value),
            Icons.attach_money_outlined,
            percentageChange: _summary!.averageOrderValue.percentageChange,
            footer: "TOTAL KESELURUHAN",
          ),
        ),
      ],
    );
  }

  Widget _metricCard(String title, String value, IconData icon,
      {String? footer, List<String>? details, double? percentageChange}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ScaleOnTap(
      onTap: () {}, // Hoverable bento box
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF2E2E2E) : AppColors.border.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (percentageChange != null)
                  _buildPercentageBadge(percentageChange)
                else
                  const SizedBox.shrink(),
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      footer,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
            if (details != null) ...[
              const SizedBox(height: 8),
              ...details.map((d) {
                final isAdd = d.contains('+');
                return Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Icon(
                        isAdd ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                        size: 10,
                        color: isAdd ? AppColors.success : AppColors.destructive,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          d,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isAdd ? AppColors.success : AppColors.destructive,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrendCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return AnimateEntry(
      delay: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF2E2E2E) : AppColors.border.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.trending_up_rounded, color: AppColors.success, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Tren Pendapatan Harian",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Visualisasi pergerakan pendapatan dengan rentang maksimal 7 hari.",
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildCustomDropdown(
                  label: _getPresetLabel(_trendDateRange!),
                  onSelected: (preset) async {
                    await Future.delayed(const Duration(milliseconds: 50));
                    if (preset == 'custom') {
                      final picked = await _showCalendar(isRange: true, maxDays: 7);
                      if (picked != null) {
                        setState(() => _trendDateRange = picked as DateTimeRange);
                        _fetchTrend();
                      }
                    } else {
                      setState(() => _trendDateRange = _getRangeFromPreset(preset));
                      _fetchTrend();
                    }
                  },
                  presets: const ['7days', 'today', 'yesterday'],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 300,
              constraints: const BoxConstraints(minHeight: 200),
              child: _revenueTrend.isEmpty
                  ? Center(
                      child: Text(
                        "Tidak ada data tren",
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    )
                  : RepaintBoundary(
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (touchedSpot) => Theme.of(context).cardColor,
                              tooltipRoundedRadius: 8,
                              tooltipBorder: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  int index = spot.x.toInt();
                                  if (index >= 0 && index < _revenueTrend.length) {
                                    final item = _revenueTrend[index];
                                    final date = DateTime.parse(item['date']);
                                    final dateStr = DateFormat('dd MMM yyyy').format(date);
                                    return LineTooltipItem(
                                      "$dateStr\n",
                                      TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontSize: 11,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: currency.format(spot.y),
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return null;
                                }).toList();
                              },
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: isDark ? const Color(0xFF2E2E2E) : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index < 0 || index >= _revenueTrend.length) return const SizedBox();
                                  final item = _revenueTrend[index];
                                  final revenue = parseDouble(item['revenue']);
                                  if (revenue <= 0) return const SizedBox();
                                  final date = DateTime.parse(item['date']);
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormat('dd MMM').format(date),
                                      style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _revenueTrend.asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), parseDouble(e.value['revenue']));
                              }).toList(),
                              isCurved: true,
                              color: AppColors.primary,
                              barWidth: 4,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                  radius: 4,
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                  strokeColor: Theme.of(context).cardColor,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.3),
                                    AppColors.primary.withValues(alpha: 0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeakHoursCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimateEntry(
      delay: const Duration(milliseconds: 350),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF2E2E2E) : AppColors.border.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.local_fire_department_rounded, color: AppColors.warning, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Analisis Jam Sibuk",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Pola sebaran pesanan harian berdasarkan jam transaksi.",
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildCustomDropdown(
                  label: _getPeakLabel(_peakDate),
                  onSelected: (preset) async {
                    await Future.delayed(const Duration(milliseconds: 50));
                    if (preset == 'custom') {
                      final picked = await _showCalendar(isRange: false);
                      if (picked != null) {
                        setState(() => _peakDate = picked as DateTime);
                        _fetchPeak();
                      }
                    } else {
                      setState(() {
                        if (preset == 'today') _peakDate = DateTime.now();
                        if (preset == 'yesterday') _peakDate = DateTime.now().subtract(const Duration(days: 1));
                      });
                      _fetchPeak();
                    }
                  },
                  presets: const ['today', 'yesterday'],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 200,
              constraints: const BoxConstraints(minHeight: 150),
              child: _peakHours.isEmpty
                  ? Center(
                      child: Text(
                        "Tidak ada data jam sibuk",
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    )
                  : RepaintBoundary(
                      child: BarChart(
                        BarChartData(
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (group) => Theme.of(context).cardColor,
                              tooltipRoundedRadius: 8,
                              tooltipBorder: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  "${group.x.toString().padLeft(2, '0')}:00\n",
                                  TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 11,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "${rod.toY.toInt()} Pesanan",
                                      style: const TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value % 3 != 0) return const SizedBox();
                                  return Text(
                                    "${value.toInt().toString().padLeft(2, '0')}:00",
                                    style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(24, (index) {
                            final peak = _peakHours.firstWhere(
                              (p) => p['hour'].toString().startsWith(index.toString().padLeft(2, '0')),
                              orElse: () => {'count': 0},
                            );
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: parseDouble(peak['count']),
                                  color: AppColors.secondary,
                                  width: 10,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDropdown({
    required String label,
    required List<String> presets,
    required Function(String) onSelected,
    String? currentValue,
  }) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      tooltip: "",
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: minAxisSize,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87)),
            ),
            SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
      itemBuilder: (context) => [
        ...presets.map((p) => PopupMenuItem(
              value: p,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_translatePreset(p), style: TextStyle(fontSize: 13)),
                  if (currentValue == p)
                    Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87)),
                ],
              ),
            )),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'custom',
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Pilih Tanggal...", style: TextStyle(fontSize: 13)),
              if (currentValue == 'custom')
                Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87)),
            ],
          ),
        ),
      ],
    );
  }

  MainAxisSize get minAxisSize => MainAxisSize.min;

  String _translatePreset(String p) {
    switch (p) {
      case 'today': return "Hari Ini";
      case 'yesterday': return "Kemarin";
      case '7days': return "7 Hari Terakhir";
      case '30days': return "30 Hari Terakhir";
      case 'thisMonth': return "Bulan Ini";
      case 'lastMonth': return "Bulan Lalu";
      default: return p;
    }
  }

  String _getPresetLabel(DateTimeRange range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (range.start == today && range.end.day == today.day) return "Hari Ini";
    if (range.start == yesterday && range.end.day == yesterday.day) return "Kemarin";
    if (range.start == today.subtract(const Duration(days: 6))) return "7 Hari Terakhir";
    if (range.start == today.subtract(const Duration(days: 29))) return "30 Hari Terakhir";
    
    return "${DateFormat('dd MMM').format(range.start)} - ${DateFormat('dd MMM').format(range.end)}";
  }

  String _getPeakLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return "Hari Ini";
    if (d == today.subtract(const Duration(days: 1))) return "Kemarin";
    return DateFormat('dd MMM yyyy').format(date);
  }

  DateTimeRange? _getRangeFromPreset(String preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (preset) {
      case 'today': return DateTimeRange(start: today, end: now);
      case 'yesterday': 
        final y = today.subtract(const Duration(days: 1));
        return DateTimeRange(start: y, end: y.add(const Duration(hours: 23, minutes: 59)));
      case '7days': return DateTimeRange(start: today.subtract(const Duration(days: 6)), end: now);
      case '30days': return DateTimeRange(start: today.subtract(const Duration(days: 29)), end: now);
      case 'thisMonth': return DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
      case 'lastMonth':
        final start = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 0);
        return DateTimeRange(start: start, end: end);
      default: return null;
    }
  }

  Future<dynamic> _showCalendar({required bool isRange, int? maxDays}) async {
    return showDialog(
      context: context,
      builder: (context) => _WebStyleCalendarDialog(
        isRange: isRange,
        maxDays: maxDays,
        initialRange: maxDays == 7 ? _trendDateRange : _globalDateRange,
        initialDate: _peakDate,
      ),
    );
  }

  Widget _donutCard(String title, List<DistributionItem> items,
      {String? subtitle}) {
    int totalCount = items.fold(0, (sum, item) => sum + item.value);
    final segmentColors = [
      Theme.of(context).colorScheme.primary, // Deep Indigo
      Theme.of(context).colorScheme.secondary, // Professional Teal
      const Color(0xFFF59E0B), // Amber Warning
      const Color(0xFF6366F1), // Indigo Accent
      const Color(0xFF10B981), // Emerald Success
      const Color(0xFF0EA5E9), // Sky Blue
    ];

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
          ),
          if (subtitle != null)
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          SizedBox(height: 16),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 120),
              child: items.isEmpty
                  ? Center(
                      child: Text("Tidak ada data",
                          style: TextStyle(
                              fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)))
                  : Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(enabled: false),
                                  sections: items.asMap().entries.map((entry) {
                                    final i = entry.key;
                                    final e = entry.value;
                                    return PieChartSectionData(
                                      value: e.value.toDouble(),
                                      color: segmentColors[i % segmentColors.length],
                                      radius: 16,
                                      showTitle: false,
                                    );
                                  }).toList(),
                                  centerSpaceRadius: 32,
                                  sectionsSpace: 2,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "$totalCount",
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  Text(
                                    "ORDER",
                                    style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 5,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: items.asMap().entries.map((entry) {
                                final i = entry.key;
                                final e = entry.value;
                                final color = segmentColors[i % segmentColors.length];
                                final percent = totalCount > 0
                                    ? (e.value / totalCount * 100).toStringAsFixed(1)
                                    : '0.0';
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          e.label,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "$percent%",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributions() {
    final width = MediaQuery.of(context).size.width;
    int count = width > 1000 ? 3 : 1;
    return GridView.count(
      crossAxisCount: count,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        AnimateEntry(
          delay: const Duration(milliseconds: 400),
          child: _donutCard("Metode Pembayaran", _summary!.paymentMethods,
              subtitle: "Distribusi transaksi berdasarkan fitur bayar."),
        ),
        AnimateEntry(
          delay: const Duration(milliseconds: 450),
          child: _donutCard("Tipe Pesanan", _summary!.orderTypes,
              subtitle: "Dine-in vs Takeaway share."),
        ),
        AnimateEntry(
          delay: const Duration(milliseconds: 500),
          child: _donutCard("Platform Pesanan", _summary!.platforms,
              subtitle: "Sumber kanal pesanan masuk."),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    final width = MediaQuery.of(context).size.width;
    bool isWide = width > 800;
    return Flex(
      direction: isWide ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isWide
            ? Expanded(
                flex: 1,
                child: AnimateEntry(
                  delay: const Duration(milliseconds: 550),
                  child: _listSection(
                    "Menu Terlaris",
                    _summary!.mostSoldItems,
                    icon: Icons.restaurant_menu,
                    subtitle: "Item yang paling sering dipesan.",
                  ),
                ),
              )
            : AnimateEntry(
                delay: const Duration(milliseconds: 550),
                child: _listSection(
                  "Menu Terlaris",
                  _summary!.mostSoldItems,
                  icon: Icons.restaurant_menu,
                  subtitle: "Item yang paling sering dipesan.",
                ),
              ),
        if (isWide) SizedBox(width: 24),
        if (!isWide) SizedBox(height: 24),
        isWide
            ? Expanded(
                flex: 1,
                child: AnimateEntry(
                  delay: const Duration(milliseconds: 600),
                  child: _listSection(
                    "Stok Kritis",
                    _summary!.lowStockItems,
                    icon: Icons.warning_amber_rounded,
                    subtitle: "Bahan baku yang harus segera diisi ulang.",
                    isError: true,
                  ),
                ),
              )
            : AnimateEntry(
                delay: const Duration(milliseconds: 600),
                child: _listSection(
                  "Stok Kritis",
                  _summary!.lowStockItems,
                  icon: Icons.warning_amber_rounded,
                  subtitle: "Bahan baku yang harus segera diisi ulang.",
                  isError: true,
                ),
              ),
      ],
    );
  }

  Widget _listSection(
    String title,
    dynamic items, {
    required IconData icon,
    String? subtitle,
    bool isError = false,
  }) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isError ? Theme.of(context).colorScheme.error : const Color(0xFF10B981), size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          SizedBox(height: 20),
          if (items.isEmpty)
            Center(
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Icon(
                    isError ? Icons.check_circle_outline : Icons.info_outline,
                    size: 48,
                    color: isError ? Colors.green.withValues(alpha: 0.2) : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  ),
                  SizedBox(height: 12),
                  Text(
                    isError ? "Stok bahan baku terpantau aman." : "Belum ada item terlaris.",
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            )
          else
            ...items.map<Widget>((item) {
              if (item is MostSoldItem) {
                return ScaleOnTap(
                  onTap: () {},
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Kuantitas: ${item.totalSold}x",
                                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Terlaris",
                            style: TextStyle(fontSize: 10, color: const Color(0xFF10B981), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // LowStockItem
                final double stockVal = item.stock;
                final bool isOut = stockVal == 0;
                final Color statusColor = isOut ? Theme.of(context).colorScheme.error : const Color(0xFFF59E0B);
                final Color statusBg = statusColor.withValues(alpha: 0.1);

                return ScaleOnTap(
                  onTap: () {},
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Tersisa: $stockVal ${item.unit}",
                                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOut ? Icons.cancel_outlined : Icons.warning_amber_rounded,
                                size: 12,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isOut ? "Habis" : "Kritis",
                                style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }).toList(),
        ],
      ),
    );
  }
}

class _WebStyleCalendarDialog extends StatefulWidget {
  final bool isRange;
  final int? maxDays;
  final DateTimeRange? initialRange;
  final DateTime? initialDate;

  const _WebStyleCalendarDialog({
    required this.isRange,
    this.maxDays,
    this.initialRange,
    this.initialDate,
  });

  @override
  State<_WebStyleCalendarDialog> createState() => _WebStyleCalendarDialogState();
}

class _WebStyleCalendarDialogState extends State<_WebStyleCalendarDialog> {
  DateTime? _selectedStart;
  DateTime? _selectedEnd;
  DateTime? _selectedSingle;

  @override
  void initState() {
    super.initState();
    if (widget.isRange) {
      _selectedStart = widget.initialRange?.start;
      _selectedEnd = widget.initialRange?.end;
    } else {
      _selectedSingle = widget.initialDate;
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isRange ? "Pilih Rentang Tanggal" : "Pilih Tanggal",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              widget.isRange 
                  ? "Tentukan awal dan akhir tanggal untuk filter data."
                  : "Tentukan tanggal spesifik untuk filter data harian.",
              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.normal),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
      content: Builder(
        builder: (context) {
          final width = MediaQuery.of(context).size.width;
          final bool useVertical = width < 600;
          return SizedBox(
            width: widget.isRange ? (useVertical ? 350 : 750) : 350,
            height: widget.isRange ? (useVertical ? 750 : 400) : 380,
            child: widget.isRange
                ? (useVertical ? SingleChildScrollView(child: _buildVerticalRange()) : _buildHorizontalRange())
                : _buildSingleCalendar(),
          );
        },
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      actionsPadding: EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (widget.isRange) {
              if (_selectedStart != null && _selectedEnd != null) {
                final range = DateTimeRange(start: _selectedStart!, end: _selectedEnd!);
                if (widget.maxDays != null && range.duration.inDays >= widget.maxDays!) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Maksimal rentang adalah ${widget.maxDays} hari")),
                  );
                  return;
                }
                Navigator.pop(context, range);
              }
            } else {
              Navigator.pop(context, _selectedSingle);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 0,
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildHorizontalRange() {
    return Row(
      children: [
        Expanded(child: _buildStartCalendar()),
        const VerticalDivider(width: 1),
        Expanded(child: _buildEndCalendar()),
      ],
    );
  }

  Widget _buildVerticalRange() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStartCalendar(isSmall: true),
        Divider(height: 1),
        _buildEndCalendar(isSmall: true),
      ],
    );
  }

  Widget _buildSingleCalendar() {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF639B8D),
                  brightness: Theme.of(context).brightness,
                ).copyWith(primary: const Color(0xFF639B8D)),
              ),
              child: CalendarDatePicker(
                key: ValueKey("single_$_selectedSingle"),
                initialDate: _selectedSingle ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                onDateChanged: (date) => setState(() => _selectedSingle = date),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartCalendar({bool isSmall = false}) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text("Tanggal Mulai", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).colorScheme.primary)),
          ),
          SizedBox(
            height: isSmall ? 330 : null,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF639B8D),
                  brightness: Theme.of(context).brightness,
                ).copyWith(primary: const Color(0xFF639B8D)),
              ),
              child: CalendarDatePicker(
                key: ValueKey("start_$_selectedStart"),
                initialDate: _selectedStart ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                onDateChanged: (date) {
                  setState(() {
                    _selectedStart = date;
                    if (_selectedEnd != null && _selectedEnd!.isBefore(_selectedStart!)) {
                      _selectedEnd = null;
                    }
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndCalendar({bool isSmall = false}) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text("Tanggal Selesai", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).colorScheme.primary)),
          ),
          SizedBox(
            height: isSmall ? 330 : null,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF639B8D),
                  brightness: Theme.of(context).brightness,
                ).copyWith(primary: const Color(0xFF639B8D)),
              ),
              child: CalendarDatePicker(
                key: ValueKey("end_$_selectedEnd"),
                initialDate: _selectedEnd ?? _selectedStart ?? DateTime.now(),
                firstDate: _selectedStart ?? DateTime(2020),
                lastDate: DateTime.now(),
                onDateChanged: (date) => setState(() => _selectedEnd = date),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
