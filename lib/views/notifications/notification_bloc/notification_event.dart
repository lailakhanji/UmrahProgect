part of 'notification_bloc.dart';

abstract class NotificationEvent {}


// =========================================================
// GET NOTIFICATIONS
// =========================================================

class GetNotificationsEvent
    extends NotificationEvent {}


// =========================================================
// START POLLING
// =========================================================

class StartNotificationPollingEvent
    extends NotificationEvent {}


// =========================================================
// CHECK NEW NOTIFICATIONS
// =========================================================

class CheckNewNotificationsEvent
    extends NotificationEvent {}


// =========================================================
// CLEAR BADGE
// =========================================================

class ClearNotificationBadgeEvent
    extends NotificationEvent {}


// =========================================================
// STOP BELL
// =========================================================

class StopBellRingingEvent
    extends NotificationEvent {}