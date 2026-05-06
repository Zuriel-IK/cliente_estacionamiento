import 'package:cliente_estacionamiento/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final items = [
      _NavItemData(
        label: 'Inicio',
        icon: Icons.home_rounded,
        outlinedIcon: Icons.home_outlined,
      ),
      _NavItemData(
        label: 'Reservacion',
        icon: Icons.date_range_rounded,
        outlinedIcon: Icons.date_range_outlined ,
      ),
      _NavItemData(
        label: 'Ticket',
        icon: Icons.confirmation_number_rounded ,
        outlinedIcon: Icons.confirmation_number_outlined ,
      ),
      _NavItemData(
        label: 'Perfil',
        icon: Icons.person_rounded,
        outlinedIcon: Icons.person_outline_rounded,
      ),
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.blushRose.withValues(alpha: 0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkRaspberry.withValues(alpha: 0.15),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          spacing: 8,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = currentIndex == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? AppColors.darkRaspberry.withValues(alpha: 0.2)
                          : Colors.transparent,
                    ),
                    color: isSelected
                        ? AppColors.rose200
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        duration: const Duration(milliseconds: 220),
                        scale: isSelected ? 1.0 : 0.96,
                        child: Icon(
                          isSelected ? item.icon : item.outlinedIcon,
                          size: 22,
                          color: isSelected
                              ? AppColors.jetBlack
                              : colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.jetBlack.withValues(alpha: 0.65)
                              : colorScheme.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;
  final IconData outlinedIcon;

  const _NavItemData({
    required this.label,
    required this.icon,
    required this.outlinedIcon,
  });
}