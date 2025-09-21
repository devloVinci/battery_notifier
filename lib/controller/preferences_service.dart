import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:hinzai_battery_notifier/model/notifications.dart';

class NotificationSettingsManager {
  static const String _notificationsKey = 'battery_notifications2';

  Future<List<BatteryNotification>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_notificationsKey);
    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => BatteryNotification.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<void> saveNotifications(
      List<BatteryNotification> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationsKey, jsonEncode(notifications));
  }

  Future<void> addNotification(BatteryNotification notification) async {
    List<BatteryNotification> notifications = await getNotifications();
    notifications.add(notification);
    await saveNotifications(notifications);
  }

  Future<void> removeNotification(int index) async {
    List<BatteryNotification> notifications = await getNotifications();
    notifications.removeAt(index);
    await saveNotifications(notifications);
  }

  Future<void> updateNotification(
      BatteryNotification newNotification, int index) async {
    final notifications = await getNotifications();
    if (index < 0 || index >= notifications.length) return;
    notifications[index] = newNotification;
    await saveNotifications(notifications);
  }
}
