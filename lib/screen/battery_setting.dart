import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';
import 'package:hinzai_battery_notifier/controller/preferences_service.dart';
import 'package:hinzai_battery_notifier/enums/notify_activity.dart';
import 'package:hinzai_battery_notifier/model/notifications.dart';
import 'package:hinzai_battery_notifier/enums/notify_type.dart';
import 'package:hinzai_battery_notifier/widgets/DropDownBatteryNotify.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  final NotificationSettingsManager _settingsManager =
      NotificationSettingsManager();
  late Future<List<BatteryNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notificationsFuture = _settingsManager.getNotifications();
    });
  }

  void _addNotification(BatteryNotification notification) async {
    await _settingsManager.addNotification(notification);
    _loadNotifications();
  }

  void _removeNotification(int index) async {
    await _settingsManager.removeNotification(index);
    _loadNotifications();
  }

  void _updateNotification(
      BatteryNotification newNotification, int index) async {
    await _settingsManager.updateNotification(newNotification, index);
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const fl.Row(
          children: [
            Text('Notifications List'),
            Icon(Icons.notification_important)
          ],
        ),
      ),
      body: FutureBuilder<List<BatteryNotification>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading notifications'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications'));
          } else {
            final notifications = snapshot.data!;
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                  key: Key(notification.onLevel.toString() +
                      notification.type.toString()),
                  onDismissed: (direction) {
                    _removeNotification(index);
                  },
                  background: Container(color: Colors.red),
                  child: DropDownBatteryNotify(
                    batteryNotification: notification,
                    index: index,
                    onSave: (updatedNotification) {
                      print("old : ${notification.toJson()}");
                      print("new : ${updatedNotification.toJson()}");
                      _updateNotification(notification, index);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNotification(BatteryNotification(30, NotifyType.normal,
              active: NotifyActivity.oneTime));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
