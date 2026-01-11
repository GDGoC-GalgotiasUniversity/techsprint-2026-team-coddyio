import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/plant_disease_result.dart';
import '../services/api_service.dart';
import '../services/gemini_service.dart';
import '../services/plant_disease_service.dart';

class PlantDiseaseScreen extends StatefulWidget {
  const PlantDiseaseScreen({super.key});

  @override
  State<PlantDiseaseScreen> createState() => _PlantDiseaseScreenState();
}

class _PlantDiseaseScreenState extends State<PlantDiseaseScreen> {
  final ApiService _apiService = ApiService();
  final GeminiService _geminiService = GeminiService();
  final PlantDiseaseService _diseaseService = PlantDiseaseService();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  PlantDiseaseResult? _detectionResult;
  Map<String, dynamic>? _diseaseInfo;
  String? _remedies;
  bool _isLoading = false;
  bool _isLoadingRemedies = false;
  bool _isLoadingInfo = false;
  String? _uploadProgress;
  String? _plantName;

  @override
  void initState() {
    super.initState();
    _fetchPlantName();
  }

  /// Fetch plant name from API
  Future<void> _fetchPlantName() async {
    try {
      final status = await _apiService.getPlantStatus();
      if (mounted && status?.hasPlant == true && status?.plantType != null) {
        setState(() {
          _plantName = status!.plantType;
        });
      }
    } catch (e) {
      print('Error fetching plant name: $e');
    }
  }

  Future<Uint8List> _compressImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize to max 800x800 while maintaining aspect ratio
      final resized = img.copyResize(
        image,
        width: image.width > 800 ? 800 : image.width,
        height: image.height > 800 ? 800 : image.height,
        interpolation: img.Interpolation.linear,
      );

      // Compress to JPEG with 85% quality
      final compressed = img.encodeJpg(resized, quality: 85);

