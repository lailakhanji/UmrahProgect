import 'dart:async';

import 'package:bloc/bloc.dart';

import '../data/notification_api_service.dart';
import '../data/notification_model.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc
    extends Bloc<NotificationEvent, NotificationState> {
  final NotificationApiService notificationApiService;

  Timer? _timer;

  // آخر إشعارات موجودة
  List<NotificationModel> _oldNotifications = [];

  // الإشعارات المقروءة محلياً
  final Set<String> _locallyReadIds = {};

  int _unreadCount = 0;

  NotificationBloc(this.notificationApiService)
      : super(InitNotificationState()) {
    on<GetNotificationsEvent>(_getNotifications);
    on<StartNotificationPollingEvent>(_startPolling);
    on<CheckNewNotificationsEvent>(_checkNewNotifications);
    on<ClearNotificationBadgeEvent>(_clearNotificationBadge);
  }

  // =========================================================
  // GET NOTIFICATIONS - أول تحميل
  // =========================================================

  Future<void> _getNotifications(
      GetNotificationsEvent event,
      Emitter<NotificationState> emit,
      ) async {
    emit(LoadingNotificationState());

    final result =
    await notificationApiService.getUserNotifications();

    result.fold(
          (error) {
        emit(
          FailedNotificationState(
            errorMessage: error,
          ),
        );
      },
          (notifications) {
        _oldNotifications =
        List<NotificationModel>.from(notifications);

        _unreadCount =
            _calculateUnreadCount(notifications);

        emit(
          SuccessNotificationState(
            notifications: notifications,
            newNotifications: const [],
            unreadCount: _unreadCount,

            // مهم جداً
            // أول تحميل لا يجعل الجرس يتحرك
            isBellRinging: false,
          ),
        );
      },
    );
  }

  // =========================================================
  // START POLLING
  // =========================================================

  void _startPolling(
      StartNotificationPollingEvent event,
      Emitter<NotificationState> emit,
      ) {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 30),
          (_) {
        if (!isClosed) {
          add(CheckNewNotificationsEvent());
        }
      },
    );
  }

  // =========================================================
  // CHECK NEW NOTIFICATIONS
  // =========================================================

  Future<void> _checkNewNotifications(
      CheckNewNotificationsEvent event,
      Emitter<NotificationState> emit,
      ) async {
    final result =
    await notificationApiService.getUserNotifications();

    result.fold(
          (error) {
        print('NOTIFICATION POLLING ERROR: $error');
      },
          (notifications) {
        // =============================================
        // IDs القديمة
        // =============================================

        final oldIds =
        _oldNotifications.map((e) => e.id).toSet();

        // =============================================
        // الإشعارات الجديدة فقط
        // =============================================

        final newNotifications = notifications
            .where(
              (notification) =>
          !oldIds.contains(notification.id),
        )
            .toList();

        // =============================================
        // حساب عدد غير المقروء
        // =============================================

        _unreadCount =
            _calculateUnreadCount(notifications);

        // =============================================
        // تحديث القائمة القديمة
        // =============================================

        _oldNotifications =
        List<NotificationModel>.from(notifications);

        // =============================================
        // هل يوجد إشعار جديد؟
        // =============================================

        final bool hasNewNotification =
            newNotifications.isNotEmpty;

        print('================================');
        print('NOTIFICATION POLLING');
        print('NEW COUNT: ${newNotifications.length}');
        print('UNREAD COUNT: $_unreadCount');
        print(
          'BELL RINGING: $hasNewNotification',
        );
        print('================================');

        // =============================================
        // إرسال الحالة
        // =============================================

        emit(
          SuccessNotificationState(
            notifications: notifications,
            newNotifications: newNotifications,
            unreadCount: _unreadCount,

            // يتحرك فقط عند وصول إشعار جديد
            isBellRinging: hasNewNotification,
          ),
        );
      },
    );
  }

  // =========================================================
  // CALCULATE UNREAD
  // =========================================================

  int _calculateUnreadCount(
      List<NotificationModel> notifications,
      ) {
    return notifications.where(
          (notification) {
        if (notification.isRead) {
          return false;
        }

        if (_locallyReadIds.contains(
          notification.id,
        )) {
          return false;
        }

        return true;
      },
    ).length;
  }

  // =========================================================
  // CLEAR BADGE
  // =========================================================

  Future<void> _clearNotificationBadge(
      ClearNotificationBadgeEvent event,
      Emitter<NotificationState> emit,
      ) async {
    if (state is! SuccessNotificationState) {
      return;
    }

    final currentState =
    state as SuccessNotificationState;

    final notifications =
        currentState.notifications;

    // =============================================
    // الإشعارات غير المقروءة
    // =============================================

    final unreadNotifications =
    notifications.where(
          (notification) {
        return !notification.isRead &&
            !_locallyReadIds.contains(
              notification.id,
            );
      },
    ).toList();

    // =============================================
    // حفظها كمقروءة محلياً
    // =============================================

    for (final notification
    in unreadNotifications) {
      _locallyReadIds.add(
        notification.id,
      );
    }

    _unreadCount = 0;

    // =============================================
    // تحديث القائمة محلياً
    // =============================================

    final updatedNotifications =
    notifications.map(
          (notification) {
        if (_locallyReadIds.contains(
          notification.id,
        )) {
          return NotificationModel(
            id: notification.id,
            message: notification.message,
            isRead: true,
            createdAt: notification.createdAt,
          );
        }

        return notification;
      },
    ).toList();

    _oldNotifications =
    List<NotificationModel>.from(
      updatedNotifications,
    );

    // =============================================
    // تحديث الواجهة فوراً
    // =============================================

    emit(
      SuccessNotificationState(
        notifications: updatedNotifications,
        newNotifications: const [],
        unreadCount: 0,

        // لا تحريك للجرس
        isBellRinging: false,
      ),
    );

    // =============================================
    // تحديث السيرفر
    // =============================================

    for (final notification
    in unreadNotifications) {
      final result =
      await notificationApiService.markAsRead(
        notification.id,
      );

      result.fold(
            (error) {
          print(
            'MARK AS READ ERROR: $error',
          );
        },
            (_) {
          print(
            'MARKED AS READ: ${notification.id}',
          );
        },
      );
    }
  }

  // =========================================================
  // CLOSE
  // =========================================================

  @override
  Future<void> close() {
    _timer?.cancel();

    return super.close();
  }
}