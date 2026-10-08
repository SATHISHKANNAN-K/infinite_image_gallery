import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/image_model.dart';
import '../providers/gallery_provider.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({
    required this.image,
    required this.onTap,
    super.key,
  });

  final ImageModel image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GalleryProvider>();
    final favorite = provider.isFavorite(image.id);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'image-${image.id}',
              child: CachedNetworkImage(
                imageUrl: image.webformatUrl,
                fit: BoxFit.cover,
                memCacheWidth: 700,
                placeholder: (_, __) => const ColoredBox(
                  color: Color(0x12000000),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_outlined, size: 36),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => provider.toggleFavorite(image),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      favorite ? Icons.favorite : Icons.favorite_border,
                      color: favorite ? Colors.redAccent : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xcc000000),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 28, 10, 10),
                  child: Text(
                    image.tags.split(',').take(2).join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
