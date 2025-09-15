import 'package:hive/hive.dart';

part 'fuel_type.g.dart';

@HiveType(typeId: 0)
enum FuelType {
  @HiveField(0)
  gasoline,

  @HiveField(1)
  ethanol,

  @HiveField(2)
  diesel,

  @HiveField(3)
  gnv,
}

extension FuelTypeExtension on FuelType {
  String get displayName {
    switch (this) {
      case FuelType.gasoline:
        return 'Gasolina';
      case FuelType.ethanol:
        return 'Etanol';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.gnv:
        return 'GNV';
    }
  }

  String get shortName {
    switch (this) {
      case FuelType.gasoline:
        return 'GAS';
      case FuelType.ethanol:
        return 'ETA';
      case FuelType.diesel:
        return 'DIE';
      case FuelType.gnv:
        return 'GNV';
    }
  }
}