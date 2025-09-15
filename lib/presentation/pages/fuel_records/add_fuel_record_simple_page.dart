import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/fuel_record_model.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/models/fuel_type.dart';

class AddFuelRecordSimplePage extends StatefulWidget {
  final String? preselectedVehicleId;

  const AddFuelRecordSimplePage({Key? key, this.preselectedVehicleId}) : super(key: key);

  @override
  State<AddFuelRecordSimplePage> createState() => _AddFuelRecordSimplePageState();
}

class _AddFuelRecordSimplePageState extends State<AddFuelRecordSimplePage> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _litersController = TextEditingController();
  final _pricePerLiterController = TextEditingController();
  final _gasStationController = TextEditingController();
  final _notesController = TextEditingController();

  late Box<Vehicle> vehiclesBox;
  late Box<FuelRecord> fuelRecordsBox;

  Vehicle? _selectedVehicle;
  DateTime _selectedDate = DateTime.now();
  FuelType _selectedFuelType = FuelType.gasoline;
  bool _isFullTank = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    vehiclesBox = Hive.box<Vehicle>('vehicles');
    fuelRecordsBox = Hive.box<FuelRecord>('fuel_records');

    // Pré-selecionar primeiro veículo se existir
    if (vehiclesBox.isNotEmpty) {
      _selectedVehicle = vehiclesBox.values.first;
    }
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _litersController.dispose();
    _pricePerLiterController.dispose();
    _gasStationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (vehiclesBox.isEmpty) {
      return _buildNoVehiclesScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.addFuelRecord),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seletor de veículo
              Text(
                'Veículo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppDimensions.spacingSmall),
              DropdownButtonFormField<Vehicle>(
                value: _selectedVehicle,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                ),
                items: vehiclesBox.values.map((vehicle) {
                  return DropdownMenuItem<Vehicle>(
                    value: vehicle,
                    child: Text(vehicle.displayName),
                  );
                }).toList(),
                onChanged: (Vehicle? value) {
                  setState(() {
                    _selectedVehicle = value;
                  });
                },
                validator: (value) => value == null ? AppStrings.requiredField : null,
              ),

              SizedBox(height: AppDimensions.spacingMedium),

              // Tipo de combustível
              Text(
                'Tipo de Combustível',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppDimensions.spacingSmall),
              Wrap(
                spacing: AppDimensions.spacingSmall,
                children: FuelType.values.map((fuelType) {
                  final isSelected = _selectedFuelType == fuelType;
                  return FilterChip(
                    label: Text(fuelType.displayName),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          _selectedFuelType = fuelType;
                        });
                      }
                    },
                  );
                }).toList(),
              ),

              SizedBox(height: AppDimensions.spacingMedium),

              // Odômetro
              TextFormField(
                controller: _odometerController,
                decoration: InputDecoration(
                  labelText: 'Odômetro (km)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return AppStrings.requiredField;
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Número inválido';
                  }
                  return null;
                },
              ),

              SizedBox(height: AppDimensions.spacingMedium),

              // Litros
              TextFormField(
                controller: _litersController,
                decoration: InputDecoration(
                  labelText: 'Litros',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return AppStrings.requiredField;
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Número inválido';
                  }
                  return null;
                },
              ),

              SizedBox(height: AppDimensions.spacingMedium),

              // Preço por litro
              TextFormField(
                controller: _pricePerLiterController,
                decoration: InputDecoration(
                  labelText: 'Preço por Litro',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return AppStrings.requiredField;
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Número inválido';
                  }
                  return null;
                },
              ),

              SizedBox(height: AppDimensions.spacingMedium),

              // Posto de combustível
              TextFormField(
                controller: _gasStationController,
                decoration: InputDecoration(
                  labelText: 'Posto de Combustível (opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  prefixIcon: Icon(Icons.local_gas_station, color: AppColors.primary),
                ),
                textCapitalization: TextCapitalization.words,
              ),

              SizedBox(height: AppDimensions.spacingMedium),

              // Tanque completo
              Container(
                padding: EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_gas_station_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    SizedBox(width: AppDimensions.spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanque Completo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Marque se encheu o tanque completamente',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isFullTank,
                      onChanged: (value) {
                        setState(() {
                          _isFullTank = value;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppDimensions.spacingMedium),

              // Observações
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Observações (opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  prefixIcon: Icon(Icons.note, color: AppColors.primary),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),

              SizedBox(height: AppDimensions.spacingLarge * 2),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
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
                    onTap: _isLoading ? null : () => context.pop(),
                    child: Center(
                      child: Text(
                        AppStrings.cancel,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              flex: 2,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isLoading
                        ? [
                            AppColors.textSecondary.withValues(alpha: 0.3),
                            AppColors.textSecondary.withValues(alpha: 0.2),
                          ]
                        : [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.8),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isLoading ? [] : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _isLoading ? null : _saveFuelRecord,
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(AppColors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.save_rounded,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  AppStrings.save,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoVehiclesScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.addFuelRecord),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning,
                size: 80,
                color: AppColors.warning,
              ),
              SizedBox(height: AppDimensions.spacingLarge),
              Text(
                'Nenhum veículo cadastrado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppDimensions.spacingSmall),
              Text(
                'Você precisa cadastrar um veículo antes de registrar abastecimentos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppDimensions.spacingLarge),
              ElevatedButton.icon(
                onPressed: () {
                  context.pop();
                  context.push('/add-vehicle');
                },
                icon: Icon(Icons.add),
                label: Text(AppStrings.addVehicle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveFuelRecord() async {
    if (!_formKey.currentState!.validate() || _selectedVehicle == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final fuelRecord = FuelRecord.create(
        vehicleId: _selectedVehicle!.id,
        date: _selectedDate,
        odometer: double.parse(_odometerController.text),
        liters: double.parse(_litersController.text),
        pricePerLiter: double.parse(_pricePerLiterController.text),
        fuelType: _selectedFuelType,
        isFullTank: _isFullTank,
        gasStationName: _gasStationController.text.trim().isEmpty ? null : _gasStationController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      await fuelRecordsBox.add(fuelRecord);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.savedSuccessfully),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}