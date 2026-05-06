import 'dart:math' as math;
import 'package:flutter/material.dart';

class AppCircleLoading extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;
  final String? text;

  const AppCircleLoading({
    super.key,
    this.size = 42,
    this.strokeWidth = 4,
    this.color = const Color(0xFFEA638C),
    this.backgroundColor = const Color(0xFFFFDCE7),
    this.text,
  });

  @override
  State<AppCircleLoading> createState() => _AppCircleLoadingState();
}

class _AppCircleLoadingState extends State<AppCircleLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ringSize = widget.size;
    final stroke = widget.strokeWidth;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: child,
            );
          },
          child: SizedBox(
            width: ringSize,
            height: ringSize,
            child: CustomPaint(
              painter: _CircleLoadingPainter(
                color: widget.color,
                backgroundColor: widget.backgroundColor,
                strokeWidth: stroke,
              ),
            ),
          ),
        ),
        if (widget.text != null) ...[
          const SizedBox(height: 10),
          Text(
            widget.text!,
            style: TextStyle(
              color: widget.color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _CircleLoadingPainter extends CustomPainter {
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  const _CircleLoadingPainter({
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width / 2) - strokeWidth / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    const startAngle = -math.pi / 2;
    const sweepAngle = math.pi * 1.25;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleLoadingPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}