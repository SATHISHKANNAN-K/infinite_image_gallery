import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/image_model.dart';
import '../providers/gallery_provider.dart';

class ImageDetailScreen extends StatelessWidget {
  const ImageDetailScreen({
    required this.image,
    super.key,
  });

  final ImageModel image;

  Future<void> _download(BuildContext context) async {
    final provider = context.read<GalleryProvider>();
    final success = await provider.downloadImage(image);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Image saved to your gallery.'
              : 'Unable to save the image. Check gallery permission and try again.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _share() async {
    await SharePlus.instance.share(
      ShareParams(
        text: 'Check out this image by ${image.user}: ${image.largeImageUrl}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GalleryProvider>();
    final favorite = provider.isFavorite(image.id);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: favorite ? 'Remove favorite' : 'Add favorite',
            onPressed: () => provider.toggleFavorite(image),
            icon: Icon(
              favorite ? Icons.favorite : Icons.favorite_border,
              color: favorite ? Colors.redAccent : null,
            ),
          ),
          IconButton(
            tooltip: 'Share',
            onPressed: _share,
            icon: const Icon(Icons.share_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Hero(
              tag: 'image-${image.id}',
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: CachedNetworkImage(
                  imageUrl: image.largeImageUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const AspectRatio(
                    aspectRatio: 1,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => const AspectRatio(
                    aspectRatio: 1,
                    child: Center(
                      child: Icon(Icons.broken_image_outlined, size: 48),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            image.tags.isEmpty ? 'Image' : image.tags,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Photo by ${image.user}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(icon: Icons.favorite_outline, value: image.likes),
              _StatChip(icon: Icons.visibility_outlined, value: image.views),
              _StatChip(icon: Icons.download_outlined, value: image.downloads),
              _StatChip(icon: Icons.chat_bubble_outline, value: image.comments),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'A ${image.imageWidth} × ${image.imageHeight} image shared by ${image.user}. '
            'Tags: ${image.tags.isEmpty ? 'none' : image.tags}.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: provider.isDownloading ? null : () => _download(context),
            icon: provider.isDownloading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
            label: Text(
              provider.isDownloading ? 'Downloading...' : 'Download image',
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _share,
            icon: const Icon(Icons.share_outlined),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(_format(value)),
    );
  }

  String _format(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return '$value';
  }
}
