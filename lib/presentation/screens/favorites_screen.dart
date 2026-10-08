import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/gallery_provider.dart';
import '../widgets/image_card.dart';
import 'image_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          Consumer<GalleryProvider>(
            builder: (context, provider, _) {
              if (provider.favorites.isEmpty) return const SizedBox.shrink();

              return IconButton(
                tooltip: 'Clear favorites',
                onPressed: () => _confirmClear(context),
                icon: const Icon(Icons.delete_outline),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<GalleryProvider>(
        builder: (context, provider, _) {
          final favorites = provider.favorites;

          if (favorites.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 64),
                    SizedBox(height: 14),
                    Text(
                      'No favorites yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tap the heart on any image to save it here.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final count = width >= 1100
                  ? 5
                  : width >= 800
                      ? 4
                      : width >= 560
                          ? 3
                          : 2;

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: favorites.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final image = favorites[index];

                  return ImageCard(
                    image: image,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ImageDetailScreen(image: image),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear favorites?'),
        content: const Text(
          'This removes all saved favorites from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<GalleryProvider>().clearFavorites();
    }
  }
}
