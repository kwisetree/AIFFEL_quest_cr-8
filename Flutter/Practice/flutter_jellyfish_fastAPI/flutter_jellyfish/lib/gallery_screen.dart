import 'package:flutter/material.dart';
import 'image_model.dart';
import 'gallery_service.dart';
import 'dart:typed_data';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<GalleryImage> _images = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final images = await GalleryService.getImages();
      setState(() {
        _images = images;
      });
    } catch (e) {
      // 오류 처리
      print('갤러리 이미지 로딩 실패: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이미지 갤러리'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadImages,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _images.isEmpty
              ? const Center(child: Text('저장된 이미지가 없습니다.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    final image = _images[index];
                    return _buildImageCard(image);
                  },
                ),
    );
  }

  Widget _buildImageCard(GalleryImage image) {
    return Card(
      clipBehavior: Clip.none, // 테두리를 둥글지 않게
      elevation: 2.0,
      color: Colors.white,
      child: InkWell(
        onTap: () => _showImageDetail(image),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.memory(
                image.imageData,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '날짜: ${_formatDate(image.timestamp)}',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (image.predictionLabel != null)
                    Text(
                      '종류: ${image.predictionLabel}',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showImageDetail(GalleryImage image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(_formatDate(image.timestamp)),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await GalleryService.deleteImage(image.id);
                    _loadImages();
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.memory(
                    image.imageData,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  if (image.predictionLabel != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('종류: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(image.predictionLabel ?? ''),
                      ],
                    ),
                    if (image.predictionScore != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('확률: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${(image.predictionScore! * 100).toStringAsFixed(2)}%'),
                        ],
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}