import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/image_repository.dart';
import 'data/services/pixabay_service.dart';
import 'presentation/providers/gallery_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const apiKey = String.fromEnvironment(
    'PIXABAY_API_KEY',
    defaultValue: '57934447-17e8f606226eee1279e941422',
  );
  const baseUrl = String.fromEnvironment(
    'PIXABAY_BASE_URL',
    defaultValue: 'https://pixabay.com/api/',
  );

  final service = PixabayService(
    apiKey: apiKey,
    baseUrl: baseUrl,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => GalleryProvider(
        repository: ImageRepository(service),
      )..initialize(),
      child: const GalleryApp(),
    ),
  );
}

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Infinite Gallery',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: provider.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
