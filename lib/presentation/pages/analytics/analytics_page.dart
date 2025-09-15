import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/fuel_record_model.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/models/fuel_type.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late Box<FuelRecord> fuelRecordsBox;
  late Box<Vehicle> vehiclesBox;
  String? selectedVehicleId;
  int selectedPeriod = 30; // dias

  @override
  void initState() {
    super.initState();
    fuelRecordsBox = Hive.box<FuelRecord>('fuel_records');
    vehiclesBox = Hive.box<Vehicle>('vehicles');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.analytics),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          PopupMenuButton<int>(
            icon: Icon(Icons.date_range),
            onSelected: (value) {
              setState(() {
                selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 7, child: Text('Últimos 7 dias')),
              PopupMenuItem(value: 30, child: Text('Últimos 30 dias')),
              PopupMenuItem(value: 90, child: Text('Últimos 3 meses')),
              PopupMenuItem(value: 365, child: Text('Último ano')),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: fuelRecordsBox.listenable(),
        builder: (context, Box<FuelRecord> box, _) {
          var records = _getFilteredRecords();

          if (records.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVehicleFilter(),
                  SizedBox(height: AppDimensions.spacingLarge),
                  _buildMetricsOverview(records),
                  SizedBox(height: AppDimensions.spacingLarge),
                  _buildSpendingChart(records),
                  SizedBox(height: AppDimensions.spacingLarge),
                  _buildFuelTypeAnalysis(records),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<FuelRecord> _getFilteredRecords() {
    var records = fuelRecordsBox.values.toList();

    // Filtrar por veículo
    if (selectedVehicleId != null) {
      records = records.where((r) => r.vehicleId == selectedVehicleId).toList();
    }

    // Filtrar por período
    final cutoffDate = DateTime.now().subtract(Duration(days: selectedPeriod));
    records = records.where((r) => r.date.isAfter(cutoffDate)).toList();

    // Ordenar por data
    records.sort((a, b) => a.date.compareTo(b.date));

    return records;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppDimensions.spacingLarge),
            Text(
              'Dados insuficientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppDimensions.spacingSmall),
            Text(
              'Registre alguns abastecimentos para ver análises',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleFilter() {
    final vehicles = vehiclesBox.values.toList();

    if (vehicles.length <= 1) return SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtrar por veículo:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppDimensions.spacingSmall),
            Wrap(
              spacing: AppDimensions.spacingSmall,
              children: [
                FilterChip(
                  label: Text('Todos'),
                  selected: selectedVehicleId == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedVehicleId = null;
                      });
                    }
                  },
                ),
                ...vehicles.map((vehicle) {
                  final isSelected = selectedVehicleId == vehicle.id;
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(vehicle.identificationColorValue),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(vehicle.shortName),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedVehicleId = selected ? vehicle.id : null;
                      });
                    },
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsOverview(List<FuelRecord> records) {
    final totalSpent = records.fold<double>(0, (sum, r) => sum + r.totalCost);
    final totalLiters = records.fold<double>(0, (sum, r) => sum + r.liters);
    final averagePrice = totalLiters > 0 ? totalSpent / totalLiters : 0.0;
    final totalRefuels = records.length;

    // Calcular consumo médio
    double averageConsumption = 0;
    int consumptionCount = 0;
    for (int i = 1; i < records.length; i++) {
      if (records[i].vehicleId == records[i-1].vehicleId && records[i].isFullTank) {
        final consumption = records[i].calculateConsumption(records[i-1].odometer);
        if (consumption != null) {
          averageConsumption += consumption;
          consumptionCount++;
        }
      }
    }
    if (consumptionCount > 0) {
      averageConsumption = averageConsumption / consumptionCount;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumo do Período',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppDimensions.spacingMedium),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Gasto',
                '${AppStrings.currency} ${totalSpent.toStringAsFixed(2)}',
                Icons.attach_money,
                AppColors.error,
              ),
            ),
            SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: _buildMetricCard(
                'Preço Médio',
                '${AppStrings.currency} ${averagePrice.toStringAsFixed(3)}/L',
                Icons.local_gas_station,
                AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacingMedium),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Consumo Médio',
                '${averageConsumption.toStringAsFixed(1)} km/L',
                Icons.speed,
                AppColors.info,
              ),
            ),
            SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: _buildMetricCard(
                'Abastecimentos',
                totalRefuels.toString(),
                Icons.local_gas_station,
                AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: AppDimensions.spacingSmall),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.spacingSmall),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSpendingChart(List<FuelRecord> records) {
    // Agrupar por mês
    Map<String, double> monthlySpending = {};

    for (final record in records) {
      final monthKey = '${record.date.month}/${record.date.year}';
      monthlySpending[monthKey] = (monthlySpending[monthKey] ?? 0) + record.totalCost;
    }

    if (monthlySpending.isEmpty) return SizedBox.shrink();

    List<BarChartGroupData> barGroups = [];
    List<String> months = monthlySpending.keys.toList();

    for (int i = 0; i < months.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: monthlySpending[months[i]]!,
              color: AppColors.primary,
              width: 20,
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gastos por Mês',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppDimensions.spacingMedium),
            Container(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 60),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < months.length) {
                            return Text(
                              months[value.toInt()],
                              style: TextStyle(fontSize: 10),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelTypeAnalysis(List<FuelRecord> records) {
    Map<String, double> fuelTypeSpending = {};
    Map<String, int> fuelTypeCount = {};

    for (final record in records) {
      final fuelTypeName = record.fuelType.displayName;
      fuelTypeSpending[fuelTypeName] = (fuelTypeSpending[fuelTypeName] ?? 0) + record.totalCost;
      fuelTypeCount[fuelTypeName] = (fuelTypeCount[fuelTypeName] ?? 0) + 1;
    }

    if (fuelTypeSpending.isEmpty) return SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Análise por Tipo de Combustível',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppDimensions.spacingMedium),
            ...fuelTypeSpending.entries.map((entry) {
              final fuelType = entry.key;
              final totalSpent = entry.value;
              final count = fuelTypeCount[fuelType] ?? 0;
              final averageSpent = totalSpent / count;

              return Padding(
                padding: EdgeInsets.only(bottom: AppDimensions.spacingMedium),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.getFuelTypeColor(fuelType).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        border: Border.all(
                          color: AppColors.getFuelTypeColor(fuelType),
                        ),
                      ),
                      child: Icon(
                        Icons.local_gas_station,
                        color: AppColors.getFuelTypeColor(fuelType),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fuelType,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '$count abastecimentos',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${AppStrings.currency} ${totalSpent.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Média: ${AppStrings.currency} ${averageSpent.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}