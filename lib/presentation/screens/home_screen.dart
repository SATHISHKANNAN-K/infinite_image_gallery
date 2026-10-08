import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../providers/gallery_provider.dart';
import '../widgets/image_card.dart';
import 'favorites_screen.dart';
import 'image_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showThemePicker() async {
    final provider = context.read<GalleryProvider>();

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ThemeOption(
                title: 'System default',
                mode: ThemeMode.system,
                selected: provider.themeMode == ThemeMode.system,
              ),
              _ThemeOption(
                title: 'Light',
                mode: ThemeMode.light,
                selected: provider.themeMode == ThemeMode.light,
              ),
              _ThemeOption(
                title: 'Dark',
                mode: ThemeMode.dark,
                selected: provider.themeMode == ThemeMode.dark,
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.appName,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Theme',
            onPressed: _showThemePicker,
            icon: const Icon(Icons.brightness_6_outlined),
          ),
          IconButton(
            tooltip: 'Favorites',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FavoritesScreen(),
                ),
              );
            },
            icon: const Icon(Icons.favorite_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: context.read<GalleryProvider>().refresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(searchController: _searchController)),
            const SliverToBoxAdapter(child: _CategoryList()),
            const _GalleryGrid(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GalleryProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover something beautiful',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Search, explore and save images you love.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: provider.searchImages,
            decoration: InputDecoration(
              hintText: 'Search images...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  searchController.clear();
                  provider.searchImages('');
                },
                icon: const Icon(Icons.close),
              ),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList();

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, provider, _) {
        final selected = provider.category.isEmpty ? 'All' : provider.category;

        return SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = AppConstants.categories[index];

              return ChoiceChip(
                label: Text(category),
                selected: selected == category,
                onSelected: (_) => provider.setCategory(category),
              );
            },
          ),
        );
      },
    );
  }
}

class _GalleryGrid extends StatelessWidget {
  const _GalleryGrid();

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, provider, _) {
        if (provider.status == GalleryStatus.loading && provider.images.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.status == GalleryStatus.error && provider.images.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _ErrorState(
              message: provider.errorMessage,
              onRetry: provider.loadInitial,
            ),
          );
        }

        if (provider.images.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text('No images found. Try another search.'),
            ),
          );
        }

        return SliverLayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.crossAxisExtent;
            final count = width >= 1100
                ? 5
                : width >= 800
                    ? 4
                    : width >= 560
                        ? 3
                        : 2;

            return SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid.builder(
                itemCount: provider.images.length + (provider.hasMore ? 1 : 0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  if (index == provider.images.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final image = provider.images[index];

                  if (index >= provider.images.length - 6) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        context.read<GalleryProvider>().loadMore();
                      }
                    });
                  }

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
              ),
            );
          },
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 54),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.title,
    required this.mode,
    required this.selected,
  });

  final String title;
  final ThemeMode mode;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: () {
        context.read<GalleryProvider>().setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }
}
