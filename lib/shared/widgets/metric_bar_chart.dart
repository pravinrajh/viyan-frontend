import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// One bar of a [MetricBarChart].
class BarDatum {
  const BarDatum({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;
}

/// A labeled vertical bar chart built on `fl_chart`'s [BarChart], used for
/// small side-by-side metric comparisons (e.g. balance vs. requirement).
class MetricBarChart extends StatelessWidget {
  const MetricBarChart({
    super.key,
    required this.bars,
    required this.valueFormatter,
    this.height = 200,
  });

  final List<BarDatum> bars;
  final String Function(double value) valueFormatter;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maxValue = bars.fold<double>(
      0,
      (max, b) => b.value > max ? b.value : max,
    );
    final ceiling = maxValue <= 0 ? 1.0 : maxValue * 1.28;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: ceiling,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: ceiling / 4,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppTheme.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= bars.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      bars[index].label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.mutedText,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppTheme.navy,
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                    valueFormatter(rod.toY),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
            ),
          ),
          barGroups: [
            for (final entry in bars.asMap().entries)
              BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.value,
                    color: entry.value.color,
                    width: 34,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: ceiling,
                      color: AppTheme.border.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
          ],
        ),
        duration: const Duration(milliseconds: 220),
      ),
    );
  }
}
