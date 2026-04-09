class Photo {
  final int id;
  final int albumId;
  final String title;
  final String url;
  final String thumbnailUrl;

  Photo({
    required this.id,
    required this.albumId,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      albumId: json['albumId'],
      title: json['title'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  /// Album number used as a display label (e.g. "Album 1")
  String get albumLabel => 'Album $albumId';

  /// Reliable image from picsum.photos using the photo id as seed
  String get reliableImageUrl => 'https://picsum.photos/seed/$id/300/300';
}
