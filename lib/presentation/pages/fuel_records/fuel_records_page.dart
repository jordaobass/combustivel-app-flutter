import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/fuel_record_model.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/models/fuel_type.dart';

class FuelRecordsPage extends StatefulWidget {
  const FuelRecordsPage({Key? key}) : super(key: key);

  @override
  State<FuelRecordsPage> createState() => _FuelRecordsPageState();
}

class _FuelRecordsPageState extends State<FuelRecordsPage> {
  late Box<FuelRecord> fuelRecordsBox;
  late Box<Vehicle> vehiclesBox;
  String? selectedVehicleId;
  final dateFormat = DateFormat('dd/MM/yyyy');

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
        title: Text(AppStrings.fuelRecords),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          if (vehiclesBox.isNotEmpty)
            PopupMenuButton<String>(
              icon: Icon(Icons.filter_list),
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
                    child: Text(AppStrings.allVehicles),
                  ),
                  PopupMenuDivider(),
                  ...vehicles.map((vehicle) {
                    return PopupMenuItem(
                      value: vehicle.id,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(vehicle.identificationColorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: AppDimensions.spacingSmall),
                          Expanded(child: Text(vehicle.displayName)),
                        ],
                      ),
                    );
                  }).toList(),
                ];
              },
            ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: fuelRecordsBox.listenable(),
        builder: (context, Box<FuelRecord> box, _) {
          var records = box.values.toList();

          // Filtrar por veículo se selecionado
          if (selectedVehicleId != null) {
            records = records.where((r) => r.vehicleId == selectedVehicleId).toList();
          }

          // Ordenar por data (mais recente primeiro)
          records.sort((a, b) => b.date.compareTo(a.date));

          if (records.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              setState(() {});
            },
            child: Column(
              children: [
                if (selectedVehicleId != null) _buildFilterIndicator(),
                // Botão fixo no topo
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.addFuelRecord),
                    icon: Icon(Icons.add, size: 20),
                    label: Text('Adicionar Novo Abastecimento'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingLarge,
                        vertical: AppDimensions.paddingMedium,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(AppDimensions.paddingMedium),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      return _buildFuelRecordCard(records[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_gas_station_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppDimensions.spacingLarge),
            Text(
              selectedVehicleId != null
                  ? 'Nenhum abastecimento para este veículo'
                  : AppStrings.noFuelRecords,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppDimensions.spacingSmall),
            Text(
              AppStrings.addFirstFuelRecord,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppDimensions.spacingLarge),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.addFuelRecord),
              icon: Icon(Icons.add),
              label: Text(AppStrings.addFuelRecord),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterIndicator() {
    final vehicle = vehiclesBox.values
        .where((v) => v.id == selectedVehicleId)
        .firstOrNull;

    if (vehicle == null) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: AppColors.primary.withValues(alpha: 0.1),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 18, color: AppColors.primary),
          SizedBox(width: AppDimensions.spacingSmall),
          Text(
            'Filtrando por: ${vehicle.displayName}',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedVehicleId = null;
              });
            },
            child: Icon(Icons.close, size: 18, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelRecordCard(FuelRecord record) {
    final vehicle = vehiclesBox.values
        .where((v) => v.id == record.vehicleId)
        .firstOrNull;

    final fuelColor = AppColors.getFuelTypeColor(record.fuelType.name);

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        fuelColor,
                        fuelColor.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: fuelColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.local_gas_station_rounded,
                    color: AppColors.white,
                    size: 32,
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
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(width: AppDimensions.spacingSmall),
                          if (record.isFullTank)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.success.withValues(alpha: 0.2),
                                    AppColors.success.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.success.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'COMPLETO',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.spacingSmall),
                      if (vehicle != null)
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Color(vehicle.identificationColorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: AppDimensions.spacingSmall),
                            Text(
                              vehicle.displayName,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
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
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      dateFormat.format(record.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Divider(height: AppDimensions.spacingLarge),

            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Litros',
                    '${record.liters.toStringAsFixed(1)}L',
                    Icons.local_gas_station,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Preço/L',
                    '${AppStrings.currency} ${record.pricePerLiter.toStringAsFixed(3)}',
                    Icons.attach_money,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Odômetro',
                    '${record.odometer.toStringAsFixed(0)} km',
                    Icons.speed,
                  ),
                ),
              ],
            ),

            if (record.gasStationName != null || record.notes != null)
              Column(
                children: [
                  SizedBox(height: AppDimensions.spacingMedium),
                  if (record.gasStationName != null)
                    Row(
                      children: [
                        Icon(Icons.place, size: 16, color: AppColors.textSecondary),
                        SizedBox(width: AppDimensions.spacingSmall),
                        Expanded(
                          child: Text(
                            record.gasStationName!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (record.notes != null)
                    Padding(
                      padding: EdgeInsets.only(top: AppDimensions.spacingSmall),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.note, size: 16, color: AppColors.textSecondary),
                          SizedBox(width: AppDimensions.spacingSmall),
                          Expanded(
                            child: Text(
                              record.notes!,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}