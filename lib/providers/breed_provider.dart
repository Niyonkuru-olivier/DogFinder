import 'package:flutter/material.dart';

import '../models/breed.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class BreedProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  List<Breed> _allBreeds = [];
  List<Breed> _visibleBreeds = [];
  String _searchQuery = '';
  BreedFilter _activeFilter = BreedFilter.all;

  bool _isLoading = false;
  bool _isOffline = false;
  String? _errorMessage;

  List<Breed> get allBreeds => _allBreeds;
  List<Breed> get visibleBreeds => _visibleBreeds;
  String get searchQuery => _searchQuery;
  BreedFilter get activeFilter => _activeFilter;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;

  int get totalBreeds => _allBreeds.length;

  String get averageLifeSpan {
    if (_allBreeds.isEmpty) return 'Unknown';

    final spans = _allBreeds
        .map((breed) {
          final match = RegExp(r'(\d+)\s*-\s*(\d+)').firstMatch(breed.lifeSpan);
          if (match == null) return null;
          final min = int.tryParse(match.group(1)!);
          final max = int.tryParse(match.group(2)!);
          if (min == null || max == null) return null;
          return ((min + max) / 2).round();
        })
        .whereType<int>()
        .toList();

    if (spans.isEmpty) return 'Unknown';
    final average = spans.reduce((a, b) => a + b) / spans.length;
    return '${average.round()} years';
  }

  String get mostPopularGroup {
    if (_allBreeds.isEmpty) return 'Unknown';

    final counts = <String, int>{};
    for (final breed in _allBreeds) {
      counts[breed.breedGroup] = (counts[breed.breedGroup] ?? 0) + 1;
    }

    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return top.key;
  }

  Future<void> loadBreeds() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final breeds = await _apiService.fetchBreeds();
      await _apiService.attachImages(breeds, limit: imageBatchSize);
      _allBreeds = breeds;
      _isOffline = false;
      await _storageService.cacheBreeds(breeds);
      _applyFilters();
      _isLoading = false;
      notifyListeners();
      _loadRemainingImages();
    } catch (error, stackTrace) {
      debugPrint('Error loading breeds: $error');
      debugPrint('Stack trace: $stackTrace');
      final cached = await _storageService.loadCachedBreeds();
      if (cached.isNotEmpty) {
        _allBreeds = cached;
        _isOffline = true;
        _errorMessage = null;
        _applyFilters();
      } else {
        _errorMessage = 'Unable to load breeds: $error';
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadRemainingImages() async {
    await _apiService.attachImages(_allBreeds);
    _applyFilters();
    notifyListeners();
    await _storageService.cacheBreeds(_allBreeds);
  }

  Future<void> refreshBreeds() async {
    await loadBreeds();
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (query.trim().isEmpty) {
        if (_allBreeds.isEmpty) {
          await loadBreeds();
          return;
        }
        _applyFilters();
      } else if (_isOffline) {
        _applyFilters();
      } else {
        final results = await _apiService.searchBreeds(query);
        await _apiService.attachImages(results, limit: imageBatchSize);
        _visibleBreeds = _filterBreeds(results);
      }

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  void setFilter(BreedFilter filter) {
    _activeFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    final source = _searchQuery.trim().isEmpty
        ? _allBreeds
        : _allBreeds
            .where((breed) => breed.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    _visibleBreeds = _filterBreeds(source);
  }

  List<Breed> _filterBreeds(List<Breed> breeds) {
    switch (_activeFilter) {
      case BreedFilter.all:
        return breeds;
      case BreedFilter.small:
        return breeds.where((breed) => breed.sizeCategory == 'small').toList();
      case BreedFilter.medium:
        return breeds.where((breed) => breed.sizeCategory == 'medium').toList();
      case BreedFilter.large:
        return breeds.where((breed) => breed.sizeCategory == 'large').toList();
      case BreedFilter.active:
        return breeds.where((breed) => breed.isActive).toList();
      case BreedFilter.family:
        return breeds.where((breed) => breed.isFamilyFriendly).toList();
    }
  }

  Breed? findById(int id) {
    for (final breed in _allBreeds) {
      if (breed.id == id) return breed;
    }
    return null;
  }
}
