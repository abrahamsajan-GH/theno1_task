import 'package:flutter/material.dart';

import 'isometric_chart_painter.dart';

class IsometricBarChart extends StatelessWidget {
  const IsometricBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [BoxShadow(color: const Color(0x199E9E9E), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Purchase Breakup by Year',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 48),
          SizedBox(
            height: 300,
            width: double.infinity,
            child: CustomPaint(painter: IsometricChartPainter()),
          ),
        ],
      ),
    );
  }
}
