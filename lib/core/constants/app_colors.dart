import 'package:flutter/material.dart';

/// AppColors - Sistema de cores centralizado do app
/// REGRA FUNDAMENTAL: NUNCA use Colors.blue ou Color(0xFF...) no código
/// SEMPRE use variáveis desta classe
class AppColors {
  AppColors._(); // Previne instanciação

  // Cores principais (tema combustível/economia) - iOS-like
  static const Color primary = Color(0xFF30D158); // Verde iOS moderno
  static const Color secondary = Color(0xFF007AFF); // Azul iOS
  static const Color accent = Color(0xFFFF9F0A); // Laranja iOS

  // Cores de sistema - iOS-like
  static const Color success = Color(0xFF30D158); // Verde iOS
  static const Color warning = Color(0xFFFF9F0A); // Laranja iOS
  static const Color error = Color(0xFFFF453A); // Vermelho iOS
  static const Color info = Color(0xFF007AFF); // Azul iOS

  // Cores específicas do app de combustível
  static const Color gasolina = Color(0xFFFF453A); // Vermelho iOS
  static const Color etanol = Color(0xFF30D158); // Verde iOS
  static const Color diesel = Color(0xFF8E8E93); // Cinza iOS
  static const Color gnv = Color(0xFF007AFF); // Azul iOS

  // Cores de economia/performance
  static const Color economyGood = Color(0xFF30D158); // Verde iOS
  static const Color economyBad = Color(0xFFFF453A); // Vermelho iOS
  static const Color economyNeutral = Color(0xFF8E8E93); // Cinza iOS

  // Cores neutras - Light Theme
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFAFAFA);
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color iconLight = Color(0xFF616161);

  // Cores neutras - Dark Theme
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2C2C2C);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  static const Color dividerDark = Color(0xFF373737);
  static const Color iconDark = Color(0xFFB3B3B3);

  // Cores para gráficos
  static const Color chart1 = Color(0xFF1976D2);
  static const Color chart2 = Color(0xFF388E3C);
  static const Color chart3 = Color(0xFFF57C00);
  static const Color chart4 = Color(0xFFD32F2F);
  static const Color chart5 = Color(0xFF7B1FA2);

  // Cores para status de manutenção
  static const Color maintenanceOverdue = Color(0xFFFF453A); // Vermelho iOS
  static const Color maintenanceDueSoon = Color(0xFFFF9F0A); // Laranja iOS
  static const Color maintenanceGood = Color(0xFF30D158); // Verde iOS

  // Cores para eficiência
  static const Color efficiencyExcellent = Color(0xFF30D158); // Verde iOS
  static const Color efficiencyGood = Color(0xFF32D74B); // Verde iOS claro
  static const Color efficiencyAverage = Color(0xFFFF9F0A); // Laranja iOS
  static const Color efficiencyPoor = Color(0xFFFF6B35); // Laranja-vermelho iOS
  static const Color efficiencyBad = Color(0xFFFF453A); // Vermelho iOS

  // Método helper para obter cor do tipo de combustível
  static Color getFuelTypeColor(String fuelType) {
    switch (fuelType.toLowerCase()) {
      case 'gasolina':
        return gasolina;
      case 'etanol':
        return etanol;
      case 'diesel':
        return diesel;
      case 'gnv':
        return gnv;
      default:
        return primary;
    }
  }

  // Método helper para obter cor da economia baseada em porcentagem
  static Color getEconomyColor(double percentage) {
    if (percentage <= -10) return economyBad;
    if (percentage <= -5) return warning;
    if (percentage <= 5) return economyNeutral;
    if (percentage <= 10) return economyGood;
    return success;
  }

  // Método helper para obter cor da eficiência baseada no consumo
  static Color getEfficiencyColor(double consumption, double expected) {
    final efficiency = consumption / expected;
    if (efficiency >= 1.2) return efficiencyExcellent;
    if (efficiency >= 1.1) return efficiencyGood;
    if (efficiency >= 0.9) return efficiencyAverage;
    if (efficiency >= 0.8) return efficiencyPoor;
    return efficiencyBad;
  }

  // Lista de cores para gráficos diversos
  static const List<Color> chartColors = [
    chart1,
    chart2,
    chart3,
    chart4,
    chart5,
    primary,
    secondary,
    accent,
  ];

  // Aliases para compatibilidade
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Aliases para textos baseados no tema
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color textLight = textPrimaryDark;

  // Aliases para superfícies
  static const Color cardBackground = cardLight;
  static const Color divider = dividerLight;
}