# Infinite Image Gallery

Flutter intermediate-level assessment implementation.

## Features

### Required
- Responsive image gallery using `GridView`
- Infinite scrolling / page-based pagination
- Loading, empty and error states
- Image detail screen
- Image description and metadata
- Download image to device gallery
- Favorite / unfavorite images
- Favorites screen
- Cached image loading and lightweight image performance optimizations

### Bonus
- Search
- Pull-to-refresh
- Category filters
- Hero animation
- Light / dark theme
- Share image
- Download progress indicator
- Unit tests
- Clean separation between API, repositories, state and UI

## Architecture

```text
lib/
├── core/
│   ├── constants/
│   └── theme/
├── data/
│   ├── models/
│   ├── services/
│   └── repositories/
├── presentation/
│   ├── providers/
│   ├── screens/
│   └── widgets/
└── main.dart
```

The UI talks to `GalleryProvider`. The provider talks to `ImageRepository`.
`ImageRepository` talks to the Pixabay HTTP service. Favorites are persisted with
SharedPreferences, while downloads are handled by the Gal gallery package.

## API configuration

This project uses Pixabay, as recommended by the assessment.

Create a Pixabay API key from your Pixabay developer account.

Run:

```bash
flutter pub get
flutter run --dart-define=PIXABAY_API_KEY=YOUR_PIXABAY_KEY
```

For a release build:

```bash
flutter build apk --release --dart-define=PIXABAY_API_KEY=YOUR_PIXABAY_KEY
```

The app also supports:

```bash
flutter run --dart-define=PIXABAY_API_KEY=YOUR_PIXABAY_KEY --dart-define=PIXABAY_BASE_URL=https://pixabay.com/api/
```

Never commit a real API key to source control.

## Android / iOS

The `gal` package is used to save downloaded images to the device gallery and
handles the platform-specific gallery access flow.

For iOS, make sure the generated app's `Info.plist` contains the photo-library
usage descriptions required by the version of `gal` being used. For Android,
the package uses the appropriate MediaStore/gallery mechanism for modern Android.

## Run tests

```bash
flutter test
```

## Assumptions / limitations

- Pixabay requires an API key and rate limits requests.
- Pagination uses Pixabay's page/per-page API parameters.
- Favorites store the image metadata locally, not the full image file.
- Downloaded images are saved to the device gallery rather than the app's private
  documents directory.
- If the API key is missing, the app shows a clear configuration error.
- The app intentionally keeps the API layer provider-neutral so another legally
  suitable image API can be substituted later.

## Suggested screenshots for submission

1. Home gallery with search and category chips.
2. Image detail screen.
3. Favorites screen.
4. Download success / progress state.
