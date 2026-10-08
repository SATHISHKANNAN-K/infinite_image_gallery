import 'image_model.dart';

class PagedImages {
  const PagedImages({
    required this.items,
    required this.totalHits,
  });

  final List<ImageModel> items;
  final int totalHits;
}
