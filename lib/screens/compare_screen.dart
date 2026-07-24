import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/breed.dart';
import '../providers/app_providers.dart';
import '../providers/breed_provider.dart';
import '../theme/app_theme.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final compareProvider = context.watch<CompareProvider>();
    final breedProvider = context.watch<BreedProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compare Dogs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (compareProvider.firstBreed != null || compareProvider.secondBreed != null)
            TextButton(
              onPressed: compareProvider.clear,
              child: const Text('Clear', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              compareProvider.isReady
                  ? 'Side-by-side comparison'
                  : 'Select two breeds below to compare them.',
              style: const TextStyle(fontSize: 15),
            ),
          ),
          if (compareProvider.isReady)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _CompareCard(breed: compareProvider.firstBreed!),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CompareCard(breed: compareProvider.secondBreed!),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: breedProvider.allBreeds.length,
              itemBuilder: (context, index) {
                final breed = breedProvider.allBreeds[index];
                final selected = compareProvider.firstBreed?.id == breed.id ||
                    compareProvider.secondBreed?.id == breed.id;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(breed.name.isNotEmpty ? breed.name[0] : '?'),
                  ),
                  title: Text(breed.name),
                  subtitle: Text(breed.lifeSpan),
                  trailing: selected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : const Icon(Icons.add_circle_outline),
                  onTap: () => compareProvider.selectBreed(breed),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareCard extends StatelessWidget {
  final Breed breed;

  const _CompareCard({required this.breed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (breed.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: breed.imageUrl!,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.pets),
            ),
          const SizedBox(height: 10),
          Text(
            breed.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _CompareRow(label: 'Life', value: breed.lifeSpan),
          _CompareRow(label: 'Weight', value: '${breed.weightMetric} kg'),
          _CompareRow(label: 'Energy', value: breed.isActive ? 'High' : 'Moderate'),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final String value;

  const _CompareRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
