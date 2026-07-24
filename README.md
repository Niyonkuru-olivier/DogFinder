# DogFinder Pro

DogFinder is a Flutter mobile app that helps users discover dog breeds, learn their characteristics, save favorites, compare breeds, and explore random dogs using [The Dog API](https://thedogapi.com/).

## Features

- Animated splash screen with branding
- Breed list with images, temperament, life span, and weight
- Live breed search
- Filters for small, medium, large, active, and family-friendly dogs
- Detailed breed screen with characteristics and share support
- Favorites saved locally with SharedPreferences
- Random dog generator ("Surprise Me")
- Side-by-side breed comparison
- Light and dark mode
- Smooth card animations and skeleton loading
- Offline support with cached breed data
- Dog statistics dashboard
- Responsible dog ownership tips

## Tech Stack

- Flutter
- Provider for state management
- HTTP for API calls
- Cached Network Image for image loading
- Shared Preferences for offline caching and favorites
- Flutter Animate and Shimmer for UI polish
- Share Plus for sharing breeds

## Project Structure

```text
lib/
├── models/
├── providers/
├── routes/
├── screens/
├── services/
├── theme/
├── utils/
├── widgets/
└── main.dart
```

## Getting Started

1. Install Flutter SDK
2. Run `flutter pub get`
3. Run `flutter run`

## API

This app uses The Dog API:

- `GET /v1/breeds`
- `GET /v1/breeds/search?q=...`
- `GET /v1/images/search?breed_id=...`

The API key is configured in `lib/utils/constants.dart`.

## Screenshots

Add screenshots here before submission:

- Splash screen
- Home screen with search and filters
- Breed details
- Favorites
- Compare breeds
- Dark mode

## Notes

This project was built as a Dog Discovery App rather than a simple image viewer, with emphasis on UX, API usage, offline support, and clean architecture.
