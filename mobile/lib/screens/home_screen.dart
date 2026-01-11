import 'package:flutter/material.dart';
import 'dart:async';
import '../models/sensor_data.dart';
import '../models/plant_status.dart';
import '../services/api_service.dart';
import '../services/threshold_service.dart';
import '../services/notification_service.dart';
import '../widgets/sensor_card.dart';
import '../widgets/mini_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _plantNameController = TextEditingController();
  final ThresholdService _thresholdService = ThresholdService();
  final NotificationService _notificationService = NotificationService();
  SensorData? _latestData;
  PlantStatus? _plantStatus;
  final List<SensorData> _recentReadings = [];
  bool _isLoading = true;
  Timer? _timer;
  static const int _maxReadings = 10;

  @override
  void initState() {
    super.initState();
    _fetchPlantStatus();
    _fetchLatestData();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _fetchLatestData(),
    );
  }

  @override
  void dispose() {
    _plantNameController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPlantStatus() async {
    final status = await _apiService.getPlantStatus();
    if (mounted) {
      setState(() {
        _plantStatus = status;
        if (status?.plantType != null) {
          _plantNameController.text = status!.plantType!;
        }
      });
    }
  }

  Future<void> _fetchLatestData() async {
    final data = await _apiService.getLatestReading();
    if (mounted && data != null) {
      setState(() {
        _latestData = data;
        _isLoading = false;
        _recentReadings.add(data);
        if (_recentReadings.length > _maxReadings) {
          _recentReadings.removeAt(0);
        }
      });
      _checkThresholdsAndNotify(data);
    }
  }

  Future<void> _checkThresholdsAndNotify(SensorData data) async {
    try {
      final alerts = await _thresholdService.checkThresholds(data);
      for (final alert in alerts) {
        await _notificationService.showNotification(
          title: alert.title,
          body: alert.message,
          payload: {
            'type': alert.type.toString(),
            'sensorType': alert.sensorType,
            'value': alert.value.toString(),
            'unit': alert.unit,
          },
        );
      }
    } catch (e) {
      debugPrint('Error checking thresholds: $e');
    }
  }

  Future<void> _updatePlantStatus(bool hasPlant, {String? plantName}) async {
    final success = await _apiService.updatePlantStatus(
      hasPlant,
      plantType: plantName,
    );
    if (success) {
      await _fetchPlantStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hasPlant
                  ? '✅ Plant status updated${plantName != null && plantName.isNotEmpty ? ': $plantName' : ''}'
                  : '❌ Plant status updated',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  List<double> _getTemperatureValues() {
    return _recentReadings.map((r) => r.temperature).toList();
  }

  List<double> _getHumidityValues() {
    return _recentReadings.map((r) => r.humidity).toList();
  }

  List<double> _getSoilMoistureValues() {
    return _recentReadings.map((r) => r.soilPct).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.agriculture,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              'KisanGuide',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLatestData,
        color: Theme.of(context).colorScheme.primary,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _latestData == null
            ? _buildEmptyState()
            : _buildContent(isDark),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sensors_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No sensor data available',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchLatestData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome Card
        _buildWelcomeCard(),
        const SizedBox(height: 20),

        // Plant Status Card
        _buildPlantStatusCard(),
        const SizedBox(height: 20),

        // Sensor Cards
        _buildSensorCardsGrid(),
        const SizedBox(height: 20),

        // Live Trends Section
        _buildTrendsSection(),
        const SizedBox(height: 20),

        // Last Updated
        _buildLastUpdatedCard(),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.wb_sunny, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to KisanGuide',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Monitor your farm in real-time',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.eco,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Plant Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_plantStatus?.hasPlant == true)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '🌱 ${_plantStatus?.plantType ?? "Plant"}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updatePlantStatus(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                          ),
                          child: const Text('No Plant'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                          ),
                          child: const Text('Has Plant'),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cancel, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'No plant selected',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                          ),
                          child: const Text('Yes, I have'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updatePlantStatus(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                          ),
                          child: const Text('No Plant'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCardsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Sensor Data',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SensorCard(
          title: 'Temperature',
          value: '${_latestData?.temperature.toStringAsFixed(1)}°C',
          subtitle: _getTemperatureStatus(),
          icon: Icons.thermostat,
          color: const Color(0xFFFF6F00),
        ),
        const SizedBox(height: 12),
        SensorCard(
          title: 'Humidity',
          value: '${_latestData?.humidity.toStringAsFixed(1)}%',
          subtitle: _getHumidityStatus(),
          icon: Icons.water_drop,
          color: const Color(0xFF0288D1),
        ),
        const SizedBox(height: 12),
        SensorCard(
          title: 'Soil Moisture',
          value: '${_latestData?.soilPct.toStringAsFixed(1)}%',
          subtitle: _getSoilStatus(),
          icon: Icons.grain,
          color: const Color(0xFF388E3C),
        ),
      ],
    );
  }

  Widget _buildTrendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Trends',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        MiniChart(
          values: _getTemperatureValues(),
          color: const Color(0xFFFF6F00),
          title: 'Temperature Trend',
          icon: Icons.thermostat,
        ),
        MiniChart(
          values: _getHumidityValues(),
          color: const Color(0xFF0288D1),
          title: 'Humidity Trend',
          icon: Icons.water_drop,
        ),
        MiniChart(
          values: _getSoilMoistureValues(),
          color: const Color(0xFF388E3C),
          title: 'Soil Moisture Trend',
          icon: Icons.grain,
        ),
      ],
    );
  }

  Widget _buildLastUpdatedCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(
              'Last updated: ${_latestData?.timestamp.toString().split('.')[0] ?? 'N/A'}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _getTemperatureStatus() {
    if (_latestData == null) return 'N/A';
    final temp = _latestData!.temperature;
    if (temp < 10) return '❄️ Cold';
    if (temp > 35) return '🔥 Hot';
    return '✅ Optimal';
  }

  String _getHumidityStatus() {
    if (_latestData == null) return 'N/A';
    final humidity = _latestData!.humidity;
    if (humidity < 30) return '🏜️ Dry';
    if (humidity > 80) return '💧 Humid';
    return '✅ Optimal';
  }

  String _getSoilStatus() {
    if (_latestData == null) return 'N/A';
    final soil = _latestData!.soilPct;
    if (soil < 30) return '🌵 Dry';
    if (soil > 80) return '💦 Wet';
    return '✅ Optimal';
  }
}
