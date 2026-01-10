import 'package:flutter/material.dart';
import 'dart:async';
import '../models/sensor_data.dart';
import '../models/plant_status.dart';
import '../services/api_service.dart';
import '../services/threshold_service.dart';
import '../services/notification_service.dart';
import '../widgets/sensor_card.dart';
import '../widgets/mini_chart.dart';
import 'history_screen.dart';
import 'ai_chat_screen.dart';
import 'voice_agent_screen.dart';
import 'plant_disease_screen.dart';

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
        // Set plant name in controller if it exists
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

        // Add new reading to the list
        _recentReadings.add(data);

        // Keep only the last 10 readings
        if (_recentReadings.length > _maxReadings) {
          _recentReadings.removeAt(0);
        }
      });

      // Check thresholds and send notifications
      _checkThresholdsAndNotify(data);
    }
  }

  /// Check sensor thresholds and send notifications
  Future<void> _checkThresholdsAndNotify(SensorData data) async {
    try {
      final alerts = await _thresholdService.checkThresholds(data);

      for (final alert in alerts) {
        print('🔔 Alert: ${alert.title}');
        // Show local notification
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
      print('Error checking thresholds: $e');
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
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9), // Light green background
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
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.nature, color: Color(0xFF2E7D32)),
              tooltip: 'Plant Disease',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlantDiseaseScreen(),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.mic, color: Color(0xFF2E7D32)),
              tooltip: 'Voice Agent',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VoiceAgentScreen(sensorData: _latestData),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.psychology, color: Color(0xFF2E7D32)),
              tooltip: 'AI Assistant',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AiChatScreen(sensorData: _latestData),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.show_chart, color: Color(0xFF2E7D32)),
              tooltip: 'History',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLatestData,
        color: const Color(0xFF2E7D32),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _latestData == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sensors_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No sensor data available',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Welcome Card
                  Container(
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
                          child: const Icon(
                            Icons.wb_sunny,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Farm Status',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getStatusMessage(_latestData!),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Plant Status Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF4CAF50,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.eco,
                                  color: Color(0xFF2E7D32),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Do you have a plant?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _updatePlantStatus(true),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Yes, I have'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _plantStatus?.hasPlant == true
                                        ? Colors.green
                                        : Colors.grey[300],
                                    foregroundColor:
                                        _plantStatus?.hasPlant == true
                                        ? Colors.white
                                        : Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _updatePlantStatus(false),
                                  icon: const Icon(Icons.close),
                                  label: const Text('No, I don\'t'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _plantStatus?.hasPlant == false
                                        ? Colors.red
                                        : Colors.grey[300],
                                    foregroundColor:
                                        _plantStatus?.hasPlant == false
                                        ? Colors.white
                                        : Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_plantStatus?.hasPlant == true) ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: _plantNameController,
                              decoration: InputDecoration(
                                hintText:
                                    'Enter plant name (e.g., Tomato, Rose)',
                                prefixIcon: const Icon(Icons.local_florist),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              onChanged: (value) {
                                _updatePlantStatus(true, plantName: value);
                              },
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _plantNameController.text.isNotEmpty
                                          ? '🌱 ${_plantNameController.text} - Ready for disease detection'
                                          : 'Great! You can use Plant Disease Detection',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (_plantStatus?.hasPlant == false) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Plant Disease Detection will be available when you have a plant',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sensor Cards
                  SensorCard(
                    title: 'Temperature',
                    value: '${_latestData!.temperature.toStringAsFixed(1)}°C',
                    icon: Icons.thermostat,
                    color: const Color(0xFFFF6F00),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8A00), Color(0xFFFF6F00)],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SensorCard(
                    title: 'Humidity',
                    value: '${_latestData!.humidity.toStringAsFixed(1)}%',
                    icon: Icons.water_drop,
                    color: const Color(0xFF0288D1),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF03A9F4), Color(0xFF0288D1)],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SensorCard(
                    title: 'Soil Moisture',
                    value: '${_latestData!.soilPct.toStringAsFixed(1)}%',
                    subtitle: 'Raw: ${_latestData!.soilRaw}',
                    icon: Icons.grass,
                    color: const Color(0xFF388E3C),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Real-time Graphs Section
                  if (_recentReadings.length > 1) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF4CAF50,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.trending_up,
                              color: Color(0xFF2E7D32),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Live Trends',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Last ${_recentReadings.length} readings',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    MiniChart(
                      values: _getTemperatureValues(),
                      color: const Color(0xFFFF6F00),
                      title: 'Temperature',
                      icon: Icons.thermostat,
                    ),
                    MiniChart(
                      values: _getHumidityValues(),
                      color: const Color(0xFF0288D1),
                      title: 'Humidity',
                      icon: Icons.water_drop,
                    ),
                    MiniChart(
                      values: _getSoilMoistureValues(),
                      color: const Color(0xFF388E3C),
                      title: 'Soil Moisture',
                      icon: Icons.grass,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Last Updated Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4CAF50,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.update,
                            size: 20,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Last updated: ${_formatTime(_latestData!.timestamp)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF616161),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _getStatusMessage(SensorData data) {
    if (data.soilPct < 30) {
      return 'Needs Water 💧';
    } else if (data.temperature > 35) {
      return 'Too Hot 🌡️';
    } else if (data.humidity > 80) {
      return 'High Humidity 💦';
    } else {
      return 'All Good 🌱';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    return '${diff.inDays}d ago';
  }
}
