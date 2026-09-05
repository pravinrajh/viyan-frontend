import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// One slice of a [DonutChart].
class DonutSegment {
  const DonutSegment({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;
}

/// A labeled donut chart with a legend, built on `fl_chart`'s [PieChart].
/// Segments with a zero total render an empty ring rather than a crash.
class DonutChart extends StatefulWidget {
  const DonutChart({
    super.key,
    required this.segments,
    this.centerLabel,
    this.size = 168,
  });

  final List<DonutSegment> segments;
  final String? centerLabel;
  final double size;

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final total = widget.segments.fold<double>(0, (sum, s) => sum + s.value);
    final visible = widget.segments.where((s) => s.value > 0).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: widget.size * 0.32,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (!event.isInterestedForInteractions ||
                          response?.touchedSection == null) {
                        setState(() => _touchedIndex = null);
                        return;
                      }
                      setState(() {
                        _touchedIndex =
                            response!.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sections: total <= 0
                      ? [
                          PieChartSectionData(
                            value: 1,
                            color: AppTheme.border,
                            showTitle: false,
                            radius: widget.size * 0.16,
                          ),
                        ]
                      : [
                          for (final entry in visible.asMap().entries)
                            PieChartSectionData(
                              value: entry.value.value,
                              color: entry.value.color,
                              showTitle: false,
                              radius: _touchedIndex == entry.key
                                  ? widget.size * 0.20
                                  : widget.size * 0.16,
                            ),
                        ],
                ),
                duration: const Duration(milliseconds: 220),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    total <= 0 ? '0' : total.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                    ),
                  ),
                  if (widget.centerLabel != null)
                    Text(
                      widget.centerLabel!,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.mutedText,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final segment in widget.segments)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: segment.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          segment.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.mutedText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        segment.value.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
