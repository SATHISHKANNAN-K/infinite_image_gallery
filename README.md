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