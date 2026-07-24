import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/breed.dart';
import '../providers/app_providers.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class DetailScreen extends StatefulWidget {
  final Breed breed;

  const DetailScreen({super.key, required this.breed});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ApiService _apiService = ApiService();
  late Breed _breed;
  bool _loadingImage = false;

  @override
  void initState() {
    super.initState();
    _breed = widget.breed;
    if (_breed.imageUrl == null) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() => _loadingImage = true);
    final imageUrl = await _apiService.fetchBreedImage(_breed.id);
    if (!mounted) return;
    setState(() {
      _breed = _breed.copyWith(imageUrl: imageUrl);
      _loadingImage = false;
    });
  }

  Future<void> _shareBreed() async {
    await Share.share(
      'I discovered ${_breed.name} on DogFinder 🐶\nDownload DogFinder',
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavorite(_breed.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _breed.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _shareBreed,
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () => favorites.toggleFavorite(_breed.id),
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroImage(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _breed.bredFor.isNotEmpty
                        ? '${_breed.name} dogs are known for being ${_breed.bredFor.toLowerCase()}.'
                        : '${_breed.name} is a wonderful breed with a unique personality.',
                    style: const TextStyle(height: 1.5, fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Characteristics',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _breed.temperamentTags
                        .map(
                          (tag) => Chip(
                            avatar: const Icon(Icons.star, size: 16, color: AppColors.primary),
                            label: Text(tag),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  _InfoCard(
                    icon: Icons.monitor_weight_outlined,
                    title: 'Weight',
                    value: '${_breed.weightMetric} kg',
                  ),
                  _InfoCard(
                    icon: Icons.height,
                    title: 'Height',
                    value: '${_breed.heightMetric} cm',
                  ),
                  _InfoCard(
                    icon: Icons.schedule,
                    title: 'Life Span',
                    value: _breed.lifeSpan,
                  ),
                  _InfoCard(
                    icon: Icons.public,
                    title: 'Origin',
                    value: _breed.origin,
                  ),
                  _InfoCard(
                    icon: Icons.category_outlined,
                    title: 'Breed Group',
                    value: _breed.breedGroup,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      child: _breed.imageUrl == null
          ? Container(
              height: 320,
              color: Colors.grey.shade200,
              child: Center(
                child: _loadingImage
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.pets, size: 72, color: Colors.grey),
              ),
            )
          : CachedNetworkImage(
              imageUrl: _breed.imageUrl!,
              height: 320,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 320,
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 320,
                color: Colors.grey.shade200,
                child: const Icon(Icons.pets, size: 72, color: Colors.grey),
              ),
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
