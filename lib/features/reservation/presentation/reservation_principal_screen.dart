import 'package:cliente_estacionamiento/core/notifications/app_notifier.dart';
import 'package:cliente_estacionamiento/core/theme/app_theme.dart';
import 'package:cliente_estacionamiento/features/models/reservation_model.dart';
import 'package:cliente_estacionamiento/features/reservation/providers/reservation_provider.dart';
import 'package:cliente_estacionamiento/features/reservation/screens/create_reservation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cliente_estacionamiento/features/reservation/screens/reservation_code_screen.dart';

class ReservationPrincipalScreen extends ConsumerStatefulWidget {
  final bool isActive;

  const ReservationPrincipalScreen({
    super.key,
    required this.isActive,
  });

  @override
  ConsumerState<ReservationPrincipalScreen> createState() =>
      _ReservationPrincipalScreenState();
}

class _ReservationPrincipalScreenState
    extends ConsumerState<ReservationPrincipalScreen>
    with WidgetsBindingObserver {
  ProviderSubscription<AsyncValue<List<ReservationModel>>>? _sseSub;
  String? _deletingReservationId;
  final Set<String> _expandedReservationIds = {};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.isActive) {
      _startSseListener();
    }
  }

  @override
  void didUpdateWidget(covariant ReservationPrincipalScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _startSseListener();
      ref.read(reservationListProvider.notifier).refreshReservations();
    }

    if (!widget.isActive && oldWidget.isActive) {
      _stopSseListener();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopSseListener();
    super.dispose();
  }

  void _startSseListener() {
    if (_sseSub != null) return;

    _sseSub = ref.listenManual<AsyncValue<List<ReservationModel>>>(
      reservationUpdatesProvider,
          (previous, next) {
        next.whenData((data) {
          ref.read(reservationListProvider.notifier).applyUpdate(data);
        });
      },
    );
  }

  void _stopSseListener() {
    _sseSub?.close();
    _sseSub = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startSseListener();
      ref.read(reservationListProvider.notifier).refreshReservations();
    }

    if (state == AppLifecycleState.paused) {
      _sseSub?.close();
      _sseSub = null;
    }
  }
  void _toggleReservationExpanded(String reservationId) {
    setState(() {
      if (_expandedReservationIds.contains(reservationId)) {
        _expandedReservationIds.remove(reservationId);
      } else {
        _expandedReservationIds.add(reservationId);
      }
    });
  }
  Future<void> _deleteReservation(String reservationId) async {
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.whiteRose,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: AppColors.blushRose.withValues(alpha: 0.14),
            ),
          ),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.dangerSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Eliminar reserva',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.jetBlack,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            '¿Seguro que deseas eliminar esta reserva?',
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppColors.jetBlack,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.darkRaspberry,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: colorScheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _deletingReservationId = reservationId;
    });

    try {
      await ref.read(deleteReservationActionProvider.notifier).deleteReservation(
        reservationId: reservationId,
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletingReservationId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservationsAsync = ref.watch(reservationListProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomListPadding = bottomInset + 20;
    ref.listen<AsyncValue<void>>(
      deleteReservationActionProvider,
          (previous, next) {
        if (previous?.isLoading == true && next.hasValue) {
          AppNotifier.success(
            title: 'Éxito',
            message: 'Reserva eliminada correctamente',
          );
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
        titleSpacing: 20,
        title: const Text(
          'Reservas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.blushRose,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blushRose.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Nueva reserva',
                color: Colors.white,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateReservationScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        onRefresh: () => ref
            .read(reservationListProvider.notifier)
            .refreshReservations(),
        child: reservationsAsync.when(
          skipLoadingOnRefresh: true,
          skipError: true,
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottomListPadding),
            children: const [
              SizedBox(height: 90),
              _CenteredStateCard(
                icon: Icons.calendar_month_rounded,
                iconColor: AppColors.blushRose,
                iconBackground: AppColors.rose150,
                title: 'Cargando reservas',
                message: 'Estamos preparando la información más reciente.',
                child: Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.blushRose,
                    ),
                  ),
                ),
              ),
            ],
          ),
          error: (error, stackTrace) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottomListPadding),
            children: [
              const SizedBox(height: 90),
              _CenteredStateCard(
                icon: Icons.error_outline_rounded,
                iconColor: AppColors.darkRaspberry,
                iconBackground: AppColors.dangerSoft,
                title: 'No se pudieron cargar las reservas',
                message: 'Error al cargar reservas: $error',
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(reservationListProvider.notifier)
                          .refreshReservations();
                    },
                    child: const Text('Reintentar'),
                  ),
                ),
              ),
            ],
          ),
          data: (reservations) {
            if (reservations.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 20, 20, bottomListPadding),
                children: [
                  const SizedBox(height: 70),
                  _CenteredStateCard(
                    icon: Icons.event_busy_rounded,
                    iconColor: AppColors.darkRaspberry,
                    iconBackground: AppColors.rose150,
                    title: 'No hay reservas',
                    message:
                    'Cuando crees una nueva reserva, aparecerá listada aquí.',
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateReservationScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Nueva reserva'),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 14, 20, bottomListPadding),
              children: [
                const _ReservationTopHeader(),
                const SizedBox(height: 18),
                ...List.generate(
                  reservations.length,
                      (index) {
                    final reservation = reservations[index];
                    final isDeleting = _deletingReservationId == reservation.id;

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == reservations.length - 1 ? 0 : 14,
                      ),
                      child: _ReservationCard(
                        reservation: reservation,
                        displayIndex: index + 1,
                        isDeleting: isDeleting,
                        isExpanded: _expandedReservationIds.contains(reservation.id),
                        onToggleExpanded: () => _toggleReservationExpanded(reservation.id),
                        onDelete: isDeleting
                            ? null
                            : () => _deleteReservation(reservation.id),
                        onViewCode: reservation.code != null
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReservationCodeScreen(
                                reservationId: reservation.id,
                              ),
                            ),
                          );
                        }
                            : null,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReservationTopHeader extends StatelessWidget {
  const _ReservationTopHeader();

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
                  'Llega justo a tiempo con',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.carbonBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tus reservas',
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

class _ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final int displayIndex;
  final VoidCallback? onDelete;
  final bool isDeleting;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback? onViewCode;

  const _ReservationCard({
    required this.reservation,
    required this.displayIndex,
    required this.onDelete,
    required this.isDeleting,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onViewCode,
  });

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

  _ReservationStateStyle _stateStyle(String state) {
    switch (state.toLowerCase()) {
      case 'pendiente':
        return const _ReservationStateStyle(
          backgroundColor: AppColors.warningSoft,
          textColor: AppColors.warning,
          icon: Icons.schedule_rounded,
          label: 'Pendiente',
        );
      case 'activa':
        return const _ReservationStateStyle(
          backgroundColor: AppColors.rose150,
          textColor: AppColors.darkRaspberry,
          icon: Icons.radio_button_checked_rounded,
          label: 'Activa',
        );
      case 'completada':
        return const _ReservationStateStyle(
          backgroundColor: AppColors.successSoft,
          textColor: AppColors.successDark,
          icon: Icons.check_circle_rounded,
          label: 'Completada',
        );
      case 'cancelada':
        return const _ReservationStateStyle(
          backgroundColor: AppColors.dangerSoft,
          textColor: AppColors.danger,
          icon: Icons.cancel_rounded,
          label: 'Cancelada',
        );
      default:
        return const _ReservationStateStyle(
          backgroundColor: AppColors.neutralWarm,
          textColor: AppColors.jetBlack,
          icon: Icons.info_outline_rounded,
          label: 'Sin estado',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = _stateStyle(reservation.state.name);

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onToggleExpanded,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reserva ${displayIndex.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.jetBlack,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Información de estacionamiento y horario',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withValues(alpha: 0.60),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _StateChip(state: state),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: onToggleExpanded,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            splashFactory: NoSplash.splashFactory,
                            borderRadius: BorderRadius.circular(8),
                            child: Ink(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.darkRaspberry,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.blushRose.withValues(alpha: 0.12),
                                ),
                              ),
                              child: AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 220),
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.rose50,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 220),
              crossFadeState: isExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Column(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoPill(
                          icon: Icons.local_parking_rounded,
                          label: 'Lugar',
                          value: reservation.place,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoPill(
                          icon: Icons.directions_car_rounded,
                          label: 'Carro',
                          value: reservation.car,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _DateTimeBlock(
                          title: 'Inicio',
                          date: _formatDate(reservation.timeStart),
                          time: _formatTime(reservation.timeStart),
                          accentColor: AppColors.blushRose,
                          softColor: AppColors.rose100,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DateTimeBlock(
                          title: 'Fin',
                          date: _formatDate(reservation.timeEnd),
                          time: _formatTime(reservation.timeEnd),
                          accentColor: AppColors.darkRaspberry,
                          softColor: AppColors.rose150,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              secondChild: const SizedBox.shrink(),
            ),
            const SizedBox(height: 14),
            if (onViewCode != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onViewCode,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.darkRaspberry,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.password_rounded),
                    label: const Text('Ver código'),
                  )
              ),
            ],
            const SizedBox(height: 14),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isDeleting ? null : onDelete,
                borderRadius: BorderRadius.circular(10),
                child: Ink(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.darkRaspberry,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.16),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: isDeleting
                        ? const SizedBox(
                      key: ValueKey('loading'),
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.rose50,
                      ),
                    )
                        : Row(
                      key: const ValueKey('delete'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.rose50,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Eliminar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.rose50,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _DateTimeBlock extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final Color accentColor;
  final Color softColor;

  const _DateTimeBlock({
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
          Row(
            children: [
              Icon(
                Icons.access_time_filled_rounded,
                size: 16,
                color: accentColor,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
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

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.rose50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.blushRose.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.darkRaspberry,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.jetBlack.withValues(alpha: 0.58),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.jetBlack,
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

class _StateChip extends StatelessWidget {
  final _ReservationStateStyle state;

  const _StateChip({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: state.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: state.textColor.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            state.icon,
            size: 15,
            color: state.textColor,
          ),
          const SizedBox(width: 6),
          Text(
            state.label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: state.textColor,
              letterSpacing: 0.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredStateCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String message;
  final Widget? child;

  const _CenteredStateCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.message,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.jetBlack,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppColors.jetBlack.withValues(alpha: 0.70),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _ReservationStateStyle {
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final String label;

  const _ReservationStateStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.label,
  });
}