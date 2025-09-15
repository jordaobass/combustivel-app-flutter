import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/vehicle_model.dart';

class AddVehiclePage extends StatefulWidget {
  final String? vehicleId;

  const AddVehiclePage({Key? key, this.vehicleId}) : super(key: key);

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _tankCapacityController = TextEditingController();
  final _expectedConsumptionController = TextEditingController();

  late Box<Vehicle> vehiclesBox;
  Vehicle? _editingVehicle;
  Color _selectedColor = AppColors.primary;
  bool _isLoading = false;

  final List<Color> _availableColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.error,
    AppColors.warning,
    AppColors.info,
    AppColors.success,
    Color(0xFF9C27B0), // Purple
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFFFF5722), // Deep Orange
  ];

  @override
  void initState() {
    super.initState();
    vehiclesBox = Hive.box<Vehicle>('vehicles');
    _loadVehicleData();
  }

  void _loadVehicleData() {
    if (widget.vehicleId != null) {
      final vehicle = vehiclesBox.values
          .where((v) => v.id == widget.vehicleId)
          .firstOrNull;

      if (vehicle != null) {
        _editingVehicle = vehicle;
        _brandController.text = vehicle.brand;
        _modelController.text = vehicle.model;
        _yearController.text = vehicle.year.toString();
        _tankCapacityController.text = vehicle.tankCapacity.toString();
        _expectedConsumptionController.text = vehicle.expectedConsumption.toString();
        _selectedColor = Color(vehicle.identificationColorValue);
      }
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _tankCapacityController.dispose();
    _expectedConsumptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingVehicle != null ? AppStrings.editVehicle : AppStrings.addVehicle),
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
              _buildTextField(
                controller: _brandController,
                label: AppStrings.vehicleBrand,
                hint: 'Ex: Honda, Toyota, Volkswagen',
                icon: Icons.business,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return AppStrings.requiredField;
                  }
                  if (value!.length < 2) {
                    return 'Marca deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppDimensions.spacingMedium),

              _buildTextField(
                controller: _modelController,
                label: AppStrings.vehicleModel,
                hint: 'Ex: Civic, Corolla, Gol',
                icon: Icons.directions_car,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return AppStrings.requiredField;
                  }
                  if (value!.length < 2) {
                    return 'Modelo deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppDimensions.spacingMedium),

              _buildTextField(
                controller: _yearController,
                label: AppStrings.vehicleYear,
                hint: 'Ex: 2020',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return AppStrings.requiredField;
                  }
                  final year = int.tryParse(value!);
                  if (year == null) {
                    return AppStrings.invalidNumber;
                  }
                  final currentYear = DateTime.now().year;
                  if (year < 1900 || year > currentYear + 1) {
                    return 'Ano deve estar entre 1900 e ${currentYear + 1}';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppDimensions.spacingMedium),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _tankCapacityController,
                      label: AppStrings.tankCapacity,
                      hint: 'Ex: 50',
                      icon: Icons.local_gas_station,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppStrings.requiredField;
                        }
                        final capacity = double.tryParse(value!);
                        if (capacity == null) {
                          return AppStrings.invalidNumber;
                        }
                        if (capacity <= 0 || capacity > 200) {
                          return 'Capacidade deve estar entre 1 e 200 litros';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacingMedium),
                  Expanded(
                    child: _buildTextField(
                      controller: _expectedConsumptionController,
                      label: AppStrings.expectedConsumption,
                      hint: 'Ex: 12.5',
                      icon: Icons.speed,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppStrings.requiredField;
                        }
                        final consumption = double.tryParse(value!);
                        if (consumption == null) {
                          return AppStrings.invalidNumber;
                        }
                        if (consumption <= 0 || consumption > 50) {
                          return 'Consumo deve estar entre 1 e 50 km/L';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppDimensions.spacingLarge),

              Text(
                AppStrings.vehicleColor,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppDimensions.spacingMedium),

              _buildColorPicker(),

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
                onPressed: _isLoading ? null : _saveVehicle,
                child: Text(_editingVehicle != null ? 'Atualizar' : AppStrings.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: AppDimensions.spacingMedium,
      runSpacing: AppDimensions.spacingMedium,
      children: _availableColors.map((color) {
        final isSelected = color.value == _selectedColor.value;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.textPrimary : AppColors.divider,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 24,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  void _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_editingVehicle != null) {
        // Editando veículo existente
        final updatedVehicle = _editingVehicle!.copyWith(
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          year: int.parse(_yearController.text),
          tankCapacity: double.parse(_tankCapacityController.text),
          expectedConsumption: double.parse(_expectedConsumptionController.text),
          identificationColorValue: _selectedColor.value,
        );

        // Atualizar os valores do objeto existente
        final index = vehiclesBox.values.toList().indexWhere((v) => v.id == _editingVehicle!.id);
        if (index >= 0) {
          await vehiclesBox.putAt(index, updatedVehicle);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.updatedSuccessfully),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        // Criando novo veículo
        final vehicle = Vehicle.create(
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          year: int.parse(_yearController.text),
          tankCapacity: double.parse(_tankCapacityController.text),
          expectedConsumption: double.parse(_expectedConsumptionController.text),
          identificationColorValue: _selectedColor.value,
        );

        await vehiclesBox.add(vehicle);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.savedSuccessfully),
            backgroundColor: AppColors.success,
          ),
        );
      }

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