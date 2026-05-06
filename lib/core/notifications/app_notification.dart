import 'app_notification_type.dart';

class AppNotification {
  final String title;
  final String message;
  final AppNotificationType type;
  final Duration duration;

  const AppNotification({
    required this.title,
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 3),
  });

  factory AppNotification.success({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    return AppNotification(
      title: title,
      message: message,
      type: AppNotificationType.success,
      duration: duration,
    );
  }

  factory AppNotification.error({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    return AppNotification(
      title: title,
      message: message,
      type: AppNotificationType.error,
      duration: duration,
    );
  }

  factory AppNotification.warning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    return AppNotification(
      title: title,
      message: message,
      type: AppNotificationType.warning,
      duration: duration,
    );
  }

  factory AppNotification.info({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    return AppNotification(
      title: title,
      message: message,
      type: AppNotificationType.info,
      duration: duration,
    );
  }
}