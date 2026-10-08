import '../models/paged_images.dart';
import '../services/pixabay_service.dart';

class ImageRepository {
  ImageRepository(this._service);

  final PixabayService _service;

  Future<PagedImages> search({
    required int page,
    required int perPage,
    String query = '',
    String category = '',
  }) {
    return _service.search(
      page: page,
      perPage: perPage,
      query: query,
      category: category,
    );
  }

  Future<List<int>> download(String url) => _service.download(url);
}
