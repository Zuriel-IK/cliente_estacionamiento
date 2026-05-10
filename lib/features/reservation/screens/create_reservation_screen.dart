import 'package:cliente_estacionamiento/core/notifications/app_notifier.dart';
import 'package:cliente_estacionamiento/core/theme/app_theme.dart';
import 'package:cliente_estacionamiento/features/home/providers/home_provider.dart';
import 'package:cliente_estacionamiento/features/models/dashboard_model.dart';
import 'package:cliente_estacionamiento/features/reservation/providers/reservation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateReservationScreen extends ConsumerStatefulWidget {
  const CreateReservationScreen({super.key});

  @override
  ConsumerState<CreateReservationScreen> createState() =>
      _CreateReservationScreenState();
}

class _CreateReservationScreenState
    extends ConsumerState<CreateReservationScreen>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();

  String? _selectedPlaceId;
  int? _selectedTime;
  bool _isSaving = false;

  ProviderSubscription<AsyncValue<DashboardModel>>? _dashboardSseSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startDashboardSseListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopDashboardSseListener();
    super.dispose();
  }

  void _startDashboardSseListener() {
    if (_dashboardSseSub != null) return;

    _dashboardSseSub = ref.listenManual<AsyncValue<DashboardModel>>(
      dashboardUpdatesProvider,
          (previous, next) {
        next.whenData((data) {
          ref.read(dashboardControllerProvider.notifier).applyUpdate(data);

          final stillExists = data.parkingSlots.any(
                (slot) =>
            slot.id == _selectedPlaceId &&
                slot.state.toLowerCase() == 'disponible',
          );

          if (!stillExists && mounted) {
            setState(() {
              _selectedPlaceId = null;
            });
          }
        });
      },
    );
  }

  void _stopDashboardSseListener() {
    _dashboardSseSub?.close();
    _dashboardSseSub = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startDashboardSseListener();
      ref.read(dashboardControllerProvider.notifier).refreshDashboard();
    }

    if (state == AppLifecycleState.paused) {
      _stopDashboardSseListener();
    }
  }

  Future<void> _submit() async {
    if (_selectedPlaceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona un espacio'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona un tiempo'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(createReservationActionProvider.notifier).createReservation(
        placeId: _selectedPlaceId!,
        time: _selectedTime!,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    final day = local.day.toString().padLeft(2, '0');
    final month = months[local.month - 1];
    final year = local.year.toString();

    return '$day $month $year';
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '$hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardControllerProvider);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    ref.listen<AsyncValue<void>>(
      createReservationActionProvider,
          (previous, next) {
        if (previous?.isLoading == true && next.hasValue) {
          AppNotifier.success(
            title: 'Éxito',
            message: 'Reserva creada correctamente',
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
            }
          });
        }

        if (previous?.isLoading == true && next.hasError) {
          AppNotifier.error(
            title: 'Error',
            message: next.error.toString(),
          );
        }
      },
    );
    return Scaffold(
      backgroundColor: AppColors.whiteRose,
      appBar: AppBar(
        backgroundColor: AppColors.whiteRose,
        foregroundColor: AppColors.jetBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Nueva reserva',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: dashboardAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.blushRose,
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.whiteRose,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.blushRose.withValues(alpha: 0.16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkRaspberry.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                'Error al cargar espacios: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.jetBlack,
                ),
              ),
            ),
          ),
        ),
        data: (dashboard) {
          final allSlots = dashboard.parkingSlots;
          final availableSlots = allSlots
              .where((slot) => slot.state.toLowerCase() == 'disponible')
              .toList();

          if (_selectedPlaceId != null &&
              !availableSlots.any((slot) => slot.id == _selectedPlaceId)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.of(context).pop();
              setState(() {
                _selectedPlaceId = null;
              });
            });
          }

          final now = DateTime.now();
          final end = _selectedTime == null
              ? null
              : now.add(Duration(minutes: _selectedTime!));

          if (availableSlots.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 28),
              children: [
                const SizedBox(height: 70),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.whiteRose,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.blushRose.withValues(alpha: 0.14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkRaspberry.withValues(alpha: 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.local_parking_rounded,
                        size: 34,
                        color: AppColors.darkRaspberry,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No hay espacios disponibles para reservar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.jetBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 28),
              children: [
                const _CreateReservationHeader(),
                const SizedBox(height: 22),
                const _SectionHeader(
                  title: 'Selecciona un lugar',
                  subtitle: 'Los espacios libres muestran su número o nombre.',
                ),
                const SizedBox(height: 14),
                _ParkingPlaceGrid(
                  slots: allSlots,
                  selectedPlaceId: _selectedPlaceId,
                  onSelect: (placeId) {
                    setState(() {
                      _selectedPlaceId = placeId;
                    });
                  },
                ),
                if (_selectedPlaceId == null) ...[
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: Text(
                      'Selecciona un espacio',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: 'Tiempo de reserva',
                  subtitle: 'Elige cuánto tiempo deseas reservar.',
                ),
                const SizedBox(height: 14),
                _TimeSelector(
                  selectedTime: _selectedTime,
                  onChanged: (value) {
                    setState(() {
                      _selectedTime = value;
                    });
                  },
                ),
                if (_selectedTime == null) ...[
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: Text(
                      'Selecciona un tiempo',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (_selectedTime != null)
                  _ReservationPreviewCard(
                    startDate: _formatDate(now),
                    startTime: _formatTime(now),
                    endDate: _formatDate(end!),
                    endTime: _formatTime(end),
                    selectedSlotName: allSlots
                        .firstWhere((slot) => slot.id == _selectedPlaceId,
                        orElse: () => availableSlots.first)
                        .name,
                  ),
                if (_selectedTime != null) const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.blushRose,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: Text(
                      _isSaving ? 'Guardando...' : 'Crear reserva',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CreateReservationHeader extends StatelessWidget {
  const _CreateReservationHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.rose400,
            AppColors.rose200,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.blushRose,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkRaspberry.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.blushRose,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blushRose.withValues(alpha: 0.24),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reserva rápida',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.carbonBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Elige lugar y duración',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.2,
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.jetBlack,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.jetBlack.withValues(alpha: 0.62),
          ),
        ),
      ],
    );
  }
}

class _ParkingPlaceGrid extends StatelessWidget {
  final List<dynamic> slots;
  final String? selectedPlaceId;
  final ValueChanged<String> onSelect;

  const _ParkingPlaceGrid({
    required this.slots,
    required this.selectedPlaceId,
    required this.onSelect,
  });

  bool _isAvailable(dynamic slot) {
    return slot.state.toLowerCase() == 'disponible';
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: slots.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isAvailable = _isAvailable(slot);
        final isSelected = selectedPlaceId == slot.id;

        return _ParkingPlaceTile(
          label: slot.name,
          isAvailable: isAvailable,
          isSelected: isSelected,
          onTap: isAvailable ? () => onSelect(slot.id) : null,
        );
      },
    );
  }
}

