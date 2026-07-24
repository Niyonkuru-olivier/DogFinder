import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/breed.dart';
import '../utils/constants.dart';

class ApiService {
  Map<String, String> get _headers => {'x-api-key': apiKey};

  Future<List<Breed>> fetchBreeds() async {
    final response = await http.get(Uri.parse(breedsUrl), headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch breeds (${response.statusCode})');
    }

    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((item) => Breed.fromJson(item)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<Breed>> searchBreeds(String query) async {
    if (query.trim().isEmpty) {
      return fetchBreeds();
    }

    final response = await http.get(
      Uri.parse('$breedsUrl/search?q=${Uri.encodeQueryComponent(query.trim())}'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to search breeds (${response.statusCode})');
    }

    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((item) => Breed.fromJson(item)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<String?> fetchBreedImage(int breedId) async {
    final response = await http.get(
      Uri.parse('$imagesUrl?breed_id=$breedId&limit=1'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      return null;
    }

    final List<dynamic> jsonData = jsonDecode(response.body);
    if (jsonData.isEmpty) return null;
    return jsonData.first['url'] as String?;
  }

  Future<Breed> fetchRandomBreedWithImage() async {
    final response = await http.get(
      Uri.parse('$imagesUrl?limit=1'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch random dog (${response.statusCode})');
    }

    final List<dynamic> jsonData = jsonDecode(response.body);
    if (jsonData.isEmpty) {
      throw Exception('No random dog image available');
    }

    final imageData = jsonData.first as Map<String, dynamic>;
    final breeds = imageData['breeds'] as List<dynamic>?;

    if (breeds != null && breeds.isNotEmpty) {
      final breed = Breed.fromJson(breeds.first as Map<String, dynamic>);
      return breed.copyWith(imageUrl: imageData['url'] as String?);
    }

    return Breed(
      id: 0,
      name: 'Surprise Dog',
      bredFor: 'A delightful random companion',
      breedGroup: 'Mixed',
      lifeSpan: 'Unknown',
      temperament: 'Friendly, Curious',
      origin: 'Unknown',
      weightMetric: 'Unknown',
      heightMetric: 'Unknown',
      imageUrl: imageData['url'] as String?,
    );
  }

  Future<void> attachImages(List<Breed> breeds, {int? limit}) async {
    final target = limit == null ? breeds : breeds.take(limit).toList();

    await Future.wait(
      target.map((breed) async {
        if (breed.imageUrl != null) return;
        final imageUrl = await fetchBreedImage(breed.id);
        breed.imageUrl = imageUrl;
      }),
    );
  }
}

class StorageService {
  Future<void> cacheBreeds(List<Breed> breeds) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(breeds.map((breed) => breed.toJson()).toList());
    await prefs.setString(breedsCacheKey, encoded);
  }

  Future<List<Breed>> loadCachedBreeds() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(breedsCacheKey);
    if (cached == null) return [];

    final List<dynamic> jsonData = jsonDecode(cached);
    return jsonData.map((item) => Breed.fromCacheJson(item)).toList();
  }

  Future<void> saveFavoriteIds(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      favoritesCacheKey,
      ids.map((id) => id.toString()).toList(),
    );
  }

  Future<Set<int>> loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(favoritesCacheKey) ?? [];
    return ids.map(int.parse).toSet();
  }

  Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themeCacheKey, isDark);
  }

  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(themeCacheKey) ?? false;
  }
}
