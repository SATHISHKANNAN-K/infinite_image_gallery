import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/image_model.dart';
import '../../data/repositories/image_repository.dart';

enum GalleryStatus { idle, loading, refreshing, loadingMore, success, error }

class GalleryProvider extends ChangeNotifier {
  GalleryProvider({required ImageRepository repository})
      : _repository = repository;

  final ImageRepository _repository;

  static const _favoritesKey = 'favorite_images';
  static const _themeKey = 'theme_mode';

  GalleryStatus status = GalleryStatus.idle;
  final List<ImageModel> images = [];
  final Map<int, ImageModel> _favorites = {};

  String errorMessage = '';
  String query = '';
  String category = '';
  int currentPage = 0;
  int totalHits = 0;
  bool hasMore = true;
  bool isDownloading = false;
  int? downloadingId;
  ThemeMode themeMode = ThemeMode.system;

  List<ImageModel> get favorites => _favorites.values.toList(growable: false);

  bool isFavorite(int id) => _favorites.containsKey(id);

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();

    final rawFavorites = preferences.getStringList(_favoritesKey) ?? [];
    for (final raw in rawFavorites) {
      try {
        final map = jsonDecode(raw);
        if (map is Map<String, dynamic>) {
          final image = ImageModel.fromJson(map);
          _favorites[image.id] = image;
        }
      } catch (_) {
        // Ignore a corrupted individual favorite and keep the rest.
      }
    }

    final savedTheme = preferences.getString(_themeKey);
    themeMode = switch (savedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    notifyListeners();
    await loadInitial();
  }

  Future<void> loadInitial() async {
    currentPage = 0;
    totalHits = 0;
    hasMore = true;
    images.clear();
    errorMessage = '';
    status = GalleryStatus.loading;
    notifyListeners();

    try {
      final result = await _repository.search(
        page: 1,
        perPage: AppConstants.defaultPerPage,
        query: query,
        category: category,
      );

      images.addAll(result.items);
      currentPage = 1;
      totalHits = result.totalHits;
      hasMore = result.items.isNotEmpty &&
          images.length < totalHits &&
          result.items.length == AppConstants.defaultPerPage;
      status = GalleryStatus.success;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      status = GalleryStatus.error;
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    if (status == GalleryStatus.loading) return;

    status = GalleryStatus.refreshing;
    notifyListeners();

    try {
      final result = await _repository.search(
        page: 1,
        perPage: AppConstants.defaultPerPage,
        query: query,
        category: category,
      );

      images
        ..clear()
        ..addAll(result.items);

      currentPage = 1;
      totalHits = result.totalHits;
      hasMore = result.items.isNotEmpty &&
          images.length < totalHits &&
          result.items.length == AppConstants.defaultPerPage;
      errorMessage = '';
      status = GalleryStatus.success;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      status = GalleryStatus.error;
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!hasMore ||
        status == GalleryStatus.loading ||
        status == GalleryStatus.loadingMore ||
        status == GalleryStatus.refreshing) {
      return;
    }

    status = GalleryStatus.loadingMore;
    notifyListeners();

    try {
      final nextPage = currentPage + 1;
      final result = await _repository.search(
        page: nextPage,
        perPage: AppConstants.defaultPerPage,
        query: query,
        category: category,
      );

      if (result.items.isEmpty) {
        hasMore = false;
      } else {
        images.addAll(result.items);
        currentPage = nextPage;
        totalHits = result.totalHits;
        hasMore = images.length < totalHits &&
            result.items.length == AppConstants.defaultPerPage;
      }

      status = GalleryStatus.success;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      status = GalleryStatus.success;
    }

    notifyListeners();
  }

  Future<void> searchImages(String value) async {
    query = value.trim();
    await loadInitial();
  }

  Future<void> setCategory(String value) async {
    category = value == 'All' ? '' : value;
    await loadInitial();
  }

  Future<void> toggleFavorite(ImageModel image) async {
    if (_favorites.containsKey(image.id)) {
      _favorites.remove(image.id);
    } else {
      _favorites[image.id] = image;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _favoritesKey,
      _favorites.values.map((item) => jsonEncode(item.toJson())).toList(),
    );

    notifyListeners();
  }

  Future<void> clearFavorites() async {
    _favorites.clear();
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_favoritesKey);
    notifyListeners();
  }

  Future<bool> downloadImage(ImageModel image) async {
    if (isDownloading) return false;

    isDownloading = true;
    downloadingId = image.id;
    notifyListeners();

    try {
      final bytes = await _repository.download(image.largeImageUrl);

      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        await Gal.requestAccess(toAlbum: true);
      }

      await Gal.putImageBytes(
        Uint8List.fromList(bytes),
        album: AppConstants.appName,
      );

      return true;
    } catch (_) {
      return false;
    } finally {
      isDownloading = false;
      downloadingId = null;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _themeKey,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    );

    notifyListeners();
  }
}
