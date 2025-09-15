import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'vehicle_model.g.dart';

@HiveType(typeId: 1)
class Vehicle extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String brand;

  @HiveField(2)
  final String model;

  @HiveField(3)
  final int year;

  @HiveField(4)
  final double tankCapacity;

  @HiveField(5)
  final double expectedConsumption;

  @HiveField(6)
  final int identificationColorValue; // Color.value

  @HiveField(7)
  final String? imagePath;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  @HiveField(10)
  final bool isActive;

  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.tankCapacity,
    required this.expectedConsumption,
    required this.identificationColorValue,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Vehicle.create({
    required String brand,
    required String model,
    required int year,
    required double tankCapacity,
    required double expectedConsumption,
    required int identificationColorValue,
    String? imagePath,
  }) {
    final now = DateTime.now();
    return Vehicle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      brand: brand,
      model: model,
      year: year,
      tankCapacity: tankCapacity,
      expectedConsumption: expectedConsumption,
      identificationColorValue: identificationColorValue,
      imagePath: imagePath,
      createdAt: now,
      updatedAt: now,
    );
  }

  Vehicle copyWith({
    String? brand,
    String? model,
    int? year,
    double? tankCapacity,
    double? expectedConsumption,
    int? identificationColorValue,
    String? imagePath,
    bool? isActive,
  }) {
    return Vehicle(
      id: id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      tankCapacity: tankCapacity ?? this.tankCapacity,
      expectedConsumption: expectedConsumption ?? this.expectedConsumption,
      identificationColorValue: identificationColorValue ?? this.identificationColorValue,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }

  String get displayName => '$brand $model $year';

  String get shortName => '${brand.substring(0, 3).toUpperCase()} ${model.substring(0, 3).toUpperCase()}';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'tankCapacity': tankCapacity,
      'expectedConsumption': expectedConsumption,
      'identificationColorValue': identificationColorValue,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      tankCapacity: json['tankCapacity'].toDouble(),
      expectedConsumption: json['expectedConsumption'].toDouble(),
      identificationColorValue: json['identificationColorValue'],
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        brand,
        model,
        year,
        tankCapacity,
        expectedConsumption,
        identificationColorValue,
        imagePath,
        isActive,
      ];
}