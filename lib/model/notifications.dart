import 'package:hinzai_battery_notifier/enums/notify_activity.dart';
import 'package:hinzai_battery_notifier/enums/notify_type.dart';

class BatteryNotification {
  int onLevel;
  NotifyType type;
  NotifyActivity active;
  DateTime? lastTime;
  bool onPlug;

  BatteryNotification(this.onLevel, this.type,
      {this.active = NotifyActivity.oneTime,
      this.lastTime,
      this.onPlug = true});

  // Convert to JSON
  Map<String, dynamic> toJson() => {
        'onLevel': onLevel,
        'type': type.toString(),
        'active': active.toString(),
        'dateTime': lastTime?.toIso8601String(),
        'onPlug': onPlug,
      };

  // Convert from JSON
  factory BatteryNotification.fromJson(Map<String, dynamic> json) {
    return BatteryNotification(
      json['onLevel'],
      NotifyType.values.firstWhere((e) => e.toString() == json['type']),
      active: NotifyActivity.values
          .firstWhere((e) => e.toString() == json['active']),
      lastTime:
          json['dateTime'] != null ? DateTime.parse(json['dateTime']) : null,
      onPlug: json['onPlug'] ?? true,
    );
  }
}
