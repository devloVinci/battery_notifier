
# Project Story

A friend asked me to create a simple app to protect his weak battery. The app alerts him when charging goes above 90% (to unplug) or when it drops below 30% without charging (to plug in). It sends a clear notification with sound, helping extend battery life through better charging habits.

# just telling
First of all, I admire that the app is low in perfomance that is because I just make it for my friend.
 
I wanted to add projects in my portforlio and I found this app, I encountered a big issues with flutter_fluent_ui and I tried to fix them with co-pilot, I am just being honest here but I build this app before using co-pilot.


# Battery Notifier

Battery Notifier is a Flutter application that reminds you to charge or unplug your device based on configurable battery thresholds.

Purpose:
- Notify the user to charge when the battery falls below a configured minimum and the device is not charging.
- Notify the user to unplug when the battery rises above a configured maximum and the device is still plugged in.

Platforms:
- Windows (desktop)

This repository provides a user-facing UI for configuring thresholds, background monitoring logic, and platform integrations to issue native notifications where supported.

## Features

- Configurable low/high battery thresholds.
- Native notifications on supported platforms (Windows toasts, Android notifications).
- Lightweight UI to view current battery level and settings.
- Persistent preferences across app restarts.

## Quick Start

Prerequisites:

- Flutter SDK (stable). Installation: https://flutter.dev/docs/get-started/install
- For Windows desktop builds: Visual Studio 2019/2022 with "Desktop development with C++" workload.

Clone and fetch dependencies:

```powershell
git clone <your-repo-url>
cd hinzai_battery_notifier
flutter pub get
```

Run on Windows (desktop):

```powershell
flutter run -d windows
```


Build release artifacts:

```powershell
flutter build windows --release
```
```

Notes:
- If you encounter Windows build issues, confirm Visual Studio and C++ toolchain are installed and `flutter doctor` reports no desktop-related problems.
- Some third-party packages may require specific Flutter SDK versions. If a package is incompatible, either choose a compatible version or vendor and patch the package locally.

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

## Troubleshooting

- Run `flutter doctor -v` and fix platform-specific issues first.
- If `fluent_ui` or other UI packages produce API errors, try switching to a package version compatible with your Flutter SDK or vendor and patch the package under `vendor/`.
- For Windows-specific build failures ensure Visual Studio components are installed and up-to-date.

## Contributing

- Open an issue for bugs and feature requests.
- Create small, focused pull requests and include platform testing notes.

Suggested workflow:

```powershell
git checkout -b feat/your-feature
# implement changes
flutter pub get
flutter test
git add .
git commit -m "feat: short description"
git push origin feat/your-feature
```

## Project name and branding

The repository currently uses the internal path `hinzai_battery_notifier`. If you want to rebrand the product, I'll update product strings and platform resource files (Windows `Runner.rc`, `CMakeLists.txt`, and other runner resources).

## License

If you don't have a preferred license, MIT is a permissive option. Add a `LICENSE` file before publishing to GitHub.

---

If you'd like, I can also:

- Add repository badges (build status, license, pub.dev).
- Replace product strings and remove the `hinzai` name across platform files.
- Add sample screenshots to the README.

Tell me which of the above you'd like me to do next.
