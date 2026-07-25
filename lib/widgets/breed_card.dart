import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/breed.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'dog_image_widget.dart';

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
                      elevation: 2,
                    ),
                    onPressed: () => favorites.toggleFavorite(breed.id),
                    icon: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 22,
                    ),
                  ).animate(target: isFavorite ? 1 : 0).scale(
                        duration: 200.ms,
                        curve: Curves.easeOutBack,
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
                    '🐶 ${breed.name}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (breed.temperament.isNotEmpty) ...[
                    Text(
                      breed.temperament,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _DetailMetric(
                        label: 'Life Span',
                        value: breed.lifeSpan,
                        icon: Icons.timer_rounded,
                      ),
                      _DetailMetric(
                        label: 'Weight',
                        value: '${breed.weightMetric} kg',
                        icon: Icons.scale_rounded,
                      ),
                      _DetailMetric(
                        label: 'Height',
                        value: '${breed.heightMetric} cm',
                        icon: Icons.straighten_rounded,
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
    return DogImageWidget(
      imageUrl: breed.displayImageUrl,
      fallbackUrl: breed.fallbackImageUrl,
      height: 210,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}


class _DetailMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
