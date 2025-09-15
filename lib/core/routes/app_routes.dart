import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../presentation/pages/dashboard/dashboard_page.dart';
import '../../presentation/pages/vehicles/vehicles_page.dart';
import '../../presentation/pages/vehicles/add_vehicle_page.dart';
import '../../presentation/pages/fuel_records/fuel_records_page.dart';
import '../../presentation/pages/fuel_records/add_fuel_record_simple_page.dart';
import '../../presentation/pages/analytics/analytics_page.dart';
import '../../presentation/widgets/main_layout.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String vehicles = '/vehicles';
  static const String addVehicle = '/add-vehicle';
  static const String fuelRecords = '/fuel-records';
  static const String addFuelRecord = '/add-fuel-record';
  static const String analytics = '/analytics';

  static final GoRouter router = GoRouter(
    initialLocation: dashboard,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: dashboard,
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: DashboardPage(),
              );
            },
          ),
          GoRoute(
            path: vehicles,
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: VehiclesPage(),
              );
            },
          ),
          GoRoute(
            path: fuelRecords,
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: FuelRecordsPage(),
              );
            },
          ),
          GoRoute(
            path: analytics,
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: AnalyticsPage(),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: addVehicle,
        pageBuilder: (context, state) {
          return MaterialPage(
            child: AddVehiclePage(),
          );
        },
      ),
      GoRoute(
        path: addFuelRecord,
        pageBuilder: (context, state) {
          final vehicleId = state.uri.queryParameters['vehicleId'];
          return MaterialPage(
            child: AddFuelRecordSimplePage(preselectedVehicleId: vehicleId),
          );
        },
      ),
    ],
  );
}