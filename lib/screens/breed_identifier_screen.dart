import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/breed_provider.dart';
import '../providers/history_provider.dart';
import '../services/ai_classifier_service.dart';
import '../theme/app_theme.dart';
import '../widgets/dog_image_widget.dart';
import 'detail_screen.dart';

class BreedIdentifierScreen extends StatefulWidget {
  const BreedIdentifierScreen({super.key});

  @override
  State<BreedIdentifierScreen> createState() => _BreedIdentifierScreenState();
}

class _BreedIdentifierScreenState extends State<BreedIdentifierScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  final AiClassifierService _classifierService = AiClassifierService();

  XFile? _selectedImage;
  bool _isAnalyzing = false;
  String _analysisStatus = '';
  PredictionResult? _predictionResult;

  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize API key text field from provider
    Future.microtask(() {
      if (!mounted) return;
      _apiKeyController.text = context.read<HistoryProvider>().geminiApiKey;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
          _predictionResult = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<void> _analyzeBreed() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _predictionResult = null;
    });

    final breedProvider = context.read<BreedProvider>();
    final historyProvider = context.read<HistoryProvider>();

    // Simulated status updates
    final statuses = [
      'Initializing image processor...',
      'Detecting dog boundaries...',
      'Analyzing coat patterns and snout shape...',
      'Matching features with breed database...',
      'Computing prediction confidence...',
    ];

    for (int i = 0; i < statuses.length; i++) {
      if (!mounted || !_isAnalyzing) return;
      setState(() {
        _analysisStatus = statuses[i];
      });
      await Future.delayed(Duration(milliseconds: 400 + (i * 100)));
    }

    try {
      final result = await _classifierService.classifyImage(
        imageFile: _selectedImage!,
        allBreeds: breedProvider.allBreeds,
        apiKey: historyProvider.geminiApiKey,
      );

      if (!mounted) return;

      setState(() {
        _predictionResult = result;
        _isAnalyzing = false;
      });

      // Save to history
      await historyProvider.addRecord(
        imagePath: _selectedImage!.path,
        result: result,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analysis failed: $e')),
      );
    }
  }

  void _shareResult() {
    if (_predictionResult == null) return;
    final text = 'I just identified a dog breed using DogFinder AI!\n\n'
        '🐶 Breed: ${_predictionResult!.breedName}\n'
        '📈 Confidence: ${(_predictionResult!.confidence * 100).toStringAsFixed(0)}%\n'
        '✨ Temperament: ${_predictionResult!.temperament}\n'
        '⏳ Life Span: ${_predictionResult!.lifeSpan}\n'
        '⚖️ Weight: ${_predictionResult!.weight}\n\n'
        'Try DogFinder to identify your dog breed!';
    Share.share(text);
  }

  void _reset() {
    setState(() {
      _selectedImage = null;
      _predictionResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog Breed Identifier', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key),
            tooltip: 'Gemini API Key Settings',
            onPressed: _showApiKeySettingsDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.psychology), text: 'Identify'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIdentifyTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildIdentifyTab() {
    final hasImage = _selectedImage != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!hasImage) ...[
            _buildUploadCard(),
          ] else ...[
            _buildImagePreview(),
            const SizedBox(height: 20),
            if (!_isAnalyzing && _predictionResult == null)
              ElevatedButton.icon(
                onPressed: _analyzeBreed,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Analyze Breed'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
          ],
          if (_isAnalyzing) _buildLoadingState(),
          if (_predictionResult != null && !_isAnalyzing) _buildResultState(),
        ],
      ),
    );
  }

  Widget _buildUploadCard() {
    return Column(
      children: [
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.none),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.8)),
              const SizedBox(height: 16),
              const Text(
                'Let\'s identify your dog!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a photo or capture one now.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.collections_rounded),
                label: const Text('Upload Photo'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_rounded),
                label: const Text('Take Picture'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        // Mini note about Gemini API option
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Supports real Google Gemini Vision classification if you add your API key using the key icon at the top right.',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: _buildXFileImage(_selectedImage!, height: 300, width: double.infinity),
          ),
        ),
        if (!_isAnalyzing)
          Positioned(
            top: 16,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: _reset,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildXFileImage(XFile file, {double? height, double? width}) {
    if (kIsWeb) {
      return Image.network(
        file.path,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          width: width,
          color: Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 40, color: Colors.grey),
        ),
      );
    }
    return Image.file(
      File(file.path),
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        width: width,
        color: Colors.grey.shade200,
        child: const Icon(Icons.pets, size: 40, color: Colors.grey),
      ),
    );
  }

  Widget _buildPathImage(String path, {double? height, double? width}) {
    if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('blob:') || kIsWeb) {
      return Image.network(
        path,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          width: width,
          color: Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 24, color: Colors.grey),
        ),
      );
    }
    return Image.file(
      File(path),
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        width: width,
        color: Colors.grey.shade200,
        child: const Icon(Icons.pets, size: 24, color: Colors.grey),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 60,
            width: 60,
            child: CircularProgressIndicator(strokeWidth: 4),
          ),
          const SizedBox(height: 20),
          Text(
            'Analyzing Image...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _analysisStatus,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildResultState() {
    final result = _predictionResult!;
    final confidencePercent = (result.confidence * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Prediction',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            result.breedName,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Confidence',
                            style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '$confidencePercent%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                _buildResultMetric(Icons.stars_rounded, 'Temperament', result.temperament),
                const SizedBox(height: 12),
                _buildResultMetric(Icons.timer_rounded, 'Life Span', result.lifeSpan),
                const SizedBox(height: 12),
                _buildResultMetric(Icons.scale_rounded, 'Weight', result.weight),
                if (result.breed != null) ...[
                  const Divider(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(breed: result.breed!),
                          ),
                        );
                      },
                      child: const Text('View Full Breed Profile'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (result.similarBreeds.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Similar Breeds',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: result.similarBreeds.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final b = result.similarBreeds[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(breed: b),
                        ),
                      );
                    },
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: DogImageWidget(
                                imageUrl: b.displayImageUrl,
                                fallbackUrl: b.fallbackImageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: Text(
                                b.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareResult,
                  icon: const Icon(Icons.ios_share_rounded),
                  label: const Text('Share Result'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildResultMetric(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, _) {
        final items = historyProvider.items;

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No Prediction History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Predictions you make will appear here.',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${items.length} Predictions Saved',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => _confirmClearHistory(historyProvider),
                    icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                    label: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final breedProvider = context.read<BreedProvider>();
                  final dateStr = _formatTimestamp(item.timestamp);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: SizedBox(
                        width: 60,
                        height: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildPathImage(item.imagePath, width: 60, height: 60),
                        ),
                      ),
                      title: Text(
                        item.breedName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Confidence: ${(item.confidence * 100).toStringAsFixed(0)}%'),
                          const SizedBox(height: 2),
                          Text(dateStr, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () {
                        // Display the selected item
                        setState(() {
                          _selectedImage = XFile(item.imagePath);
                          _predictionResult = item.toPredictionResult(breedProvider.allBreeds);
                          _tabController.animateTo(0);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(dt.year, dt.month, dt.day);

    if (checkDate == today) {
      return 'Today at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (checkDate == yesterday) {
      return 'Yesterday at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  void _confirmClearHistory(HistoryProvider historyProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This will delete all saved predictions permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              historyProvider.clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showApiKeySettingsDialog() {
    final historyProvider = context.read<HistoryProvider>();
    _apiKeyController.text = historyProvider.geminiApiKey;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gemini API Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Google Gemini API Key to use real vision AI classification:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
                hintText: 'AIzaSy...',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              historyProvider.saveApiKey(_apiKeyController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gemini API Key saved successfully.')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
