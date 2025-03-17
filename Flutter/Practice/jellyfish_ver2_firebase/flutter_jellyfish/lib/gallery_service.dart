import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'image_model.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class GalleryService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _imagesCollection = 
      _firestore.collection('jellyfish_images');
  
  // 이미지 목록 가져오기
  static Future<List<GalleryImage>> getImages() async {
    try {
      // Firestore에서 메타데이터 가져오기
      final snapshot = await _imagesCollection
          .orderBy('timestamp', descending: true)
          .get();
      
      final List<GalleryImage> images = [];
      
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final String imageId = doc.id;
          
          String imageUrl = '';
          try {
            imageUrl = await _storage.ref('images/$imageId.jpg').getDownloadURL();
          } catch (error) {
            print('이미지 URL 가져오기 실패: $error');
          }
          
          final timestamp = data['timestamp'] != null 
              ? (data['timestamp'] as Timestamp).toDate() 
              : DateTime.now();
          
          final GalleryImage image = GalleryImage(
            id: imageId,
            timestamp: timestamp,
            imageUrl: imageUrl,
            predictionLabel: data['predictionLabel'],
            predictionScore: data['predictionScore'],
            imageData: Uint8List(0),
          );
          
          images.add(image);
        } catch (e) {
          print('이미지 처리 중 오류: $e');
        }
      }
      
      return images;
    } catch (e) {
      print('이미지 로딩 에러: $e');
      return [];
    }
  }
  
  // 새 이미지 추가
  static Future<void> addImage(Uint8List imageData, 
      {String? predictionLabel, double? predictionScore}) async {
    try {
      // 고유 ID 생성
      final String imageId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // 1. Storage에 이미지 업로드
      final ref = _storage.ref('images/$imageId.jpg');
      await ref.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // 2. Firestore에 메타데이터 저장
      final Map<String, dynamic> firestoreData = {
        'timestamp': FieldValue.serverTimestamp(),
        'predictionLabel': predictionLabel ?? "",
      };
      
      if (predictionScore != null) {
        firestoreData['predictionScore'] = predictionScore;
      }
      
      await _imagesCollection.doc(imageId).set(firestoreData);
      
    } catch (e) {
      print('이미지 저장 에러: $e');
      throw e;
    }
  }
  
  // 이미지 삭제
  static Future<void> deleteImage(String id) async {
    try {
      // 1. Firestore에서 메타데이터 삭제
      await _imagesCollection.doc(id).delete();
      
      // 2. Storage에서 이미지 삭제
      try {
        await _storage.ref('images/$id.jpg').delete();
      } catch (e) {
        print('Storage 이미지 삭제 실패: $e');
        // Continue anyway
      }
    } catch (e) {
      print('이미지 삭제 에러: $e');
      throw e;
    }
  }
}