class ImageModel {
  const ImageModel({
    required this.id,
    required this.webformatUrl,
    required this.largeImageUrl,
    required this.previewUrl,
    required this.tags,
    required this.user,
    required this.userImageUrl,
    required this.likes,
    required this.views,
    required this.downloads,
    required this.comments,
    required this.imageWidth,
    required this.imageHeight,
    required this.pageUrl,
  });

  final int id;
  final String webformatUrl;
  final String largeImageUrl;
  final String previewUrl;
  final String tags;
  final String user;
  final String userImageUrl;
  final int likes;
  final int views;
  final int downloads;
  final int comments;
  final int imageWidth;
  final int imageHeight;
  final String pageUrl;

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: _int(json['id']),
      webformatUrl: _string(json['webformatURL']),
      largeImageUrl: _string(json['largeImageURL']),
      previewUrl: _string(json['previewURL']),
      tags: _string(json['tags']),
      user: _string(json['user']),
      userImageUrl: _string(json['userImageURL']),
      likes: _int(json['likes']),
      views: _int(json['views']),
      downloads: _int(json['downloads']),
      comments: _int(json['comments']),
      imageWidth: _int(json['imageWidth']),
      imageHeight: _int(json['imageHeight']),
      pageUrl: _string(json['pageURL']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'webformatURL': webformatUrl,
      'largeImageURL': largeImageUrl,
      'previewURL': previewUrl,
      'tags': tags,
      'user': user,
      'userImageURL': userImageUrl,
      'likes': likes,
      'views': views,
      'downloads': downloads,
      'comments': comments,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
      'pageURL': pageUrl,
    };
  }

  static int _int(dynamic value) => value is num ? value.toInt() : 0;
  static String _string(dynamic value) => value?.toString() ?? '';
}
