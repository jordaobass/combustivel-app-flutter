import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/fuel_record_model.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/models/fuel_type.dart';

class AddFuelRecordPage extends StatefulWidget {
  final String? preselectedVehicleId;

  const AddFuelRecordPage({Key? key, this.preselectedVehicleId}) : super(key: key);

  @override
  State<AddFuelRecordPage> createState() => _AddFuelRecordPageState();
}

class _AddFuelRecordPageState extends State<AddFuelRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _odometerController = TextEditingController();
  final _litersController = TextEditingController();
  final _pricePerLiterController = TextEditingController();
  final _totalCostController = TextEditingController();
  final _gasStationController = TextEditingController();

  late Box<Vehicle> vehiclesBox;
  late Box<FuelRecord> fuelRecordsBox;

  Vehicle? _selectedVehicle;
  DateTime _selectedDate = DateTime.now();
  FuelType _selectedFuelType = FuelType.gasoline;
  bool _isFullTank = true;
  bool _isLoading = false;
  bool _autoCalculateTotal = true;

  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    vehiclesBox = Hive.box<Vehicle>('vehicles');
    fuelRecordsBox = Hive.box<FuelRecord>('fuel_records');
    _initializeData();
  }

  void _initializeData() {
    _dateController.text = dateFormat.format(_selectedDate);

    // Pré-selecionar veículo se fornecido
    if (widget.preselectedVehicleId != null) {
      final vehicle = vehiclesBox.values
          .where((v) => v.id == widget.preselectedVehicleId)
          .firstOrNull;
      if (vehicle != null) {
        _selectedVehicle = vehicle;
      }
    }

    // Se não há veículo pré-selecionado e há apenas um veículo, selecionar automaticamente
    if (_selectedVehicle == null && vehiclesBox.length == 1) {
      _selectedVehicle = vehiclesBox.values.first;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _odometerController.dispose();
    _litersController.dispose();
    _pricePerLiterController.dispose();
    _totalCostController.dispose();
    _gasStationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.addFuelRecord),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          if (_isLoading)
            Container(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVehicleSelector(),
              SizedBox(height: AppDimensions.spacingLarge),

              _buildDateSelector(),
              SizedBox(height: AppDimensions.spacingMedium),

              _buildTextField(
                controller: _odometerController,
                label: AppStrings.odometer + ' (km)',
                hint: 'Ex: 15000',
                icon: Icons.speed,
                keyboardType: TextInputType.number,
                validator: _validateOdometer,
              ),
              SizedBox(height: AppDimensions.spacingMedium),

              _buildFuelTypeSelector(),
              SizedBox(height: AppDimensions.spacingMedium),

              _buildFullTankSwitch(),
              SizedBox(height: AppDimensions.spacingMedium),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _litersController,
                      label: AppStrings.liters,
                      hint: 'Ex: 35.5',
                      icon: Icons.local_gas_station,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => _calculateTotal(),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppStrings.requiredField;
                        }
                        final liters = double.tryParse(value!);
                        if (liters == null || liters <= 0) {
                          return AppStrings.invalidNumber;
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacingMedium),
                  Expanded(
                    child: _buildTextField(
                      controller: _pricePerLiterController,
                      label: AppStrings.pricePerLiter,
                      hint: 'Ex: 5.899',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => _calculateTotal(),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppStrings.requiredField;
                        }
                        final price = double.tryParse(value!);
                        if (price == null || price <= 0) {
                          return AppStrings.invalidNumber;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.spacingMedium),

              _buildTextField(
                controller: _totalCostController,
                label: AppStrings.totalCost,
                hint: 'Ex: 200.50',
                icon: Icons.receipt,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                enabled: !_autoCalculateTotal,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return AppStrings.requiredField;
                  }
                  final cost = double.tryParse(value!);
                  if (cost == null || cost <= 0) {
                    return AppStrings.invalidNumber;
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    _autoCalculateTotal ? Icons.calculate : Icons.edit,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _autoCalculateTotal = !_autoCalculateTotal;
                      if (_autoCalculateTotal) {
                        _calculateTotal();
                      }
                    });
                  },
                ),
              ),

              SizedBox(height: AppDimensions.spacingLarge),

              _buildTextField(
                controller: _gasStationController,
                label: AppStrings.gasStation + ' (opcional)',
                hint: 'Ex: Posto Shell',
                icon: Icons.place,
              ),

              SizedBox(height: AppDimensions.spacingLarge * 2),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => context.pop(),
                child: Text(AppStrings.cancel),
              ),
            ),
            SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveFuelRecord,
                child: Text(AppStrings.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelector() {
    final vehicles = vehiclesBox.values.toList();

    if (vehicles.isEmpty) {
      return Column(
        children: [
          Card(
            color: AppColors.warning.withValues(alpha: 0.1),
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingMedium),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.warning),
                  SizedBox(width: AppDimensions.spacingMedium),
                  Expanded(
                    child: Text(
                      'Você precisa cadastrar um veículo antes de registrar abastecimentos.',
                      style: TextStyle(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppDimensions.spacingMedium),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.addVehicle),
            icon: Icon(Icons.add),
            label: Text(AppStrings.addVehicle),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Veículo *',
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
            prefixIcon: Icon(Icons.directions_car, color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
          ),
          hint: Text('Selecione um veículo'),
          validator: (value) {
            if (value == null) {
              return AppStrings.requiredField;
            }
            return null;
          },
          onChanged: (Vehicle? newValue) {
            setState(() {
              _selectedVehicle = newValue;
            });
          },
          items: vehicles.map<DropdownMenuItem<Vehicle>>((Vehicle vehicle) {
            return DropdownMenuItem<Vehicle>(
              value: vehicle,
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
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: AppStrings.fuelDate + ' *',
        prefixIcon: Icon(Icons.calendar_today, color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_month, color: AppColors.primary),
          onPressed: _selectDate,
        ),
      ),
      onTap: _selectDate,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return AppStrings.requiredField;
        }
        return null;
      },
    );
  }

  Widget _buildFuelTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.fuelType + ' *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppDimensions.spacingSmall),
        Wrap(
          spacing: AppDimensions.spacingMedium,
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
              selectedColor: AppColors.getFuelTypeColor(fuelType.name).withValues(alpha: 0.3),
              backgroundColor: AppColors.cardBackground,
              side: BorderSide(
                color: isSelected
                    ? AppColors.getFuelTypeColor(fuelType.name)
                    : AppColors.divider,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFullTankSwitch() {
    return SwitchListTile(
      title: Text(AppStrings.fullTank),
      subtitle: Text(_isFullTank ? 'Abastecimento completo' : 'Abastecimento parcial'),
      value: _isFullTank,
      onChanged: (bool value) {
        setState(() {
          _isFullTank = value;
        });
      },
      activeThumbColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int maxLines = 1,
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: BorderSide(color: AppColors.divider),
        ),
      ),
    );
  }

  String? _validateOdometer(String? value) {
    if (value?.isEmpty ?? true) {
      return AppStrings.requiredField;
    }

    final odometer = double.tryParse(value!);
    if (odometer == null || odometer <= 0) {
      return AppStrings.invalidNumber;
    }

    // Verificar se o odômetro é maior que o último registro
    if (_selectedVehicle != null) {
      final lastRecord = fuelRecordsBox.values
          .where((r) => r.vehicleId == _selectedVehicle!.id)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      if (lastRecord.isNotEmpty) {
        final lastOdometer = lastRecord.first.odometer;
        if (odometer < lastOdometer) {
          return 'Odômetro deve ser maior que ${lastOdometer.toStringAsFixed(0)} km';
        }
      }
    }

    return null;
  }

  void _calculateTotal() {
    if (_autoCalculateTotal) {
      final liters = double.tryParse(_litersController.text);
      final pricePerLiter = double.tryParse(_pricePerLiterController.text);

      if (liters != null && pricePerLiter != null) {
        final total = liters * pricePerLiter;
        _totalCostController.text = total.toStringAsFixed(2);
      }
    }
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = dateFormat.format(picked);
      });
    }
  }

  void _saveFuelRecord() async {
    if (!_formKey.currentState!.validate()) {
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
        gasStationName: _gasStationController.text.isEmpty ? null : _gasStationController.text,
      );

      await fuelRecordsBox.add(fuelRecord);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.savedSuccessfully),
          backgroundColor: AppColors.success,
        ),
      );

      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.genericError),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}