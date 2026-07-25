import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/breed.dart';
import '../services/ai_classifier_service.dart';

class HistoryItem {
  final DateTime timestamp;
  final String imagePath;
  final String breedName;
  final double confidence;
  final String temperament;
  final String lifeSpan;
  final String weight;
  final int? breedId;

  HistoryItem({
    required this.timestamp,
    required this.imagePath,
    required this.breedName,
    required this.confidence,
    required this.temperament,
    required this.lifeSpan,
    required this.weight,
    this.breedId,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
      'breedName': breedName,
      'confidence': confidence,
      'temperament': temperament,
      'lifeSpan': lifeSpan,
      'weight': weight,
      'breedId': breedId,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      timestamp: DateTime.parse(json['timestamp'] as String),
      imagePath: json['imagePath'] as String,
      breedName: json['breedName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      temperament: json['temperament'] as String? ?? '',
      lifeSpan: json['lifeSpan'] as String? ?? '',
      weight: json['weight'] as String? ?? '',
      breedId: json['breedId'] as int?,
    );
  }

  PredictionResult toPredictionResult(List<Breed> allBreeds) {
    Breed? matchedBreed;
    if (breedId != null && allBreeds.isNotEmpty) {
      matchedBreed = allBreeds.firstWhere((b) => b.id == breedId, orElse: () => allBreeds.first);
    }
    
    final similar = allBreeds.isNotEmpty && matchedBreed != null
        ? allBreeds
            .where((b) => b.id != matchedBreed?.id && b.breedGroup == matchedBreed?.breedGroup && b.breedGroup != 'Unknown')
            .take(3)
            .toList()
        : <Breed>[];

    return PredictionResult(
      breedName: breedName,
      confidence: confidence,
      temperament: temperament,
      lifeSpan: lifeSpan,
      weight: weight,
      breed: matchedBreed,
      similarBreeds: similar,
    );
  }
}

class HistoryProvider extends ChangeNotifier {
  static const String _historyKey = 'ai_breed_prediction_history_v1';
  static const String _apiKeyPrefKey = 'gemini_api_key_v1';

  List<HistoryItem> _items = [];
  String _geminiApiKey = '';
  bool _initialized = false;

  List<HistoryItem> get items => _items;
  String get geminiApiKey => _geminiApiKey;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load history
    final cached = prefs.getString(_historyKey);
    if (cached != null) {
      try {
        final List<dynamic> list = jsonDecode(cached);
        _items = list.map((x) => HistoryItem.fromJson(x as Map<String, dynamic>)).toList();
        // Sort descending by timestamp
        _items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } catch (e) {
        debugPrint('Failed to load history from cache: $e');
      }
    }

    // Load API Key
    _geminiApiKey = prefs.getString(_apiKeyPrefKey) ?? '';
    _initialized = true;
    notifyListeners();
  }

  Future<void> saveApiKey(String apiKey) async {
    _geminiApiKey = apiKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPrefKey, apiKey);
    notifyListeners();
  }

  Future<void> addRecord({
    required String imagePath,
    required PredictionResult result,
  }) async {
    final item = HistoryItem(
      timestamp: DateTime.now(),
      imagePath: imagePath,
      breedName: result.breedName,
      confidence: result.confidence,
      temperament: result.temperament,
      lifeSpan: result.lifeSpan,
      weight: result.weight,
      breedId: result.breed?.id,
    );

    _items.insert(0, item);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_items.map((x) => x.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
  }

  Future<void> clearHistory() async {
    _items.clear();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
