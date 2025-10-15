import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hinzai_battery_notifier/controller/notification_controller.dart';
import 'package:hinzai_battery_notifier/controller/preferences_service.dart';
import 'package:hinzai_battery_notifier/enums/notify_activity.dart';
import 'package:hinzai_battery_notifier/enums/notify_type.dart';
import 'package:hinzai_battery_notifier/model/notifications.dart';

class BatteryStateNotifier extends ChangeNotifier {
  final Battery _battery = Battery();
  final NotificationController _notificationController =
      NotificationController();
  final NotificationSettingsManager _settingsManager =
      NotificationSettingsManager();

  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.unknown;
  Timer? _batteryLevelTimer;
  late StreamSubscription<BatteryState> _batteryStateSubscription;

  int get batteryLevel => _batteryLevel;
  BatteryState get batteryState => _batteryState;

  BatteryStateNotifier() {
    _initializeBatteryState();
    _initializeBatteryLevel();
    _notificationController.initialize();
    _startBatteryLevelTimer();
  }

  void _initializeBatteryState() {
    _batteryStateSubscription =
        _battery.onBatteryStateChanged.listen((BatteryState state) {
      _batteryState = state;
      notifyListeners();
    });
  }

  void _initializeBatteryLevel() async {
    _batteryLevel = await _battery.batteryLevel;
    notifyListeners();
    _sendBatteryNotifications(_batteryLevel);
  }

  void _startBatteryLevelTimer() {
    _batteryLevelTimer = Timer.periodic(
      const Duration(seconds: 30),
      (Timer timer) async {
        final int level = await _battery.batteryLevel;
        if (_batteryLevel != level) {
          _batteryLevel = level;
          notifyListeners();
          _sendBatteryNotifications(_batteryLevel);
        }
      },
    );
  }

  Future<void> _sendBatteryNotifications(int batteryLevel) async {
    final notifications = await _settingsManager.getNotifications();

    for (int i = 0; i < notifications.length; i++) {
      final notification = notifications[i];
      if (_shouldSendNotification(notification, batteryLevel)) {
        final notificationSent =
            await _sendNotification(notification, batteryLevel, i);
        if (notificationSent) break;
      }
    }
  }

  bool _shouldSendNotification(
      BatteryNotification notification, int batteryLevel) {
    if (notification.active == NotifyActivity.always ||
        (notification.active == NotifyActivity.oneTime &&
            notification.lastTime == null)) {
      if (_batteryState == BatteryState.charging &&
          notification.onPlug == false) {
        return false;
      }
      if (_batteryState == BatteryState.discharging && notification.onPlug) {
        return false;
      }

      if (!isFiveMinutesOrMore(notification.lastTime, DateTime.now())) {
        return false;
      }

      if (notification.onPlug) {
        return batteryLevel >= notification.onLevel &&
            batteryLevel <= notification.onLevel + 20;
      } else {
        return batteryLevel <= notification.onLevel &&
            batteryLevel >= notification.onLevel - 20;
      }
    }
    return false;
  }

  bool isFiveMinutesOrMore(DateTime? dateTime1, DateTime dateTime2) {
    if (dateTime1 == null) {
      return true;
    }
    Duration difference = dateTime2.difference(dateTime1);
    return difference.inMinutes >= 2;
  }

  Future<bool> _sendNotification(
      BatteryNotification notification, int batteryLevel, int index) async {
    String title, content;

    if (notification.onPlug) {
      title = "Battery Charging";
      content = "Battery level is $batteryLevel%";
    } else {
      title = "Battery Discharging";
      content = "Battery level is $batteryLevel%";
    }

    if (notification.type == NotifyType.alarm) {
      _notificationController.showAlarm(title, content);
    } else if (notification.type == NotifyType.normal) {
      _notificationController.sendTimedNotification(title, content, 10);
    }

    await _afterNotify(index, notification);
    return true;
  }

  Future<void> _afterNotify(int index, BatteryNotification notification) async {
    if (notification.active == NotifyActivity.oneTime) {
      notification.active = NotifyActivity.notActive;
    }
    notification.lastTime = DateTime.now();
    await _settingsManager.updateNotification(notification, index);
    notifyListeners();
  }

  @override
  void dispose() {
    _batteryStateSubscription.cancel();
    _batteryLevelTimer?.cancel();
    super.dispose();
  }
}
