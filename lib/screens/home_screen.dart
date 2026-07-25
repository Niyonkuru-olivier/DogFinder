import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_providers.dart';
import '../providers/breed_provider.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';
import '../widgets/breed_card.dart';
import '../widgets/dog_image_widget.dart';
import '../widgets/search_and_filters.dart';
import '../widgets/skeleton_loader.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<BreedProvider>().loadBreeds();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          appName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Dog Breed Identifier',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.identifier);
            },
            icon: const Icon(Icons.center_focus_strong_rounded),
          ),
          IconButton(
            tooltip: 'Compare breeds',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.compare);
            },
            icon: const Icon(Icons.compare_arrows_rounded),
          ),
          IconButton(
            tooltip: 'Favorites',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
            icon: const Icon(Icons.favorite_rounded),
          ),
          IconButton(
            tooltip: themeProvider.isDarkMode ? 'Light mode' : 'Dark mode',
            onPressed: themeProvider.toggleTheme,
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRandomDog(context),
        icon: const Icon(Icons.casino_rounded),
        label: const Text('Surprise Me'),
      ),
      body: Consumer<BreedProvider>(
        builder: (context, breedProvider, _) {
          return Column(
            children: [
              BreedSearchBar(
                controller: _searchController,
                onChanged: breedProvider.search,
                onClear: () {
                  _searchController.clear();
                  breedProvider.search('');
                },
              ),
              BreedFilterBar(
                activeFilter: breedProvider.activeFilter,
                onFilterSelected: breedProvider.setFilter,
              ),
              if (breedProvider.isOffline) const OfflineBanner(),
              if (!breedProvider.isLoading && breedProvider.errorMessage == null)
                StatsDashboard(
                  totalBreeds: breedProvider.totalBreeds,
                  averageLifeSpan: breedProvider.averageLifeSpan,
                  mostPopularGroup: breedProvider.mostPopularGroup,
                ),
              Expanded(child: _buildBody(breedProvider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BreedProvider breedProvider) {
    if (breedProvider.isLoading && breedProvider.visibleBreeds.isEmpty) {
      return const BreedListSkeleton();
    }

    if (breedProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                breedProvider.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: breedProvider.loadBreeds,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (breedProvider.visibleBreeds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No breeds found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your filter or search query.',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: breedProvider.refreshBreeds,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 100),
        itemCount: breedProvider.visibleBreeds.length + 1,
        itemBuilder: (context, index) {
          if (index == breedProvider.visibleBreeds.length) {
            return const AdoptionInfoCard();
          }

          final breed = breedProvider.visibleBreeds[index];
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

  Future<void> _showRandomDog(BuildContext context) async {
    final randomProvider = context.read<RandomDogProvider>();
    await randomProvider.fetchRandomDog();

    if (!context.mounted) return;

    final breed = randomProvider.randomBreed;
    if (breed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(randomProvider.errorMessage ?? 'Could not load random dog')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                breed.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: DogImageWidget(
                  imageUrl: breed.displayImageUrl,
                  fallbackUrl: breed.fallbackImageUrl,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                breed.shortDescription,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(breed: breed),
                    ),
                  );
                },
                child: const Text('View Details'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
