import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RealtimeClock extends StatefulWidget {
  /// show seconds (true => update every second; false => minute aligned)
  final bool showSeconds;
  final TextStyle? timeStyle;
  final TextStyle? dateStyle;

  const RealtimeClock({
    Key? key,
    this.showSeconds = false,
    this.timeStyle,
    this.dateStyle,
  }) : super(key: key);

  @override
  State<RealtimeClock> createState() => _RealtimeClockState();
}

class _RealtimeClockState extends State<RealtimeClock> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();

    if (widget.showSeconds) {
      // simple: tick every second
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    } else {
      // align to next minute boundary, then run periodic every minute
      final now = DateTime.now();
      final int seconds = now.second;
      final int millis = now.millisecond;
      final int msUntilNextMinute = ((60 - seconds) * 1000) - millis;

      // first timer: one-shot to reach the next minute boundary
      _timer = Timer(Duration(milliseconds: msUntilNextMinute), () {
        _tick(); // update right at the minute
        // then schedule periodic every minute
        _timer = Timer.periodic(const Duration(minutes: 1), (_) => _tick());
      });
    }
  }

  void _tick() {
    if (mounted) {
      setState(() {
        _now = DateTime.now();
      });
    }
  }

  @override
  void didUpdateWidget(covariant RealtimeClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if showSeconds changed, restart timer with new mode
    if (oldWidget.showSeconds != widget.showSeconds) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // time format
    final timeFormat = widget.showSeconds ? DateFormat('hh:mm:ss a') : DateFormat('hh:mm a');
    final dateFormat = DateFormat('EEEE, d MMMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          timeFormat.format(_now),
          style: widget.timeStyle ?? const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF0066FF)),
        ),
        const SizedBox(height: 4),
        Text(
          dateFormat.format(_now),
          style: widget.dateStyle ?? const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
