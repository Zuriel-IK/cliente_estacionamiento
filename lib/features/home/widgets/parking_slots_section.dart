import 'package:cliente_estacionamiento/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../../models/dashboard_model.dart';

class FloorGridSection extends StatelessWidget {
  final List<ParkingSlot> slots;

  const FloorGridSection({super.key, required this.slots});

  bool _isAvailable(ParkingSlot slot) =>
      slot.state.toLowerCase() == 'disponible' ||
          slot.state.toLowerCase() == 'available';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    const occupiedColor = AppColors.blushRose;
    const occupiedSoftColor = AppColors.blushRose;
    const availableColor = AppColors.darkRaspberry;
    const availableSoftColor = AppColors.jetBlack;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.whiteRose,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.blushRose.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkRaspberry.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Planta 1',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
              const Row(
                children: [
                  _LegendDot(
                    color: occupiedColor,
                    softColor: occupiedSoftColor,
                    label: 'Ocupado',
                  ),
                  SizedBox(width: 10),
                  _LegendDot(
                    color: availableColor,
                    softColor: availableSoftColor,
                    label: 'Disponible',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: slots.map((slot) {
              return ParkingSlotTile(
                slot: slot,
                available: _isAvailable(slot),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class ParkingSlotTile extends StatelessWidget {
  final ParkingSlot slot;
  final bool available;

  const ParkingSlotTile({
    super.key,
    required this.slot,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withValues(alpha: 0.28),
          builder: (_) => ParkingSlotInfoDialog(
            slot: slot,
            available: available,
          ),
        );
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: available ? AppColors.jetBlack : AppColors.blushRose,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class ParkingSlotInfoDialog extends StatelessWidget {
  final ParkingSlot slot;
  final bool available;

  const ParkingSlotInfoDialog({
    super.key,
    required this.slot,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = available ? AppColors.jetBlack : AppColors.blushRose;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 180,
            height: 180,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: cardColor.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  slot.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    slot.state.toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.surface,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tipo: Estandar',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final Color softColor;
  final String label;

  const _LegendDot({
    required this.color,
    required this.softColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: softColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.62),
          ),
        ),
      ],
    );
  }
}