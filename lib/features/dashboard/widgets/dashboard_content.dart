import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:gosir/features/reports/models/dashboard_summary.dart';
import 'package:intl/intl.dart';
import 'package:gosir/core/utils/safe_parse.dart';

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
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_summary == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text("Gagal memuat data dashboard"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchAllData,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text("Coba Lagi"),
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
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMetricsGrid(currency),
            const SizedBox(height: 32),
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
                    color: Colors.black,
                    fontSize: 32,
                  ),
            ),
            const Text(
              "Analisis performa bisnis dan pertumbuhan periode ini.",
              style: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: _resetFilter,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text("Reset"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(width: 12),
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

  Widget _buildMetricsGrid(NumberFormat currency) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = width > 1200 ? 4 : width > 800 ? 2 : 1;
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: [
        _metricCard(
          "Total Pendapatan",
          currency.format(_summary!.revenue.value),
          Icons.account_balance_wallet_outlined,
          footer: "TOTAL KESELURUHAN",
        ),
        _metricCard(
          "Pendapatan Bersih",
          currency.format(_summary!.nettRevenue.value),
          Icons.monetization_on_outlined,
          details: [
            "Pemasukan Kas: +${currency.format(_summary!.totalCashIncome)}",
            "Pengeluaran Kas: -${currency.format(_summary!.totalCashOutcome)}",
          ],
        ),
        _metricCard(
          "Total Pesanan",
          "${_summary!.totalOrders.value.toInt()}",
          Icons.receipt_long_outlined,
          footer: "TOTAL KESELURUHAN",
        ),
        _metricCard(
          "Rata-rata Pesanan",
          currency.format(_summary!.averageOrderValue.value),
          Icons.attach_money_outlined,
          footer: "TOTAL KESELURUHAN",
        ),
      ],
    );
  }

  Widget _metricCard(String title, String value, IconData icon,
      {String? footer, List<String>? details}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Icon(icon, color: Colors.grey.shade400, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF065F46), // Dark green like web
                ),
              ),
              const Spacer(),
              if (footer != null)
                Text(
                  footer,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              if (details != null)
                ...details.map((d) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 10,
                          color: d.contains('+') ? Colors.green : Colors.red,
                        ),
                      ),
                    )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
                        Icon(Icons.trending_up, color: Color(0xFF10B981), size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Tren Pendapatan Harian",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Visualisasi pergerakan pendapatan dngn rentang maksimal 7 hari.",
                      style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
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
                presets: ['7days', 'today', 'yesterday'],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 300,
            constraints: const BoxConstraints(minHeight: 200),
            child: _revenueTrend.isEmpty
                ? const Center(child: Text("Tidak ada data tren"))
                : RepaintBoundary(
                    child: IgnorePointer(
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(enabled: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.shade100,
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
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
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
                              color: const Color(0xFFF97316),
                              barWidth: 3,
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFF97316).withValues(alpha: 0.3),
                                    const Color(0xFFF97316).withValues(alpha: 0.0),
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
          ),
        ],
      ),
    );
  }

  Widget _buildPeakHoursCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
                        Icon(Icons.local_fire_department, color: Color(0xFFF97316), size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Analisis Jam Sibuk",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Pola sebaran pesanan harian berdasarkan jam harian.",
                      style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
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
                presets: ['today', 'yesterday'],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 200,
            constraints: const BoxConstraints(minHeight: 150),
            child: _peakHours.isEmpty
                ? const Center(child: Text("Tidak ada data jam sibuk"))
                : RepaintBoundary(
                    child: IgnorePointer(
                      child: BarChart(
                        BarChartData(
                          barTouchData: BarTouchData(enabled: false),
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
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
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
                                  color: const Color(0xFFF97316),
                                  width: 12,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: minAxisSize,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
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
                  Text(_translatePreset(p), style: const TextStyle(fontSize: 13)),
                  if (currentValue == p)
                    const Icon(Icons.check, size: 16, color: Colors.black87),
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
              const Text("Pilih Tanggal...", style: TextStyle(fontSize: 13)),
              if (currentValue == 'custom')
                const Icon(Icons.check, size: 16, color: Colors.black87),
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 150),
              child: items.isEmpty
                  ? const Center(
                      child: Text("Tidak ada data",
                          style: TextStyle(
                              fontSize: 11, color: AppColors.mutedForeground)))
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(enabled: false),
                            sections: items.asMap().entries.map((entry) {
                            final i = entry.key;
                            final e = entry.value;
                            final colors = [
                              const Color(0xFF0EA5E9), // Blue
                              const Color(0xFFF97316), // Orange
                              const Color(0xFF10B981), // Green
                              const Color(0xFF6366F1), // Indigo
                            ];
                            return PieChartSectionData(
                              value: e.value.toDouble(),
                              title: '${e.label}\n(${e.value})',
                              color: colors[i % colors.length],
                              radius: 40,
                              showTitle: true,
                              titlePositionPercentageOffset: 1.5,
                              titleStyle: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            );
                          }).toList(),
                          centerSpaceRadius: 50,
                          sectionsSpace: 0,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "$totalCount",
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                            const Text(
                              "ORDER",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                          ],
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
        _donutCard("Metode Pembayaran", _summary!.paymentMethods,
            subtitle: "Distribusi transaksi berdasarkan fitur bayar."),
        _donutCard("Tipe Pesanan", _summary!.orderTypes,
            subtitle: "Dine-in vs Takeaway share."),
        _donutCard("Platform Pesanan", _summary!.platforms,
            subtitle: "Sumber kanal pesanan masuk."),
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
                child: _listSection(
                  "Menu Terlaris",
                  _summary!.mostSoldItems,
                  icon: Icons.restaurant_menu,
                  subtitle: "Item yang paling sering dipesan.",
                ),
              )
            : _listSection(
                "Menu Terlaris",
                _summary!.mostSoldItems,
                icon: Icons.restaurant_menu,
                subtitle: "Item yang paling sering dipesan.",
              ),
        if (isWide) const SizedBox(width: 24),
        if (!isWide) const SizedBox(height: 24),
        isWide
            ? Expanded(
                flex: 1,
                child: _listSection(
                  "Stok Kritis",
                  _summary!.lowStockItems,
                  icon: Icons.warning_amber_rounded,
                  subtitle: "Bahan baku yang harus segera diisi ulang.",
                  isError: true,
                ),
              )
            : _listSection(
                "Stok Kritis",
                _summary!.lowStockItems,
                icon: Icons.warning_amber_rounded,
                subtitle: "Bahan baku yang harus segera diisi ulang.",
                isError: true,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isError ? Colors.red : const Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
              ),
            ),
          const SizedBox(height: 20),
          if (items.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Icon(
                    isError ? Icons.check_circle_outline : Icons.info_outline,
                    size: 48,
                    color: isError ? Colors.green.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isError ? "Stok bahan baku terpantau aman." : "Belum ada item terlaris.",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ...items.map<Widget>((item) {
              if (item is MostSoldItem) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text("Kuantitas: ${item.totalSold}x", style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text("Terlaris", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              } else {
                // LowStockItem
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${item.name} (${item.stock} ${item.unit})",
                    style: const TextStyle(fontSize: 12, color: Colors.red),
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
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isRange ? "Pilih Rentang Tanggal" : "Pilih Tanggal",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              widget.isRange 
                  ? "Tentukan awal dan akhir tanggal untuk filter data."
                  : "Tentukan tanggal spesifik untuk filter data harian.",
              style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.normal),
            ),
          ),
          const SizedBox(height: 16),
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
      backgroundColor: AppColors.background,
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
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
            backgroundColor: const Color(0xFF639B8D), // Teal color from screenshot
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold)),
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
        const Divider(height: 1),
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
                colorScheme: const ColorScheme.light(primary: Color(0xFF639B8D)),
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
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text("Tanggal Mulai", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF639B8D))),
          ),
          SizedBox(
            height: isSmall ? 330 : null,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: Color(0xFF639B8D)),
              ),
              child: CalendarDatePicker(
                key: ValueKey("start_${_selectedStart}"),
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
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text("Tanggal Selesai", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF639B8D))),
          ),
          SizedBox(
            height: isSmall ? 330 : null,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: Color(0xFF639B8D)),
              ),
              child: CalendarDatePicker(
                key: ValueKey("end_${_selectedEnd}"),
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
