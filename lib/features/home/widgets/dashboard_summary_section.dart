import 'package:cliente_estacionamiento/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LiveStatusCard extends StatelessWidget {
  final double percentFull;
  final int totalSlots;
  final int availableSlots;

  const LiveStatusCard({
    super.key,
    required this.percentFull,
    required this.totalSlots,
    required this.availableSlots,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (percentFull * 100).round();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whiteRose,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.blushRose.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkRaspberry.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: _CircularPercent(percentage: percentage),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Espacios Totales',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.58),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalSlots',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Disponibles Ahora',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.58),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.rose100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '$availableSlots disponibles',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.jetBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularPercent extends StatelessWidget {
  final int percentage;

  const _CircularPercent({required this.percentage});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final targetValue = (percentage.clamp(0, 100)) / 100.0;

    final status = _statusLabel(percentage);
    final accentColor = _accentColor(percentage);
    final softAccent = _softAccentColor(percentage);

    return Center(
      child: SizedBox.square(
        dimension: 112,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: targetValue),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: softAccent.withValues(alpha: 0.18),
                  ),
                ),
                SizedBox(
                  width: 92,
                  height: 92,
                  child: CircularProgressIndicator(
                    value: animatedValue,
                    strokeWidth: 7,
                    backgroundColor: softAccent.withValues(alpha: 0.30),
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(animatedValue * 100).round()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _statusLabel(int percentage) {
    if (percentage >= 85) return 'HIGH';
    if (percentage >= 40) return 'MEDIUM';
    return 'LOW';
  }

  static Color _accentColor(int percentage) {
    if (percentage >= 85) return AppColors.danger;
    if (percentage >= 60) return AppColors.warning;
    return AppColors.darkRaspberry;
  }

  static Color _softAccentColor(int percentage) {
    if (percentage >= 85) return AppColors.dangerSoft;
    if (percentage >= 60) return AppColors.warningSoft;
    return AppColors.rose150;
  }
}