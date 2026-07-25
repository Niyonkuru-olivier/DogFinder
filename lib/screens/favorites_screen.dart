import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_providers.dart';
import '../providers/breed_provider.dart';
import '../widgets/breed_card.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final breeds = context.watch<BreedProvider>();
    final favoriteBreeds = favorites.favoriteBreeds(breeds.allBreeds);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: favoriteBreeds.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No favorite breeds yet',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 6),
                  Text('Tap the heart icon on any breed to save it here.'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              itemCount: favoriteBreeds.length,
              itemBuilder: (context, index) {
                final breed = favoriteBreeds[index];
                return BreedCard(
                  breed: breed,
                  index: index,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(breed: breed),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
