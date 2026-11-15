part of 'notification_bloc.dart';

abstract class NotificationState {}


// =========================================================
// INIT
// =========================================================

class InitNotificationState
    extends NotificationState {}


// =========================================================
// LOADING
// =========================================================

class LoadingNotificationState
    extends NotificationState {}


// =========================================================
// SUCCESS
// =========================================================

class SuccessNotificationState
    extends NotificationState {
  final List<NotificationModel> notifications;

  final List<NotificationModel> newNotifications;

  final int unreadCount;

  // للتحكم بحركة الجرس
  final bool isBellRinging;

  SuccessNotificationState({
    required this.notifications,

    this.newNotifications = const [],

    this.unreadCount = 0,

    this.isBellRinging = false,
  });
}


// =========================================================
// FAILED
// =========================================================

class FailedNotificationState
    extends NotificationState {
  final String errorMessage;

  FailedNotificationState({
    required this.errorMessage,
  });
}