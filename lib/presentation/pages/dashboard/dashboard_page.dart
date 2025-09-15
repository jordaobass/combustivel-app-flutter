import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/models/fuel_record_model.dart';
import '../../../data/models/fuel_type.dart';
import '../../widgets/cards/info_card.dart';
import '../../widgets/states/empty_state.dart';
import '../../../core/widgets/app_logo.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Box<Vehicle> vehiclesBox;
  late Box<FuelRecord> fuelRecordsBox;
  String? selectedVehicleId;

  @override
  void initState() {
    super.initState();
    vehiclesBox = Hive.box<Vehicle>('vehicles');
    fuelRecordsBox = Hive.box<FuelRecord>('fuel_records');
    _addSampleData();

    // Seleciona o primeiro veículo por padrão
    if (vehiclesBox.isNotEmpty) {
      selectedVehicleId = vehiclesBox.values.first.id;
    }
  }

  void _addSampleData() {
    if (vehiclesBox.isEmpty) {
      final vehicle = Vehicle.create(
        brand: 'Honda',
        model: 'Civic',
        year: 2020,
        tankCapacity: 47.0,
        expectedConsumption: 12.5,
        identificationColorValue: 0xFF2E7D32,
      );
      vehiclesBox.add(vehicle);

      final fuelRecord = FuelRecord.create(
        vehicleId: vehicle.id,
        date: DateTime.now().subtract(Duration(days: 5)),
        odometer: 15000.0,
        liters: 35.0,
        pricePerLiter: 5.85,
        fuelType: FuelType.gasoline,
        isFullTank: true,
        gasStationName: 'Posto BR',
        notes: 'Primeiro abastecimento registrado',
      );
      fuelRecordsBox.add(fuelRecord);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            AppIcon(size: 32),
            SizedBox(width: 12),
            Text(
              AppStrings.dashboard,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (vehiclesBox.isNotEmpty)
            PopupMenuButton<String>(
              icon: Icon(Icons.directions_car, size: 24),
              tooltip: 'Selecionar Veículo',
              onSelected: (value) {
                setState(() {
                  selectedVehicleId = value == 'all' ? null : value;
                });
              },
              itemBuilder: (context) {
                final vehicles = vehiclesBox.values.toList();
                return [
                  PopupMenuItem(
                    value: 'all',
                    child: Row(
                      children: [
                        Icon(Icons.all_inclusive, size: 20, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Todos os Veículos',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuDivider(),
                  ...vehicles.map((vehicle) {
                    return PopupMenuItem(
                      value: vehicle.id,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Color(vehicle.identificationColorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              vehicle.displayName,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          if (selectedVehicleId == vehicle.id)
                            Icon(Icons.check, size: 16, color: AppColors.primary),
                        ],
                      ),
                    );
                  }).toList(),
                ];
              },
            ),
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.notifications_outlined,
              size: 24,
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Vehicle>('vehicles').listenable(),
        builder: (context, Box<Vehicle> vehiclesBox, _) {
          if (vehiclesBox.isEmpty) {
            return _buildEmptyState();
          }

          return ValueListenableBuilder(
            valueListenable: Hive.box<FuelRecord>('fuel_records').listenable(),
            builder: (context, Box<FuelRecord> fuelRecordsBox, _) {
              return _buildDashboard(vehiclesBox, fuelRecordsBox);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.directions_car_outlined,
      title: AppStrings.noVehicles,
      subtitle: AppStrings.addFirstVehicle,
      buttonText: AppStrings.addVehicle,
      onButtonPressed: _addVehicle,
      iconColor: AppColors.primary,
    );
  }

  Widget _buildDashboard(Box<Vehicle> vehiclesBox, Box<FuelRecord> fuelRecordsBox) {
    var vehicles = vehiclesBox.values.toList();
    var records = fuelRecordsBox.values.toList();

    // Filtrar dados baseado no veículo selecionado
    if (selectedVehicleId != null) {
      vehicles = vehicles.where((v) => v.id == selectedVehicleId).toList();
      records = records.where((r) => r.vehicleId == selectedVehicleId).toList();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        setState(() {});
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedVehicleId != null) _buildFilterIndicator(),
            _buildMetricsSection(records),
            SizedBox(height: AppDimensions.spacingLarge),
            _buildRecentRecordsSection(records),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection(List<FuelRecord> records) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    // Gasto do mês atual
    final monthlyRecords = records.where((record) =>
      record.date.isAfter(currentMonth.subtract(Duration(days: 1)))).toList();
    final monthlySpent = monthlyRecords.fold<double>(0, (sum, record) => sum + record.totalCost);

    // Gasto total
    final totalSpent = records.fold<double>(0, (sum, record) => sum + record.totalCost);
    final totalLiters = records.fold<double>(0, (sum, record) => sum + record.liters);
    final avgPrice = totalLiters > 0 ? totalSpent / totalLiters : 0.0;

    // Calcular consumo médio do mês
    double monthlyConsumption = 0;
    int consumptionCount = 0;
    for (int i = 1; i < monthlyRecords.length; i++) {
      if (monthlyRecords[i].vehicleId == monthlyRecords[i-1].vehicleId && monthlyRecords[i].isFullTank) {
        final consumption = monthlyRecords[i].calculateConsumption(monthlyRecords[i-1].odometer);
        if (consumption != null) {
          monthlyConsumption += consumption;
          consumptionCount++;
        }
      }
    }
    if (consumptionCount > 0) {
      monthlyConsumption = monthlyConsumption / consumptionCount;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumo do Mês',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppDimensions.spacingMedium),

        // Card principal do mês
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppDimensions.paddingLarge),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, color: AppColors.white, size: 24),
                  SizedBox(width: AppDimensions.spacingSmall),
                  Text(
                    'Gastos de ${_getMonthName(now.month)}',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.spacingSmall),
              Text(
                '${AppStrings.currency} ${monthlySpent.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (monthlyRecords.isNotEmpty)
                Text(
                  '${monthlyRecords.length} abastecimentos',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),

        SizedBox(height: AppDimensions.spacingMedium),

        // Métricas secundárias
        Row(
          children: [
            Expanded(child: _buildMetricCard(
              'Consumo Médio',
              monthlyConsumption > 0
                ? '${monthlyConsumption.toStringAsFixed(1)} km/L'
                : 'N/A',
              AppColors.info,
              Icons.speed,
            )),
            SizedBox(width: AppDimensions.spacingSmall),
            Expanded(child: _buildMetricCard(
              'Preço Médio',
              '${AppStrings.currency} ${avgPrice.toStringAsFixed(3)}/L',
              AppColors.success,
              Icons.trending_up,
            )),
          ],
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }

  Widget _buildMetricCard(String title, String value, Color color, IconData icon) {
    return InfoCard(
      title: title,
      value: value,
      icon: icon,
      color: color,
      isCompact: false,
    );
  }

  Widget _buildRecentRecordsSection(List<FuelRecord> records) {
    final recentRecords = records.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.fuelRecords,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: _addFuelRecord,
              icon: Icon(Icons.add, color: AppColors.primary),
              label: Text(
                AppStrings.add,
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacingMedium),
        if (recentRecords.isEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingLarge),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.local_gas_station_outlined,
                      size: 40,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: AppDimensions.spacingMedium),
                    Text(
                      AppStrings.noFuelRecords,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...recentRecords.map((record) => _buildRecordCard(record)),
      ],
    );
  }

  Widget _buildRecordCard(FuelRecord record) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingSmall),
      padding: EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.getFuelTypeColor(record.fuelType.name).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.getFuelTypeColor(record.fuelType.name).withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.local_gas_station,
              color: AppColors.getFuelTypeColor(record.fuelType.name),
              size: 22,
            ),
          ),
          SizedBox(width: AppDimensions.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      record.fuelType.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${record.liters.toStringAsFixed(1)}L',
                        style: TextStyle(
                          color: AppColors.info,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  record.gasStationName ?? 'Posto não informado',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${AppStrings.currency} ${record.totalCost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              Text(
                '${AppStrings.currency} ${record.pricePerLiter.toStringAsFixed(3)}/L',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusMedium),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.directions_car, color: AppColors.primary),
              title: Text(AppStrings.addVehicle),
              onTap: () {
                Navigator.pop(context);
                _addVehicle();
              },
            ),
            ListTile(
              leading: Icon(Icons.local_gas_station, color: AppColors.primary),
              title: Text(AppStrings.addFuelRecord),
              onTap: () {
                Navigator.pop(context);
                _addFuelRecord();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addVehicle() {
    context.push(AppRoutes.addVehicle);
  }

  void _addFuelRecord() {
    context.push(AppRoutes.addFuelRecord);
  }

  Widget _buildFilterIndicator() {
    final vehicle = vehiclesBox.values
        .where((v) => v.id == selectedVehicleId)
        .firstOrNull;

    if (vehicle == null) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingMedium),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(vehicle.identificationColorValue),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.directions_car_rounded,
              color: AppColors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visualizando dados de:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  vehicle.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedVehicleId = null;
              });
            },
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}