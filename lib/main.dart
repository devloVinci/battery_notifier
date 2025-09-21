import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:hinzai_battery_notifier/controller/notification_controller.dart';
import 'package:hinzai_battery_notifier/controller/preferences_service.dart';
import 'package:hinzai_battery_notifier/enums/notify_activity.dart';
import 'package:hinzai_battery_notifier/enums/notify_type.dart';
import 'package:hinzai_battery_notifier/model/notifications.dart';
import 'package:hinzai_battery_notifier/model/sentence.dart';
import 'package:hinzai_battery_notifier/screen/battery_setting.dart';
import 'package:hinzai_battery_notifier/screen/battery_show_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      themeMode: ThemeMode.dark,
      theme: FluentThemeData(
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
      title: 'Battery Notifier',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Battery _battery = Battery();
  final NotificationController _notificationController =
      NotificationController();
  int _batteryLevel = 100; // Default battery level
  BatteryState _batteryState = BatteryState.unknown;
  late StreamSubscription<BatteryState> _batteryStateSubscription;
  late Timer _batteryLevelTimer;
  int durationInSeconds = 30;
  final NotificationSettingsManager _settingsManager =
      NotificationSettingsManager();

  @override
  void initState() {
    super.initState();
    _initializeBatteryState();
    _initializeBatteryLevel();
    _notificationController.initialize();
    _startBatteryLevelTimer();
  }

  @override
  void dispose() {
    _batteryStateSubscription.cancel();
    _batteryLevelTimer.cancel();
    super.dispose();
  }

  void _initializeBatteryState() {
    _batteryStateSubscription =
        _battery.onBatteryStateChanged.listen((BatteryState state) {
      setState(() {
        _batteryState = state;
      });
    });
  }

  void _initializeBatteryLevel() async {
    final int level = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = level;
    });
    _sendBatteryNotifications(_batteryLevel);
  }

  void _startBatteryLevelTimer() {
    _batteryLevelTimer = Timer.periodic(Duration(seconds: durationInSeconds),
        (Timer timer) async {
      final int level = await _battery.batteryLevel;
      setState(() {
        _batteryLevel = level;
      });
      _sendBatteryNotifications(_batteryLevel);
    });
  }

  Future<void> _sendBatteryNotifications(int batteryLevel) async {
    List<BatteryNotification> notifications =
        await _settingsManager.getNotifications();

    for (int i = 0; i < notifications.length; i++) {
      BatteryNotification notification = notifications[i];

      // Check conditions for sending notification
      bool shouldSendNotification =
          _shouldSendNotification(notification, batteryLevel);

      if (shouldSendNotification) {
        bool notificationSent =
            await _sendNotification(notification, batteryLevel, i);

        if (notificationSent) {
          return; // Return if notification is sent to avoid sending multiple notifications
        }
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
      // Check if enough time has passed since the last notification
      if (!isFiveMinutesOrMore(notification.lastTime, DateTime.now())) {
        return false;
      }

      // Check battery level threshold based on onPlug condition
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
      title = Sentences.titleOfNotifiction;
      content = "${Sentences.conentOfNotifiction} $batteryLevel%";
    } else {
      title = Sentences.titleOffPlug;
      content = "${Sentences.contentOffPlug} $batteryLevel%";
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
    setState(() {});
  }

  int _currentPage = 0;
  final double iconSize = 30;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: Row(
          children: [
            const Text(
              "Battery Notifier",
              style: TextStyle(fontSize: 20),
            ),
            Image.asset("assets/images/animated_icon.gif")
          ],
        ),
      ),
      pane: NavigationPane(
        size: const NavigationPaneSize(openMinWidth: 100, openMaxWidth: 200),
        items: [
          PaneItem(
            icon: Image.asset(
              "assets/images/battery_app_down.gif",
              height: 30,
              width: 30,
            ),
            title: const Text("Battery"),
            body: const BatteryScreen(),
          ),
          PaneItem(
            icon: Image.asset(
              "assets/images/animated_noty.gif",
              height: 30,
              width: 30,
            ),
            title: const Text("Notifications"),
            body: const Scaffold(
              body: NotificationSettings(),
            ),
          ),
        ],
        selected: _currentPage,
        onChanged: (index) => setState(() => _currentPage = index),
      ),
    );
  }
}
