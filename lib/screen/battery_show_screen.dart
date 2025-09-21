import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:hinzai_battery_notifier/controller/notification_controller.dart';
import 'package:hinzai_battery_notifier/widgets/battery_custom.dart';

class BatteryScreen extends StatefulWidget {
  const BatteryScreen({super.key});

  @override
  _BatteryScreenState createState() => _BatteryScreenState();
}

class _BatteryScreenState extends State<BatteryScreen> {
  final Battery _battery = Battery();
  final NotificationController _notificationController =
      NotificationController();

  int _batteryLevel = 100; // Default battery level
  BatteryState _batteryState = BatteryState.unknown;
  String _batteryDescription = "Unknown";
  Color _stateTextColor = Colors.white;
  late Timer _batteryLevelTimer;
  late StreamSubscription<BatteryState> _batteryStateSubscription;

  @override
  void initState() {
    super.initState();
    _firstChecking();
    _notificationController.initialize();
    _checkBatteryState();
    _checkBatteryLevelPeriodically();
  }

  @override
  void dispose() {
    _batteryStateSubscription.cancel(); // Cancel the battery state subscription
    _batteryLevelTimer.cancel(); // Cancel the battery level timer
    super.dispose();
  }

  void _checkBatteryLevelPeriodically() {
    _batteryLevelTimer =
        Timer.periodic(const Duration(seconds: 30), (Timer timer) {
      _checkBatteryLevel();
    });
  }

  Future<void> _checkBatteryState() async {
    _batteryStateSubscription =
        _battery.onBatteryStateChanged.listen((BatteryState state) {
      setState(() {
        _batteryState = state;
        _batteryDescription = _getBatteryStateString(state);
        _stateTextColor = _getBatteryStatecolor(state);
      });
      print('Battery State: $state');
    });
  }

  Future<void> _firstChecking() async {
    final int level = await _battery.batteryLevel;
    final BatteryState state = await _battery.batteryState;
    setState(() {
      _batteryState = state;
      _batteryLevel = level;
      _batteryDescription = _getBatteryStateString(state);
      _stateTextColor = _getBatteryStatecolor(state);
    });
  }

  Future<void> _checkBatteryLevel() async {
    final int level = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = level;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battery State'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 100 * 1.5,
              height: 200 * 1.5,
              child: Stack(
                children: [
                  Center(
                    child: CustomPaint(
                        size: const Size(100 * 1.5, 200 * 1.5),
                        painter: BatteryLevelPainter(
                            batteryLevel: _batteryLevel,
                            batteryState: _batteryState,
                            color: Colors.white)),
                  ),
                  if (_batteryState == BatteryState.charging)
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/images/thunder.png",
                        width: 70,
                        height: 70,
                      ),
                    ),
                  if (_batteryState != BatteryState.charging &&
                      _batteryLevel <= 30)
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/images/wrong.png",
                        width: 70,
                        height: 70,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              'Battery level: $_batteryLevel%',
              style: const TextStyle(fontSize: 50),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'State: ',
                  style: TextStyle(fontSize: 30),
                ),
                Text(
                  _batteryDescription,
                  style: TextStyle(fontSize: 30, color: _stateTextColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getBatteryStateString(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        return "Charging";
      case BatteryState.discharging:
        return "Discharging";
      case BatteryState.full:
        return "Full";
      case BatteryState.unknown:
      default:
        return "Unknown";
    }
  }

  Color _getBatteryStatecolor(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        return Colors.blue;
      case BatteryState.discharging:
        return Colors.yellow;
      case BatteryState.full:
        return Colors.green;
      case BatteryState.unknown:
      default:
        return Colors.white;
    }
  }
}
