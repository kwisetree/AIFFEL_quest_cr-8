import 'dart:typed_data';
/* */
class GalleryImage {
  final String id;
  final DateTime timestamp;
  final Uint8List imageData;
  final String? imageUrl;
  final String? predictionLabel;
  final double? predictionScore;

  GalleryImage({
    required this.id,
    required this.timestamp,
    required this.imageData,
    this.imageUrl,
    this.predictionLabel,
    this.predictionScore,
  });

  // JSON 변환을 위한 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'predictionLabel': predictionLabel,
      'predictionScore': predictionScore,
    };
  }

  // JSON에서 객체 생성을 위한 팩토리 메서드
  factory GalleryImage.fromJson(Map<String, dynamic> json, Uint8List imageData) {
    return GalleryImage(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      imageData: imageData,
      imageUrl: json['imageUrl'],
      predictionLabel: json['predictionLabel'],
      predictionScore: json['predictionScore'] != null
          ? double.parse(json['predictionScore'].toString())
          : null,
    );
  }
}