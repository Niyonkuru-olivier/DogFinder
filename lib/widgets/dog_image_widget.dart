import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_theme.dart';

class DogImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String fallbackUrl;
  final double? height;
  final double? width;
  final BoxFit fit;

  const DogImageWidget({
    super.key,
    required this.imageUrl,
    required this.fallbackUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final targetUrl = (imageUrl != null && imageUrl!.trim().isNotEmpty)
        ? imageUrl!
        : fallbackUrl;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseShimmer = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightShimmer = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return CachedNetworkImage(
      imageUrl: targetUrl,
      height: height,
      width: width,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 200),
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: baseShimmer,
        highlightColor: highlightShimmer,
        child: Container(
          height: height ?? double.infinity,
          width: width ?? double.infinity,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) {
        if (targetUrl != fallbackUrl) {
          return Image.network(
            fallbackUrl,
            height: height,
            width: width,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(isDark),
          );
        }
        return _buildFallbackIcon(isDark);
      },
    );
  }

  Widget _buildFallbackIcon(bool isDark) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.darkSurface, Colors.grey.shade900]
              : [Colors.grey.shade200, Colors.grey.shade100],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.pets_rounded,
          size: 40,
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
      ),
    );
  }
}
