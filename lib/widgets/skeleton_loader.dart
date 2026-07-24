import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BreedCardSkeleton extends StatelessWidget {
  const BreedCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    final highlightColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 210,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 18, width: 180, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 14, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 14, width: 220, color: Colors.white),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(height: 28, width: 90, color: Colors.white),
                      const SizedBox(width: 8),
                      Container(height: 28, width: 90, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BreedListSkeleton extends StatelessWidget {
  const BreedListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 100),
      itemCount: 4,
      itemBuilder: (context, index) => const BreedCardSkeleton(),
    );
  }
}
