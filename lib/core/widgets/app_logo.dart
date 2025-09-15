import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showBackground;

  const AppLogo({
    Key? key,
    this.size = 120,
    this.showBackground = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showBackground
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(size * 0.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            )
          : null,
      child: CustomPaint(
        painter: FuelAppLogoPainter(
          primaryColor: showBackground ? AppColors.white : AppColors.primary,
          accentColor: showBackground ? AppColors.white.withValues(alpha: 0.8) : AppColors.accent,
        ),
      ),
    );
  }
}

class FuelAppLogoPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  FuelAppLogoPainter({
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Desenhar bomba de combustível
    _drawFuelPump(canvas, size, paint);

    // Desenhar gráfico de economia
    _drawEconomyChart(canvas, size, paint);

    // Desenhar gotas de combustível
    _drawFuelDrops(canvas, size, paint);
  }

  void _drawFuelPump(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.55;

    // Base da bomba
    paint.color = primaryColor;
    final pumpRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: size.width * 0.25,
        height: size.height * 0.35,
      ),
      Radius.circular(8),
    );
    canvas.drawRRect(pumpRect, paint);

    // Bico da bomba
    final nozzlePath = Path()
      ..moveTo(centerX + size.width * 0.125, centerY - size.height * 0.1)
      ..lineTo(centerX + size.width * 0.25, centerY - size.height * 0.08)
      ..lineTo(centerX + size.width * 0.25, centerY - size.height * 0.05)
      ..lineTo(centerX + size.width * 0.125, centerY - size.height * 0.03)
      ..close();
    canvas.drawPath(nozzlePath, paint);

    // Display da bomba
    paint.color = accentColor;
    final displayRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY - size.height * 0.08),
        width: size.width * 0.15,
        height: size.height * 0.08,
      ),
      Radius.circular(4),
    );
    canvas.drawRRect(displayRect, paint);
  }

  void _drawEconomyChart(Canvas canvas, Size size, Paint paint) {
    paint.color = primaryColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;

    final chartPath = Path();
    final startX = size.width * 0.15;
    final startY = size.height * 0.3;
    final endX = size.width * 0.45;
    final endY = size.height * 0.15;

    // Linha do gráfico ascendente (economia melhorando)
    chartPath.moveTo(startX, startY);
    chartPath.quadraticBezierTo(
      startX + (endX - startX) * 0.3,
      startY,
      startX + (endX - startX) * 0.5,
      startY - (startY - endY) * 0.3,
    );
    chartPath.quadraticBezierTo(
      startX + (endX - startX) * 0.7,
      endY,
      endX,
      endY,
    );

    canvas.drawPath(chartPath, paint);

    // Pontos do gráfico
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(startX, startY), 3, paint);
    canvas.drawCircle(Offset(endX, endY), 3, paint);
  }

  void _drawFuelDrops(Canvas canvas, Size size, Paint paint) {
    paint.color = accentColor;
    paint.style = PaintingStyle.fill;

    // Gota 1
    _drawDrop(canvas, Offset(size.width * 0.75, size.height * 0.25), size.width * 0.06, paint);

    // Gota 2 (menor)
    _drawDrop(canvas, Offset(size.width * 0.8, size.height * 0.35), size.width * 0.04, paint);

    // Gota 3 (menor ainda)
    _drawDrop(canvas, Offset(size.width * 0.85, size.height * 0.45), size.width * 0.03, paint);
  }

  void _drawDrop(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();

    // Criar formato de gota
    path.addOval(Rect.fromCenter(center: center, width: radius * 2, height: radius * 2));

    // Adicionar "pico" da gota
    final tipPath = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(
        center.dx - radius * 0.3,
        center.dy - radius * 1.3,
        center.dx,
        center.dy - radius * 1.5,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.3,
        center.dy - radius * 1.3,
        center.dx,
        center.dy - radius,
      );

    path.addPath(tipPath, Offset.zero);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Widget para usar como ícone pequeno
class AppIcon extends StatelessWidget {
  final double size;

  const AppIcon({Key? key, this.size = 24}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppLogo(
      size: size,
      showBackground: false,
    );
  }
}

// Widget para splash screen
class AppSplashLogo extends StatelessWidget {
  const AppSplashLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(size: 120),
        SizedBox(height: 24),
        Text(
          'Combustível',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          'Controle seus gastos',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}