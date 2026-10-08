import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/image_model.dart';
import '../models/paged_images.dart';

class PixabayException implements Exception {
  const PixabayException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PixabayService {
  PixabayService({
    required this.apiKey,
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String apiKey;
  final String baseUrl;
  final http.Client _client;

  Future<PagedImages> search({
    required int page,
    required int perPage,
    String query = '',
    String category = '',
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const PixabayException(
        'Pixabay API key is missing. Run the app with '
        '--dart-define=PIXABAY_API_KEY=YOUR_KEY',
      );
    }

    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'key': apiKey,
        'q': query.trim(),
        'page': '$page',
        'per_page': '$perPage',
        'image_type': 'photo',
        'safesearch': 'true',
        'order': 'popular',
        if (category.isNotEmpty) 'category': category.toLowerCase(),
      },
    );

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw PixabayException(
          'Image service returned HTTP ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const PixabayException('Invalid image service response.');
      }

      if (decoded['error'] != null) {
        throw PixabayException(decoded['error'].toString());
      }

      final hits = decoded['hits'];
      if (hits is! List) {
        throw const PixabayException('Image list is missing from the response.');
      }

      return PagedImages(
        items: hits
            .whereType<Map<String, dynamic>>()
            .map(ImageModel.fromJson)
            .toList(growable: false),
        totalHits: decoded['totalHits'] is num
            ? (decoded['totalHits'] as num).toInt()
            : 0,
      );
    } on PixabayException {
      rethrow;
    } catch (error) {
      throw const PixabayException(
        'Unable to load images. Check your connection and try again.',
      );
    }
  }

  Future<List<int>> download(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw PixabayException(
          'Image download failed with HTTP ${response.statusCode}.',
        );
      }

      return response.bodyBytes;
    } catch (error) {
      if (error is PixabayException) rethrow;
      throw const PixabayException(
        'Unable to download this image. Please try again.',
      );
    }
  }

  void dispose() => _client.close();
}
