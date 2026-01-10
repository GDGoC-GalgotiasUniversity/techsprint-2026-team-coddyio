import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sensor_data.dart';
import '../services/api_service.dart';

class HistoryScreen
    extends
        StatefulWidget {
  const HistoryScreen({
    super.key,
  });

  @override
  State<
    HistoryScreen
  >
  createState() => _HistoryScreenState();
}

class _HistoryScreenState
    extends
        State<
          HistoryScreen
        > {
  final ApiService
  _apiService = ApiService();
  List<
    SensorData
  >
  _readings = [];
  bool
  _isLoading = true;

  @override
  void
  initState() {
    super.initState();
    _fetchReadings();
  }

  Future<
    void
  >
  _fetchReadings() async {
    setState(
      () => _isLoading = true,
    );
    final readings = await _apiService.getReadings(
      limit: 50,
    );
    if (mounted) {
      setState(
        () {
          _readings = readings.reversed.toList();
          _isLoading = false;
        },
      );
    }
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF1F8E9,
      ),
      appBar: AppBar(
        title: const Text(
          'Sensor History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _readings.isEmpty
          ? const Center(
              child: Text(
                'No data available',
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(
                16,
              ),
              children: [
                _buildChart(
                  'Temperature (°C)',
                  Colors.orange,
                  _readings
                      .map(
                        (
                          r,
                        ) => r.temperature,
                      )
                      .toList(),
                ),
                const SizedBox(
                  height: 24,
                ),
                _buildChart(
                  'Humidity (%)',
                  Colors.blue,
                  _readings
                      .map(
                        (
                          r,
                        ) => r.humidity,
                      )
                      .toList(),
                ),
                const SizedBox(
                  height: 24,
                ),
                _buildChart(
                  'Soil Moisture (%)',
                  Colors.green,
                  _readings
                      .map(
                        (
                          r,
                        ) => r.soilPct,
                      )
                      .toList(),
                ),
              ],
            ),
    );
  }

  Widget
  _buildChart(
    String title,
    Color color,
    List<
      double
    >
    values,
  ) {
    if (values.isEmpty) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          20,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(
              alpha: 0.15,
            ),
            blurRadius: 12,
            offset: const Offset(
              0,
              4,
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(
                    8,
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
                    _getIconForTitle(
                      title,
                    ),
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine:
                        (
                          value,
                        ) {
                          return FlLine(
                            color: Colors.grey.withValues(
                              alpha: 0.2,
                            ),
                            strokeWidth: 1,
                          );
                        },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget:
                            (
                              value,
                              meta,
                            ) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(
                                    0xFF757575,
                                  ),
                                ),
                              );
                            },
                      ),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
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
                      barWidth: 3,
                      dotData: const FlDotData(
                        show: false,
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
      ),
    );
  }

  IconData
  _getIconForTitle(
    String title,
  ) {
    if (title.contains(
      'Temperature',
    ))
      return Icons.thermostat;
    if (title.contains(
      'Humidity',
    ))
      return Icons.water_drop;
    if (title.contains(
      'Soil',
    ))
      return Icons.grass;
    return Icons.sensors;
  }
}
