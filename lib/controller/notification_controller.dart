import 'package:windows_notification/windows_notification.dart';
import 'package:windows_notification/notification_message.dart';

class NotificationController {
  WindowsNotification? _winNotifyPlugin;

  /// Initialize the Windows notification plugin.
  ///
  /// Optionally pass an [applicationId] to identify the app. If omitted, a
  /// sensible default will be used (PowerShell app id is used for compatibility
  /// in the original project but you should replace it with your app id).
  void initialize({String? applicationId}) {
    _winNotifyPlugin = WindowsNotification(
      applicationId: applicationId ??
          r"{D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27}\WindowsPowerShell\v1.0\powershell.exe",
    );
  }

  bool get isInitialized => _winNotifyPlugin != null;

  void _ensureInitialized() {
    if (_winNotifyPlugin == null) {
      throw StateError(
          'NotificationController not initialized. Call initialize() first.');
    }
  }

  void sendWithPluginTemplate(String title, String content) {
    _ensureInitialized();
    final message = NotificationMessage.fromPluginTemplate(
      'plugin',
      title,
      content,
      payload: {'action': 'open_center'},
    );
    _winNotifyPlugin!.showNotificationPluginTemplate(message);
  }

  void sendCustomTemplate(String title, String content, {String? group}) {
    _ensureInitialized();
    final template = '''<?xml version="1.0" encoding="utf-8"?>
<toast launch='conversationId=9813' activationType="background">
  <visual>
    <binding template='ToastGeneric'>
      <text>$title</text>
      <text>$content</text>
    </binding>
  </visual>
  <actions>
    <action content='Archive' arguments='action:archive'/>
  </actions>
</toast>
''';

    final message =
        NotificationMessage.fromCustomTemplate('custom', group: group);
    _winNotifyPlugin!.showNotificationCustomTemplate(message, template);
  }

  void sendTimedNotification(
      String title, String content, int durationInSeconds) {
    _ensureInitialized();
    final template = '''<?xml version="1.0" encoding="utf-8"?>
<toast duration="${durationInSeconds > 5 ? 'long' : 'short'}">
  <visual>
    <binding template="ToastGeneric">
      <text>$title</text>
      <text>$content</text>
    </binding>
  </visual>
  <audio src="ms-winsoundevent:Notification.Default"/>
</toast>
''';

    final message =
        NotificationMessage.fromCustomTemplate('timed', group: 'timed');
    _winNotifyPlugin!.showNotificationCustomTemplate(message, template);
  }

  void showAlarm(String title, String content) {
    _ensureInitialized();
    final message =
        NotificationMessage.fromCustomTemplate('alarm', group: 'battery');
    final alarmTemplate =
        '''<toast launch="action=viewAlarm&amp;alarmId=3" scenario="alarm">
  <visual>
    <binding template="ToastGeneric">
      <text>$title</text>
      <text>$content</text>
    </binding>
  </visual>
  <actions>
    <action activationType="system" arguments="snooze" content=""/>
    <action activationType="background" arguments="dismiss" content="Dismiss"/>
  </actions>
  <audio src="ms-winsoundevent:Notification.Looping.Alarm" loop="true"/>
</toast>
''';

    _winNotifyPlugin!.showNotificationCustomTemplate(message, alarmTemplate);
  }
}
