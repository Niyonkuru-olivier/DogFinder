import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/breed.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

class BreedCard extends StatelessWidget {
  final Breed breed;
  final int index;
  final VoidCallback? onTap;

  const BreedCard({
    super.key,
    required this.breed,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavorite(breed.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: _buildImage(),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.92),
                      foregroundColor: isFavorite ? Colors.red : AppColors.primary,
                    ),
                    onPressed: () => favorites.toggleFavorite(breed.id),
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    breed.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    breed.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.schedule,
                        label: breed.lifeSpan,
                      ),
                      if (breed.temperamentTags.isNotEmpty)
                        _InfoChip(
                          icon: Icons.psychology_outlined,
                          label: breed.temperamentTags.first,
                        ),
                      _InfoChip(
                        icon: Icons.monitor_weight_outlined,
                        label: '${breed.weightMetric} kg',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 60).ms)
        .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: (index * 60).ms);
  }

  Widget _buildImage() {
    if (breed.imageUrl == null) {
      return Container(
        height: 210,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return CachedNetworkImage(
      imageUrl: breed.imageUrl!,
      height: 210,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 210,
        color: Colors.grey.shade200,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        height: 210,
        color: Colors.grey.shade200,
        child: const Icon(Icons.pets, size: 48, color: Colors.grey),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
