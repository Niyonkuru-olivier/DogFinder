import 'package:flutter/material.dart';

import '../models/breed.dart';
import '../services/api_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  final Set<int> _favoriteIds = {};
  bool _initialized = false;

  Set<int> get favoriteIds => _favoriteIds;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    _favoriteIds
      ..clear()
      ..addAll(await _storageService.loadFavoriteIds());
    _initialized = true;
    notifyListeners();
  }

  bool isFavorite(int breedId) => _favoriteIds.contains(breedId);

  Future<void> toggleFavorite(int breedId) async {
    if (_favoriteIds.contains(breedId)) {
      _favoriteIds.remove(breedId);
    } else {
      _favoriteIds.add(breedId);
    }
    notifyListeners();
    await _storageService.saveFavoriteIds(_favoriteIds);
  }

  List<Breed> favoriteBreeds(List<Breed> allBreeds) {
    return allBreeds.where((breed) => _favoriteIds.contains(breed.id)).toList();
  }
}

class RandomDogProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Breed? _randomBreed;
  bool _isLoading = false;
  String? _errorMessage;

  Breed? get randomBreed => _randomBreed;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRandomDog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _randomBreed = await _apiService.fetchRandomBreedWithImage();
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }
}

class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  bool _isDarkMode = false;
  bool _initialized = false;

  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    _isDarkMode = await _storageService.loadDarkMode();
    _initialized = true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _storageService.saveDarkMode(_isDarkMode);
  }
}

class CompareProvider extends ChangeNotifier {
  Breed? _firstBreed;
  Breed? _secondBreed;

  Breed? get firstBreed => _firstBreed;
  Breed? get secondBreed => _secondBreed;

  bool get isReady => _firstBreed != null && _secondBreed != null;

  void selectBreed(Breed breed) {
    if (_firstBreed?.id == breed.id || _secondBreed?.id == breed.id) {
      return;
    }

    if (_firstBreed == null) {
      _firstBreed = breed;
    } else if (_secondBreed == null) {
      _secondBreed = breed;
    } else {
      _firstBreed = breed;
      _secondBreed = null;
    }
    notifyListeners();
  }

  void clear() {
    _firstBreed = null;
    _secondBreed = null;
    notifyListeners();
  }
}
