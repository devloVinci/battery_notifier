
# Project Story

A friend asked me to create a simple app to protect his weak battery. The app alerts him when charging goes above 90% (to unplug) or when it drops below 30% without charging (to plug in). It sends a clear notification with sound, helping extend battery life through better charging habits.

# Battery Notifier

Battery Notifier is a Flutter application that reminds you to charge or unplug your device based on configurable battery thresholds.

Purpose:
- Notify the user to charge when the battery falls below a configured minimum and the device is not charging.
- Notify the user to unplug when the battery rises above a configured maximum and the device is still plugged in.

Platforms:
- Windows (desktop)

## Features

- Configurable low/high battery thresholds.
- Native notifications on supported platforms (Windows toasts, Android notifications).
- Lightweight UI to view current battery level and settings.
- Persistent preferences across app restarts.

## Configuration

Settings are available in the app UI and persisted using platform-appropriate storage. Key options:

- Low threshold (percentage): notify to charge when battery <= this value and device is not charging.
- High threshold (percentage): notify to unplug when battery >= this value and device is charging.

Default examples:
- Low threshold: 20%
- High threshold: 90%

## How it works

1. The app monitors battery level and charging state via platform plugins.
2. When a threshold condition is met (e.g. battery below low threshold while not charging), the app sends a local notification.
3. Notifications use native mechanisms where available (Windows toasts).