      print(
        '📦 Image compressed: ${imageBytes.length} → ${compressed.length} bytes',
      );
      return Uint8List.fromList(compressed);
    } catch (e) {
      print('⚠️ Compression failed, using original: $e');
      return await imageFile.readAsBytes();
    }
  }

  /// Request camera or photo library permissions
  Future<bool> _requestPermission(Permission permission) async {
    try {
      final status = await permission.request();
      return status.isGranted;
    } catch (e) {
      print('❌ Error requesting permission: $e');
      return false;
    }
  }

  /// Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      print('📸 Picking image from ${source.name}...');

      // Request appropriate permission
      Permission permission;
      if (source == ImageSource.camera) {
        permission = Permission.camera;
      } else {
        // For Android 13+, use READ_MEDIA_IMAGES; for older versions, use READ_EXTERNAL_STORAGE
        permission = Permission.photos;
      }

      final hasPermission = await _requestPermission(permission);

      if (!hasPermission) {
        if (mounted) {
          _showErrorDialog(
            'Permission Denied',
            'Please grant ${source == ImageSource.camera ? 'camera' : 'photo library'} permission to use this feature.',
          );
        }
        return;
      }

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _detectionResult = null;
          _diseaseInfo = null;
          _remedies = null;
          _uploadProgress = 'Image selected. Ready to analyze.';
        });

        print('✅ Image selected: ${pickedFile.path}');
        _detectDisease();
      } else {
        print('⚠️ No image selected');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      if (mounted) {
        _showErrorDialog('Error', 'Error picking image: $e');
      }
    }
  }

  /// Detect plant disease from selected image
  Future<void> _detectDisease() async {
    if (_selectedImage == null) {
      _showErrorDialog('Error', 'Please select an image first');
      return;
    }

    setState(() {
      _isLoading = true;
      _detectionResult = null;
      _diseaseInfo = null;
      _remedies = null;
      _uploadProgress = 'Compressing image...';
    });

    try {
      // Compress image
      setState(() => _uploadProgress = 'Compressing image...');
      final compressedBytes = await _compressImage(_selectedImage!);

      // Upload and detect
      setState(() => _uploadProgress = 'Uploading to server...');
      final result = await _apiService.detectPlantDisease(compressedBytes);

      if (mounted) {
        setState(() {
          _detectionResult = result;
          _isLoading = false;
          _uploadProgress = 'Analysis complete!';
        });

        print('✅ Disease detected: ${result?.prediction}');

        if (result != null) {
          // Get disease info and remedies
          _getDiseaseInfo(result.prediction);
          _getRemedies(result.prediction);
        }
      }
    } catch (e) {
      print('❌ Error detecting disease: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _uploadProgress = 'Error: $e';
        });
        _showErrorDialog('Error', 'Error detecting disease: $e');
      }
    }
  }

  /// Get disease information from server
  Future<void> _getDiseaseInfo(String disease) async {
    setState(() => _isLoadingInfo = true);

    try {
      print('📖 Getting disease info for: $disease');

      final info = await _diseaseService.getDiseaseInfo(disease);

      if (mounted) {
        setState(() {
          _diseaseInfo = info;
          _isLoadingInfo = false;
        });

        print('✅ Disease info retrieved');
      }
    } catch (e) {
      print('❌ Error getting disease info: $e');
      if (mounted) {
        setState(() => _isLoadingInfo = false);
      }
    }
  }

  /// Get remedies from Gemini AI
  Future<void> _getRemedies(String disease) async {
    setState(() => _isLoadingRemedies = true);

    try {
      print('🤖 Getting remedies from Gemini...');

      final initialized = await _geminiService.initialize();
      if (!initialized) {
        throw Exception('Failed to initialize Gemini service');
      }

      // Build plant-specific prompt
      String plantContext = '';
      if (_plantName != null && _plantName!.isNotEmpty) {
        plantContext = 'The plant is a $_plantName. ';
      }

      // Use simple, layman-friendly home remedies
      final prompt =
          '''You are a helpful farmer's assistant. A plant has a problem: $disease
${plantContext}Give SIMPLE home remedies using things farmers already have at home. Use EASY words, not scientific terms.

Format like this:

🏥 WHAT TO DO RIGHT NOW (Easy Fixes):
• Mix baking soda with water and spray on leaves (1 spoon baking soda in 1 bucket water)
• Pick off the bad leaves by hand and throw away
• Cut branches to let air flow through the plant
• Spray cooking oil mixed with water (few drops oil in water)

🛡️ HOW TO STOP IT HAPPENING AGAIN:
• Water the soil, not the leaves
• Put dry grass or leaves around the plant (mulch)
• Don't plant the same crop in same spot next year
• Keep plants far apart so air can move

⚠️ WHEN TO GET HELP FROM EXPERT:
• The problem keeps getting worse even after you try these
• More than half the plant is damaged
• The whole field is getting sick

Use ONLY things a farmer has at home - no fancy chemicals. Keep it SHORT and easy to understand.''';

      final response = await _geminiService.getRemedieSuggestions(prompt);

      if (mounted) {
        setState(() {
          _remedies = response;
          _isLoadingRemedies = false;
        });

        print('✅ Remedies retrieved');
      }
    } catch (e) {
      print('❌ Error getting remedies: $e');
      if (mounted) {
        setState(() => _isLoadingRemedies = false);
      }
    }
  }

  /// Show error dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Clear selected image and results
  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _detectionResult = null;
      _diseaseInfo = null;
      _remedies = null;
      _uploadProgress = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🌱 Plant Disease Detection'),
            if (_plantName != null && _plantName!.isNotEmpty)
              Text(
                'Monitoring: $_plantName',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        elevation: 0,
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearImage,
              tooltip: 'Clear image',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Selection Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Image Preview
                      if (_selectedImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 64,
                                  color: Colors.green,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No image selected',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Camera and Gallery Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Upload Progress
                      if (_uploadProgress != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _uploadProgress!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Loading Indicator
              if (_isLoading)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text(
                          'Analyzing plant image...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              // Detection Result Card
              else if (_detectionResult != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: _detectionResult!.isHealthy
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Header
                        Row(
                          children: [
                            Icon(
                              _detectionResult!.isHealthy
                                  ? Icons.check_circle
                                  : Icons.warning,
                              size: 32,
                              color: _detectionResult!.isHealthy
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _detectionResult!.isHealthy
                                        ? 'Plant is Healthy! 🎉'
                                        : 'Disease Detected ⚠️',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _detectionResult!.isHealthy
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _detectionResult!.formattedPrediction,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Confidence Score
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Confidence:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              _detectionResult!.confidencePercentage,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Confidence Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _detectionResult!.confidence,
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _detectionResult!.confidence > 0.8
                                  ? Colors.green
                                  : _detectionResult!.confidence > 0.6
                                  ? Colors.orange
                                  : Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Top Predictions
                        if (_detectionResult!.topPredictions.isNotEmpty) ...[
                          const Text(
                            'Top Predictions:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._detectionResult!.topPredictions
                              .asMap()
                              .entries
                              .map((entry) {
                                final index = entry.key + 1;
                                final prediction = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '$index. ${prediction.formattedClass}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      Text(
                                        prediction.confidencePercentage,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ],
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Disease Information Card
              if (_diseaseInfo != null && !_isLoadingInfo)
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
                        const Text(
                          'Disease Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Plant: ${_diseaseInfo!['plant']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Condition: ${_diseaseInfo!['condition']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Remedies Card
              if (_remedies != null && !_isLoadingRemedies)
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
                        const Text(
                          'Treatment & Prevention',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _remedies!,
                          style: const TextStyle(fontSize: 14, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_isLoadingRemedies)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text(
                          'Getting treatment recommendations...',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
