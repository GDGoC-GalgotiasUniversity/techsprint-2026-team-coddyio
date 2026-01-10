import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MiniChart
    extends
        StatelessWidget {
  final List<
    double
  >
  values;
  final Color
  color;
  final String
  title;
  final IconData
  icon;

  const MiniChart({
    super.key,
    required this.values,
    required this.color,
    required this.title,
    required this.icon,
  });

  @override
  Widget
  build(
    BuildContext context,
  ) {
    if (values.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          16,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(
              alpha: 0.15,
            ),
            blurRadius: 8,
            offset: const Offset(
              0,
              2,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(
                  6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                '${values.last.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          SizedBox(
            height: 60,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(
                  show: false,
                ),
                titlesData: const FlTitlesData(
                  show: false,
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX:
                    (values.length -
                            1)
                        .toDouble(),
                minY: _getMinY(
                  values,
                ),
                maxY: _getMaxY(
                  values,
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: values
                        .asMap()
                        .entries
                        .map(
                          (
                            e,
                          ) => FlSpot(
                            e.key.toDouble(),
                            e.value,
                          ),
                        )
                        .toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter:
                          (
                            spot,
                            percent,
                            barData,
                            index,
                          ) {
                            return FlDotCirclePainter(
                              radius:
                                  index ==
                                      values.length -
                                          1
                                  ? 4
                                  : 2,
                              color: color,
                              strokeWidth: 0,
                            );
                          },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(
                        alpha: 0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double
  _getMinY(
    List<
      double
    >
    values,
  ) {
    final min = values.reduce(
      (
        a,
        b,
      ) =>
          a <
              b
          ? a
          : b,
    );
    return (min -
            (min *
                0.1))
        .floorToDouble();
  }

  double
  _getMaxY(
    List<
      double
    >
    values,
  ) {
    final max = values.reduce(
      (
        a,
        b,
      ) =>
          a >
              b
          ? a
          : b,
    );
    return (max +
            (max *
                0.1))
        .ceilToDouble();
  }
}
