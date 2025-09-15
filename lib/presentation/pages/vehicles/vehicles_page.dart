import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/vehicle_model.dart';
import '../../widgets/states/empty_state.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({Key? key}) : super(key: key);

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  late Box<Vehicle> vehiclesBox;

  @override
  void initState() {
    super.initState();
    vehiclesBox = Hive.box<Vehicle>('vehicles');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.vehicles),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: vehiclesBox.listenable(),
        builder: (context, Box<Vehicle> box, _) {
          final vehicles = box.values.toList();

          if (vehicles.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
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
                  onPressed: () => context.push(AppRoutes.addVehicle),
                  icon: Icon(Icons.add, size: 20),
                  label: Text('Adicionar Novo Veículo'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingLarge,
                      vertical: AppDimensions.paddingMedium,
                    ),
                  ),
                ),
              ),
              // Lista de veículos
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(AppDimensions.paddingMedium),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      return _buildVehicleCard(vehicles[index]);
                    },
                  ),
                ),
              ),
            ],
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
      onButtonPressed: () => context.push(AppRoutes.addVehicle),
      iconColor: AppColors.primary,
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _addFuelRecord(vehicle.id),
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
                            Color(vehicle.identificationColorValue),
                            Color(vehicle.identificationColorValue).withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(vehicle.identificationColorValue).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.directions_car_rounded,
                        color: AppColors.white,
                        size: 32,
                      ),
                    ),
                SizedBox(width: AppDimensions.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.displayName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${AppStrings.tankCapacity}: ${vehicle.tankCapacity.toStringAsFixed(0)}L',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, vehicle),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20, color: AppColors.textSecondary),
                          SizedBox(width: AppDimensions.spacingSmall),
                          Text(AppStrings.edit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: AppColors.error),
                          SizedBox(width: AppDimensions.spacingSmall),
                          Text(AppStrings.delete, style: TextStyle(color: AppColors.error)),
                        ],
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
                  child: _buildInfoChip(
                    AppStrings.expectedConsumption,
                    '${vehicle.expectedConsumption.toStringAsFixed(1)} ${AppStrings.kmPerLiter}',
                    Icons.speed,
                    AppColors.info,
                  ),
                ),
                SizedBox(width: AppDimensions.spacingMedium),
                Expanded(
                  child: _buildInfoChip(
                    'Status',
                    vehicle.isActive ? 'Ativo' : 'Inativo',
                    Icons.check_circle,
                    vehicle.isActive ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.spacingMedium),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _addFuelRecord(vehicle.id),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_gas_station_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Adicionar Abastecimento',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
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
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Vehicle vehicle) {
    switch (action) {
      case 'edit':
        _editVehicle(vehicle);
        break;
      case 'delete':
        _showDeleteConfirmation(vehicle);
        break;
    }
  }

  void _editVehicle(Vehicle vehicle) {
    context.push('${AppRoutes.addVehicle}?id=${vehicle.id}');
  }

  void _showDeleteConfirmation(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.confirm),
        content: Text('Deseja realmente excluir o veículo ${vehicle.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteVehicle(vehicle);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _deleteVehicle(Vehicle vehicle) {
    vehicle.delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Veículo ${vehicle.displayName} excluído com sucesso'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _addFuelRecord(String vehicleId) {
    context.push('${AppRoutes.addFuelRecord}?vehicleId=$vehicleId');
  }
}