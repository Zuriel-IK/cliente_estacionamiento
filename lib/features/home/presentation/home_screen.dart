import 'package:cliente_estacionamiento/core/theme/app_theme.dart';
import 'package:cliente_estacionamiento/features/home/widgets/quick_actions_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/dashboard_model.dart';
import '../providers/home_provider.dart';
import '../../auth/providers/session_provider.dart';
import '../widgets/dashboard_summary_section.dart';
import '../widgets/parking_slots_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  ProviderSubscription<AsyncValue<DashboardModel>>? _sseSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sseSub?.close();
    _sseSub = null;
    super.dispose();
  }

  void _startSseListener() {
    if (_sseSub != null) return;


    _sseSub = ref.listenManual<AsyncValue<DashboardModel>>(
      dashboardUpdatesProvider,
          (previous, next) {
        next.whenData((data) {
          ref.read(dashboardControllerProvider.notifier).applyUpdate(data);
        });
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startSseListener();
      ref.read(dashboardControllerProvider.notifier).refreshDashboard();
    }

    if (state == AppLifecycleState.paused) {
      _sseSub?.close();
      _sseSub = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardControllerProvider);
    final sessionState = ref.watch(sessionControllerProvider);
    final user = sessionState.valueOrNull?.user;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.whiteRose,
        body: SafeArea(
          child: dashboardAsync.when(
            skipLoadingOnRefresh: true,
            skipError: true,
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 42,
                        color: AppColors.darkRaspberry,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Error: $err',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(dashboardControllerProvider.notifier)
                            .refreshDashboard(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (dashboard) {
              final total = dashboard.summary.totalSlots;
              final occupied = dashboard.summary.occupiedSlots;
              final percentFull = total == 0 ? 0.0 : occupied / total;

              return RefreshIndicator(
                color: colorScheme.primary,
                backgroundColor: colorScheme.surface,
                onRefresh: () async {
                  await ref
                      .read(dashboardControllerProvider.notifier)
                      .refreshDashboard();
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    _Header(userName: user?.firstName),
                    const SizedBox(height: 20),
                    const _LiveStatusHeader(isLive: true),
                    const SizedBox(height: 14),
                    LiveStatusCard(
                      percentFull: percentFull,
                      totalSlots: total,
                      availableSlots: dashboard.summary.availableSlots,
                    ),
                    const SizedBox(height: 18),
                    const QuickActionsRow(),
                    const SizedBox(height: 26),
                    FloorGridSection(slots: dashboard.parkingSlots),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String? userName;

  const _Header({this.userName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = (userName == null || userName!.trim().isEmpty)
        ? 'Usuario'
        : userName!;

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola,',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.carbonBlack,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.blushRose,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blushRose.withValues(alpha: 0.26),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveStatusHeader extends StatelessWidget {
  final bool isLive;

  const _LiveStatusHeader({required this.isLive});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final chipColor = isLive ? AppColors.rose50 : AppColors.neutralSoft;
    final textColor = isLive
        ? AppColors.darkRaspberry
        : colorScheme.onSurface.withValues(alpha: 0.60);
    final dotColor = isLive
        ? AppColors.blushRose
        : colorScheme.onSurface.withValues(alpha: 0.35);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Estacionamiento',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isLive
                  ? AppColors.blushRose.withValues(alpha: 0.18)
                  : colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: isLive
                      ? [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.40),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                      : null,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                isLive ? 'CONECTADO' : 'OFFLINE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}