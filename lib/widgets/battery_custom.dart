import 'package:battery_plus/battery_plus.dart';
import 'package:fluent_ui/fluent_ui.dart';

class BatteryLevelPainter extends CustomPainter {
  final int batteryLevel;
  final BatteryState batteryState;
  final Color color;

  BatteryLevelPainter({
    required this.batteryLevel,
    required this.batteryState,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint getPaint(
        {Color color = Colors.black,
        PaintingStyle style = PaintingStyle.stroke}) {
      return Paint()
        ..color = color
        ..strokeWidth = 1.0
        ..style = style;
    }

    final RRect batteryOutline = RRect.fromLTRBR(
        0.0, 3.0, size.width, size.height - 3, const Radius.circular(2.0));

    // Battery body
    canvas.drawRRect(
      batteryOutline,
      getPaint(color: color),
    );

    // canvas.translate(0.0, (size.height - size.height * (batteryLevel / 100)));

    // Battery nub
    canvas.drawRRect(
      RRect.fromLTRBR(size.width / 2 - 1, 0, size.width / 2 + 3, 3.0,
          const Radius.circular(2.0)),
      getPaint(style: PaintingStyle.fill, color: color),
    );

    Color indicatorColor;

    if (batteryState == BatteryState.charging) {
      indicatorColor = Colors.blue;
    } else if (batteryLevel < 25) {
      indicatorColor = Colors.red;
    } else if (batteryLevel < 40) {
      indicatorColor = Colors.orange;
    } else {
      indicatorColor = Colors.green;
    }

    canvas.drawRRect(
      RRect.fromLTRBR(0.5, (1 - (batteryLevel / 100)) * (size.height - 3.5),
          size.width - 0.5, size.height - 3.5, const Radius.circular(2.0)),
      getPaint(style: PaintingStyle.fill, color: indicatorColor),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final BatteryLevelPainter old = oldDelegate as BatteryLevelPainter;

    return old.batteryLevel != batteryLevel || old.batteryState != batteryState;
  }
}
