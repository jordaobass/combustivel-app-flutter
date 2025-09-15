import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'fuel_type.dart';

part 'fuel_record_model.g.dart';

@HiveType(typeId: 2)
class FuelRecord extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String vehicleId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final double odometer;

  @HiveField(4)
  final double liters;

  @HiveField(5)
  final double pricePerLiter;

  @HiveField(6)
  final double totalCost;

  @HiveField(7)
  final FuelType fuelType;

  @HiveField(8)
  final bool isFullTank;

  @HiveField(9)
  final String? gasStationId;

  @HiveField(10)
  final String? gasStationName;

  @HiveField(11)
  final double? latitude;

  @HiveField(12)
  final double? longitude;

  @HiveField(13)
  final String? receiptImagePath;

  @HiveField(14)
  final String? notes;

  @HiveField(15)
  final DateTime createdAt;

  @HiveField(16)
  final DateTime updatedAt;

  FuelRecord({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.odometer,
    required this.liters,
    required this.pricePerLiter,
    required this.totalCost,
    required this.fuelType,
    required this.isFullTank,
    this.gasStationId,
    this.gasStationName,
    this.latitude,
    this.longitude,
    this.receiptImagePath,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FuelRecord.create({
    required String vehicleId,
    required DateTime date,
    required double odometer,
    required double liters,
    required double pricePerLiter,
    required FuelType fuelType,
    required bool isFullTank,
    String? gasStationId,
    String? gasStationName,
    double? latitude,
    double? longitude,
    String? receiptImagePath,
    String? notes,
  }) {
    final now = DateTime.now();
    return FuelRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      vehicleId: vehicleId,
      date: date,
      odometer: odometer,
      liters: liters,
      pricePerLiter: pricePerLiter,
      totalCost: liters * pricePerLiter,
      fuelType: fuelType,
      isFullTank: isFullTank,
      gasStationId: gasStationId,
      gasStationName: gasStationName,
      latitude: latitude,
      longitude: longitude,
      receiptImagePath: receiptImagePath,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  FuelRecord copyWith({
    DateTime? date,
    double? odometer,
    double? liters,
    double? pricePerLiter,
    FuelType? fuelType,
    bool? isFullTank,
    String? gasStationId,
    String? gasStationName,
    double? latitude,
    double? longitude,
    String? receiptImagePath,
    String? notes,
  }) {
    final newLiters = liters ?? this.liters;
    final newPricePerLiter = pricePerLiter ?? this.pricePerLiter;

    return FuelRecord(
      id: id,
      vehicleId: vehicleId,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      liters: newLiters,
      pricePerLiter: newPricePerLiter,
      totalCost: newLiters * newPricePerLiter,
      fuelType: fuelType ?? this.fuelType,
      isFullTank: isFullTank ?? this.isFullTank,
      gasStationId: gasStationId ?? this.gasStationId,
      gasStationName: gasStationName ?? this.gasStationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Calcula o consumo baseado no registro anterior
  double? calculateConsumption(double previousOdometer) {
    final kmTraveled = odometer - previousOdometer;
    if (kmTraveled <= 0 || liters <= 0) return null;
    return kmTraveled / liters;
  }

  /// Calcula custo por quilômetro baseado no registro anterior
  double? calculateCostPerKm(double previousOdometer) {
    final kmTraveled = odometer - previousOdometer;
    if (kmTraveled <= 0) return null;
    return totalCost / kmTraveled;
  }

  /// Verifica se tem localização
  bool get hasLocation => latitude != null && longitude != null;

  /// Formata a localização
  String? get locationString {
    if (!hasLocation) return null;
    return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date.toIso8601String(),
      'odometer': odometer,
      'liters': liters,
      'pricePerLiter': pricePerLiter,
      'totalCost': totalCost,
      'fuelType': fuelType.name,
      'isFullTank': isFullTank,
      'gasStationId': gasStationId,
      'gasStationName': gasStationName,
      'latitude': latitude,
      'longitude': longitude,
      'receiptImagePath': receiptImagePath,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FuelRecord.fromJson(Map<String, dynamic> json) {
    return FuelRecord(
      id: json['id'],
      vehicleId: json['vehicleId'],
      date: DateTime.parse(json['date']),
      odometer: json['odometer'].toDouble(),
      liters: json['liters'].toDouble(),
      pricePerLiter: json['pricePerLiter'].toDouble(),
      totalCost: json['totalCost'].toDouble(),
      fuelType: FuelType.values.firstWhere((e) => e.name == json['fuelType']),
      isFullTank: json['isFullTank'],
      gasStationId: json['gasStationId'],
      gasStationName: json['gasStationName'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      receiptImagePath: json['receiptImagePath'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        date,
        odometer,
        liters,
        pricePerLiter,
        totalCost,
        fuelType,
        isFullTank,
        gasStationId,
        gasStationName,
        latitude,
        longitude,
        receiptImagePath,
        notes,
      ];
}