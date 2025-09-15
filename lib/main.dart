import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/models/fuel_type.dart';
import 'data/models/vehicle_model.dart';
import 'data/models/fuel_record_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(FuelTypeAdapter());
  Hive.registerAdapter(VehicleAdapter());
  Hive.registerAdapter(FuelRecordAdapter());

  await Hive.openBox<Vehicle>('vehicles');
  await Hive.openBox<FuelRecord>('fuel_records');

  runApp(CombustivelApp());
}