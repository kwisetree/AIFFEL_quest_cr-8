import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'image_model.dart';

class GalleryService {
  static const String _storageKey = 'jellyfish_gallery_images';
  
  // 이미지 목록 가져오기
  static Future<List<GalleryImage>> getImages() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> imagesJsonList = prefs.getStringList(_storageKey) ?? [];
    final List<GalleryImage> images = [];
    
    for (final imageJson in imagesJsonList) {
      try {
        final Map<String, dynamic> imageMap = jsonDecode(imageJson);
        
        // 이미지 데이터 가져오기
        final String imageDataKey = 'image_data_${imageMap['id']}';
        final String? base64Image = prefs.getString(imageDataKey);
        
        if (base64Image != null) {
          final Uint8List imageData = base64Decode(base64Image);
          final GalleryImage image = GalleryImage.fromJson(imageMap, imageData);
          images.add(image);
        }
      } catch (e) {
        print('Error loading image: $e');
      }
    }
    
    // 날짜 기준 내림차순 정렬 (최신순)
    images.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return images;
  }
  
  // 새 이미지 추가
  static Future<void> addImage(Uint8List imageData, {String? predictionLabel, double? predictionScore}) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> imagesJsonList = prefs.getStringList(_storageKey) ?? [];
    
    // 새 이미지 ID 생성 (타임스탬프 기반)
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    
    // 이미지 객체 생성
    final GalleryImage newImage = GalleryImage(
      id: id,
      timestamp: DateTime.now(),
      imageData: imageData,
      predictionLabel: predictionLabel,
      predictionScore: predictionScore,
    );
    
    // 이미지 메타데이터를 JSON으로 저장
    imagesJsonList.add(jsonEncode(newImage.toJson()));
    await prefs.setStringList(_storageKey, imagesJsonList);
    
    // 이미지 데이터를 별도로 저장 (Base64 인코딩)
    final String imageDataKey = 'image_data_$id';
    final String base64Image = base64Encode(imageData);
    await prefs.setString(imageDataKey, base64Image);
  }
  
  // 모든 이미지 삭제
  static Future<void> clearImages() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 기존 이미지 목록 가져오기
    final List<String> imagesJsonList = prefs.getStringList(_storageKey) ?? [];
    
    // 각 이미지 데이터 키 삭제
    for (final imageJson in imagesJsonList) {
      try {
        final Map<String, dynamic> imageMap = jsonDecode(imageJson);
        final String imageDataKey = 'image_data_${imageMap['id']}';
        await prefs.remove(imageDataKey);
      } catch (e) {
        print('Error removing image: $e');
      }
    }
    
    // 이미지 목록 삭제
    await prefs.remove(_storageKey);
  }
  
  // 특정 이미지 삭제
  static Future<void> deleteImage(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> imagesJsonList = prefs.getStringList(_storageKey) ?? [];
    
    // 이미지 메타데이터 삭제
    final List<String> updatedList = imagesJsonList.where((imageJson) {
      try {
        final Map<String, dynamic> imageMap = jsonDecode(imageJson);
        return imageMap['id'] != id;
      } catch (e) {
        return true; // 에러 발생 시 항목 유지
      }
    }).toList();
    
    await prefs.setStringList(_storageKey, updatedList);
    
    // 이미지 데이터 삭제
    final String imageDataKey = 'image_data_$id';
    await prefs.remove(imageDataKey);
  }
}