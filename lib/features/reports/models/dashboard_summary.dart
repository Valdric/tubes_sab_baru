import 'package:gosir/core/utils/safe_parse.dart';

class DashboardSummary {
  final MetricValue revenue;
  final MetricValue totalOrders;
  final MetricValue averageOrderValue;
  final MetricValue nettRevenue;
  final double totalCashIncome;
  final double totalCashOutcome;
  final bool isAllTime;
  final List<MostSoldItem> mostSoldItems;
  final List<LowStockItem> lowStockItems;
  final List<DistributionItem> paymentMethods;
  final List<DistributionItem> orderTypes;
  final List<DistributionItem> platforms;

  DashboardSummary({
    required this.revenue,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.nettRevenue,
    required this.totalCashIncome,
    required this.totalCashOutcome,
    required this.isAllTime,
    required this.mostSoldItems,
    required this.lowStockItems,
    required this.paymentMethods,
    required this.orderTypes,
    required this.platforms,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      revenue: MetricValue.fromJson(json['revenue']),
      totalOrders: MetricValue.fromJson(json['total_orders']),
      averageOrderValue: MetricValue.fromJson(json['average_order_value']),
      nettRevenue: MetricValue.fromJson(json['nett_revenue']),
      totalCashIncome: parseDouble(json['total_cash_income']),
      totalCashOutcome: parseDouble(json['total_cash_outcome']),
      isAllTime: json['is_all_time'] ?? true,
      mostSoldItems: (json['most_sold_items'] as List? ?? []).map((e) => MostSoldItem.fromJson(e)).toList(),
      lowStockItems: (json['low_stock_items'] as List? ?? []).map((e) => LowStockItem.fromJson(e)).toList(),
      paymentMethods: (json['payment_methods'] as List? ?? []).map((e) => DistributionItem.fromJson(e, 'method')).toList(),
      orderTypes: (json['order_types'] as List? ?? []).map((e) => DistributionItem.fromJson(e, 'type')).toList(),
      platforms: (json['platforms'] as List? ?? []).map((e) => DistributionItem.fromJson(e, 'platform')).toList(),
    );
  }
}

class MetricValue {
  final double value;
  final double percentageChange;

  MetricValue({required this.value, required this.percentageChange});

  factory MetricValue.fromJson(Map<String, dynamic>? json) {
    return MetricValue(
      value: parseDouble(json?['value']),
      percentageChange: parseDouble(json?['percentage_change']),
    );
  }
}

class MostSoldItem {
  final String name;
  final int totalSold;
  MostSoldItem({required this.name, required this.totalSold});
  factory MostSoldItem.fromJson(Map<String, dynamic> json) {
    final menuData = json['menu'] as Map<String, dynamic>?;
    return MostSoldItem(
      name: (menuData?['name'] ?? json['name'] ?? '-').toString(),
      totalSold: parseInt(json['total_sold']),
    );
  }
}

class LowStockItem {
  final String name;
  final double stock;
  final String unit;
  LowStockItem({required this.name, required this.stock, required this.unit});
  factory LowStockItem.fromJson(Map<String, dynamic> json) => LowStockItem(
    name: json['name']?.toString() ?? '-',
    stock: parseDouble(json['stock']),
    unit: json['unit']?.toString() ?? '',
  );
}

class DistributionItem {
  final String label;
  final int value;
  DistributionItem({required this.label, required this.value});
  factory DistributionItem.fromJson(Map<String, dynamic> json, String labelKey) => DistributionItem(
    label: json[labelKey]?.toString() ?? '-',
    value: parseInt(json['count']),
  );
}
