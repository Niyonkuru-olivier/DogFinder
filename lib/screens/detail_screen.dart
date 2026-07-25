import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/breed.dart';
import '../providers/app_providers.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/dog_image_widget.dart';

class DetailScreen extends StatefulWidget {
  final Breed breed;

  const DetailScreen({super.key, required this.breed});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ApiService _apiService = ApiService();
  late Breed _breed;

  @override
  void initState() {
    super.initState();
    _breed = widget.breed;
    if (_breed.imageUrl == null) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final imageUrl = await _apiService.fetchBreedImage(_breed.id);
    if (!mounted) return;
    if (imageUrl != null) {
      setState(() {
        _breed = _breed.copyWith(imageUrl: imageUrl);
      });
    }
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
            icon: const Icon(Icons.ios_share_rounded),
          ),
          IconButton(
            onPressed: () => favorites.toggleFavorite(_breed.id),
            icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
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
                            avatar: const Icon(Icons.stars_rounded, size: 16, color: AppColors.primary),
                            label: Text(tag),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  _InfoCard(
                    icon: Icons.scale_rounded,
                    title: 'Weight',
                    value: '${_breed.weightMetric} kg',
                  ),
                  _InfoCard(
                    icon: Icons.straighten_rounded,
                    title: 'Height',
                    value: '${_breed.heightMetric} cm',
                  ),
                  _InfoCard(
                    icon: Icons.timer_rounded,
                    title: 'Life Span',
                    value: _breed.lifeSpan,
                  ),
                  _InfoCard(
                    icon: Icons.public_rounded,
                    title: 'Origin',
                    value: _breed.origin,
                  ),
                  _InfoCard(
                    icon: Icons.grid_view_rounded,
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
      child: DogImageWidget(
        imageUrl: _breed.displayImageUrl,
        fallbackUrl: _breed.fallbackImageUrl,
        height: 320,
        width: double.infinity,
        fit: BoxFit.cover,
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
