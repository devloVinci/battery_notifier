import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:hinzai_battery_notifier/enums/notify_activity.dart';
import 'package:hinzai_battery_notifier/enums/notify_type.dart';
import 'package:hinzai_battery_notifier/model/notifications.dart';
import 'package:hinzai_battery_notifier/widgets/battery_custom.dart';

class DropDownBatteryNotify extends StatefulWidget {
  const DropDownBatteryNotify({
    super.key,
    required this.batteryNotification,
    required this.onSave,
    required this.index,
  });

  final BatteryNotification batteryNotification;
  final Function(BatteryNotification) onSave;
  final int index;

  @override
  State<DropDownBatteryNotify> createState() => _DropDownBatteryNotifyState();
}

class _DropDownBatteryNotifyState extends State<DropDownBatteryNotify> {
  NotifyType? _selectedItem;
  late BatteryNotification _notification;
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    _notification = widget.batteryNotification;
    print(_notification.lastTime.toString());
    _controller = TextEditingController(
        text: widget.batteryNotification.onLevel.toString());
    _selectedItem = _notification.type;
    super.initState();
  }

  void _validateInput(String input) {
    setState(() {
      final value = int.tryParse(input);
      if (value == null) {
        _errorText = 'null';
      } else if (value < 0 || value > 100) {
        _errorText = '0-100';
      } else {
        _errorText = null;
        _notification.onLevel = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // const Spacer(),
              _batteryLevelWidget(),
              const Spacer(),
              _notificationTypeDropDown(),
              const Spacer(),
              _plugStateWidget(),
              const Spacer(),
              _active(),
              const Spacer(),
              _save(),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 20),
          if (_notification.lastTime != null) ...[
            Text(
              'Last Notification Time: ${_notification.lastTime!.toString().split(".")[0]}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
          const Divider(),
        ],
      ),
    );
  }

  Widget _batteryLevelWidget() {
    return Row(
      children: [
        Column(
          children: [
            CustomPaint(
                size: const Size(25, 50),
                painter: BatteryLevelPainter(
                    batteryLevel: _notification.onLevel,
                    batteryState: BatteryState.discharging,
                    color: Colors.black)),
            const Text("Battery Level")
          ],
        ),
        const SizedBox(
          width: 20,
        ),
        SizedBox(
          width: 70,
          child: SizedBox(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter',
                errorText: _errorText,
              ),
              onChanged: _validateInput,
            ),
          ),
        ),
      ],
    );
  }

  Widget _notificationTypeDropDown() {
    return Row(
      children: [
        const Column(
          children: [
            Icon(
              Icons.notifications_active,
              size: 50,
            ),
            Text(
              "Notification type",
            )
          ],
        ),
        SizedBox(
          width: 100,
          child: DropdownButton<NotifyType>(
            items: List.generate(
              NotifyType.values.length,
              (index) => DropdownMenuItem<NotifyType>(
                value: NotifyType.values[index],
                child: Text(
                  NotifyType.values[index].toString().split(".")[1],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            value: _selectedItem,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.transparent),
            onChanged: (NotifyType? newValue) {
              setState(() {
                _selectedItem = newValue;
                _notification.type = _selectedItem!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _active() {
    Widget buildIcon() {
      if (_notification.active == NotifyActivity.always) {
        return const Icon(
          Icons.notifications_on_rounded,
          size: 40,
          color: Colors.green,
        );
      } else if (_notification.active == NotifyActivity.notActive) {
        return const Icon(
          Icons.notifications_off_rounded,
          size: 40,
          color: Colors.red,
        );
      } else {
        return const Icon(
          Icons.notifications_active_sharp,
          size: 40,
          color: Colors.yellow,
        );
      }
    }

    Widget buildText() {
      switch (_notification.active) {
        case NotifyActivity.always:
          return const Text(
            "Always",
            style: TextStyle(color: Colors.green),
          );
        case NotifyActivity.oneTime:
          return const Text(
            "One time",
            style: TextStyle(color: Colors.yellow),
          );
        case NotifyActivity.notActive:
          return const Text(
            "Not Active",
            style: TextStyle(color: Colors.red),
          );
      }
    }

    return InkWell(
      onTap: () {
        List<NotifyActivity> activity = NotifyActivity.values;
        int findIndex = activity.indexOf(_notification.active);
        if (findIndex == activity.length - 1) {
          setState(() {
            _notification.active = NotifyActivity.values.first;
          });
        } else {
          setState(() {
            _notification.active = NotifyActivity.values[findIndex + 1];
          });
        }
      },
      child: Row(
        children: [
          Column(
            children: [buildIcon(), buildText()],
          ),
        ],
      ),
    );
  }

  Widget _plugStateWidget() {
    double size = 40;
    return InkWell(
      onTap: () {
        setState(() {
          _notification.onPlug = !_notification.onPlug;
        });
      },
      child: IconButton(
        onPressed: null,
        icon: Image.asset(
          _notification.onPlug
              ? "assets/images/plugin.png"
              : "assets/images/plugoff.png",
          width: size,
          height: size,
        ),
      ),
    );
  }

  Widget _save() {
    return IconButton(
      onPressed: () {
        widget.onSave(_notification);
      },
      icon: const Icon(
        Icons.save,
        size: 35,
      ),
    );
  }
}
