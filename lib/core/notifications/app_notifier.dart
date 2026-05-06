import 'dart:async';
import 'package:flutter/material.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import 'app_notification.dart';
import 'app_notification_type.dart';

class AppNotifier {
  AppNotifier._();

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  static GlobalKey<NavigatorState> get navigatorKey => rootNavigatorKey;

  static OverlayEntry? _currentOverlay;
  static _TopNotificationEntryState? _currentNotificationState;
  static Timer? _timer;
  static bool _isDismissing = false;

  static void show(AppNotification notification) {
    final overlayState = navigatorKey.currentState?.overlay;
    final context = navigatorKey.currentContext;

    if (overlayState == null || context == null) return;

    _dismissCurrent(immediate: true);

    final top = MediaQuery.of(context).padding.top + 14;

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _TopNotificationEntry(
        top: top,
        notification: notification,
        onMounted: (state) {
          _currentNotificationState = state;
        },
        onDismissed: () {
          if (_currentOverlay == entry) {
            entry.remove();
            _currentOverlay = null;
            _currentNotificationState = null;
            _isDismissing = false;
          }
        },
      ),
    );

    _currentOverlay = entry;
    overlayState.insert(entry);

    _timer?.cancel();
    _timer = Timer(notification.duration, () {
      _dismissCurrent();
    });
  }

  static void _dismissCurrent({bool immediate = false}) {
    _timer?.cancel();
    _timer = null;

    if (_currentOverlay == null) return;

    if (immediate) {
      _currentOverlay?.remove();
      _currentOverlay = null;
      _currentNotificationState = null;
      _isDismissing = false;
      return;
    }

    if (_isDismissing) return;
    _isDismissing = true;
    _currentNotificationState?.dismiss();
  }

  static void success({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(AppNotification.success(
      title: title,
      message: message,
      duration: duration,
    ));
  }

  static void error({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(AppNotification.error(
      title: title,
      message: message,
      duration: duration,
    ));
  }

  static void warning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(AppNotification.warning(
      title: title,
      message: message,
      duration: duration,
    ));
  }

  static void info({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(AppNotification.info(
      title: title,
      message: message,
      duration: duration,
    ));
  }
}

class _TopNotificationEntry extends StatefulWidget {
  final double top;
  final AppNotification notification;
  final ValueChanged<_TopNotificationEntryState> onMounted;
  final VoidCallback onDismissed;

  const _TopNotificationEntry({
    required this.top,
    required this.notification,
    required this.onMounted,
    required this.onDismissed,
  });

  @override
  State<_TopNotificationEntry> createState() => _TopNotificationEntryState();
}

class _TopNotificationEntryState extends State<_TopNotificationEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  bool _didNotifyDismiss = false;

  @override
  void initState() {
    super.initState();

    widget.onMounted(this);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 220),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && !_didNotifyDismiss) {
        _didNotifyDismiss = true;
        widget.onDismissed();
      }
    });
  }

  Future<void> dismiss() async {
    if (!mounted) return;
    if (_controller.status == AnimationStatus.reverse ||
        _controller.status == AnimationStatus.dismissed) {
      return;
    }
    await _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: GestureDetector(
              onTap: dismiss,
              onHorizontalDragEnd: (_) => dismiss(),
              child: _NotificationCard(notification: widget.notification),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = _NotificationStyle.fromType(notification.type);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: style.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkRaspberry.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: style.softColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              style.icon,
              color: style.iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: colorScheme.onSurface.withValues(alpha: 0.35),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: colorScheme.onSurface.withValues(alpha: 0.68),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationStyle {
  final IconData icon;
  final Color iconColor;
  final Color softColor;
  final Color borderColor;

  const _NotificationStyle({
    required this.icon,
    required this.iconColor,
    required this.softColor,
    required this.borderColor,
  });

  factory _NotificationStyle.fromType(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.success:
        return const _NotificationStyle(
          icon: Icons.check_rounded,
          iconColor: AppColors.success,
          softColor: AppColors.successSoft,
          borderColor: Color(0xFFCFECDD),
        );
      case AppNotificationType.error:
        return const _NotificationStyle(
          icon: Icons.close_rounded,
          iconColor: AppColors.danger,
          softColor: AppColors.dangerSoft,
          borderColor: Color(0xFFF1CAD7),
        );
      case AppNotificationType.warning:
        return const _NotificationStyle(
          icon: Icons.priority_high_rounded,
          iconColor: AppColors.warning,
          softColor: AppColors.warningSoft,
          borderColor: Color(0xFFF6E3BA),
        );
      case AppNotificationType.info:
        return const _NotificationStyle(
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.blushRose,
          softColor: AppColors.rose100,
          borderColor: Color(0xFFF1D3DD),
        );
    }
  }
}