class _ParkingPlaceTile extends StatelessWidget {
  final String label;
  final bool isAvailable;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ParkingPlaceTile({
    required this.label,
    required this.isAvailable,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? AppColors.rose100
        : isAvailable
        ? AppColors.rose50
        : AppColors.neutralWarm;

    final borderColor = isSelected
        ? AppColors.blushRose
        : isAvailable
        ? AppColors.blushRose.withValues(alpha: 0.42)
        : AppColors.neutralWarm;

    final textColor = isSelected
        ? AppColors.darkRaspberry
        : isAvailable
        ? AppColors.jetBlack.withValues(alpha: 0.72)
        : AppColors.jetBlack.withValues(alpha: 0.34);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.4 : 1,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppColors.blushRose.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ]
                : null,
          ),
          child: Stack(
            children: [
              if (isAvailable && !isSelected)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DashedBorderPainter(
                      color: AppColors.blushRose.withValues(alpha: 0.28),
                      radius: 18,
                    ),
                  ),
                ),
              Center(
                child: isAvailable
                    ? Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSelected ? 15 : 14,
                    fontWeight:
                    isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
                )
                    : const Icon(
                  Icons.directions_car_rounded,
                  size: 22,
                  color: AppColors.jetBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final int? selectedTime;
  final ValueChanged<int> onChanged;

  const _TimeSelector({
    required this.selectedTime,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const options = [1, 15, 30];

    return Row(
      children: options.map((minutes) {
        final isSelected = selectedTime == minutes;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: minutes == options.last ? 0 : 10,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onChanged(minutes),
                borderRadius: BorderRadius.circular(18),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.rose100
                        : AppColors.whiteRose,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.blushRose
                          : AppColors.blushRose.withValues(alpha: 0.14),
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: AppColors.blushRose.withValues(alpha: 0.16),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: isSelected
                            ? AppColors.darkRaspberry
                            : AppColors.jetBlack.withValues(alpha: 0.55),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        minutes == 1 ? '1 min' : '$minutes min',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? AppColors.darkRaspberry
                              : AppColors.jetBlack.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ReservationPreviewCard extends StatelessWidget {
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final String selectedSlotName;

  const _ReservationPreviewCard({
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.selectedSlotName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.whiteRose,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.blushRose.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkRaspberry.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de reserva',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.jetBlack,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Espacio seleccionado: $selectedSlotName',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.jetBlack.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PreviewTimeBlock(
                  title: 'Inicio',
                  date: startDate,
                  time: startTime,
                  accentColor: AppColors.blushRose,
                  softColor: AppColors.rose100,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PreviewTimeBlock(
                  title: 'Fin',
                  date: endDate,
                  time: endTime,
                  accentColor: AppColors.darkRaspberry,
                  softColor: AppColors.rose150,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewTimeBlock extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final Color accentColor;
  final Color softColor;

  const _PreviewTimeBlock({
    required this.title,
    required this.date,
    required this.time,
    required this.accentColor,
    required this.softColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.jetBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.jetBlack.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 5.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}