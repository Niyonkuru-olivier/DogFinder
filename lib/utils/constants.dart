const String apiKey =
    'live_ORspNh4WaXJBSeMkUUNdGvVbUQldTbDGbxh4N9AcsxPOh43Yzlu1PlhhdIMXeuHW';

const String breedsUrl = 'https://api.thedogapi.com/v1/breeds';
const String imagesUrl = 'https://api.thedogapi.com/v1/images/search';

const String appName = 'DogFinder';
const String appTagline = 'Discover amazing dog breeds';

const int imageBatchSize = 12;

const String breedsCacheKey = 'cached_breeds_v1';
const String favoritesCacheKey = 'favorite_breed_ids';
const String themeCacheKey = 'is_dark_mode';

enum BreedFilter {
  all,
  small,
  medium,
  large,
  family,
}

extension BreedFilterLabel on BreedFilter {
  String get label {
    switch (this) {
      case BreedFilter.all:
        return 'All';
      case BreedFilter.small:
        return 'Small Dogs';
      case BreedFilter.medium:
        return 'Medium Dogs';
      case BreedFilter.large:
        return 'Large Dogs';
      case BreedFilter.family:
        return 'Family Dogs';
    }
  }

  String get emoji {
    switch (this) {
      case BreedFilter.all:
        return '🐶';
      case BreedFilter.small:
        return '🐕';
      case BreedFilter.medium:
        return '🐩';
      case BreedFilter.large:
        return '🐕🦺';
      case BreedFilter.family:
        return '👨‍👩‍👧';
    }
  }
}
