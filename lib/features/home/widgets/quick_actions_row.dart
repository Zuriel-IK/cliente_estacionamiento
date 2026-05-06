import 'package:cliente_estacionamiento/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            title: 'Realizar Reserva',
            subtitle: 'Solo toma 2 minutos',
            icon: Icons.flash_on_rounded,
            isPrimary: true,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            title: 'Ingresar codigo',
            subtitle: 'Para check-in',
            icon: Icons.pin,
            isPrimary: false,
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final backgroundColor =
    isPrimary ? AppColors.blushRose : AppColors.whiteRose;

    final borderColor = isPrimary
        ? AppColors.blushRose.withValues(alpha: 0.18)
        : AppColors.blushRose.withValues(alpha: 0.10);

    final titleColor = isPrimary ? Colors.white : colorScheme.onSurface;

    final subtitleColor = isPrimary
        ? Colors.white.withValues(alpha: 0.80)
        : colorScheme.onSurface.withValues(alpha: 0.60);

    final iconBg = isPrimary
        ? Colors.white.withValues(alpha: 0.16)
        : AppColors.rose150;

    final iconColor = isPrimary
        ? Colors.white
        : AppColors.darkRaspberry;

    final badgeColor = isPrimary
        ? Colors.white.withValues(alpha: 0.14)
        : AppColors.rose150;

    final badgeTextColor = isPrimary
        ? Colors.white
        : AppColors.darkRaspberry;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? AppColors.blushRose.withValues(alpha: 0.18)
                : AppColors.darkRaspberry.withValues(alpha: 0.05),
            blurRadius: isPrimary ? 18 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  isPrimary ? 'RAPIDO' : 'CAPTURAR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: titleColor,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}