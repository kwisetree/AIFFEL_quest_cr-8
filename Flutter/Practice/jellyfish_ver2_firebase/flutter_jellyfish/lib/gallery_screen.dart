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
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final images = await GalleryService.getImages();
      
      if (!mounted) return;
      
      setState(() {
        _images = images;
        _isLoading = false;
      });
    } catch (e) {
      print('갤러리 이미지 로딩 실패: $e');
      
      if (!mounted) return;
      
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
      clipBehavior: Clip.antiAlias,
      elevation: 2.0,
      color: Colors.white,
      child: InkWell(
        onTap: () => _showImageDetail(image),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: image.imageUrl != null && image.imageUrl!.isNotEmpty
                  ? Image.network(
                      image.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          const Center(child: Text('이미지 로드 오류')),
                    )
                  : const Center(child: Text('이미지 없음')),
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
                  image.imageUrl != null && image.imageUrl!.isNotEmpty
                      ? Image.network(
                          image.imageUrl!,
                          height: 300,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => 
                              const Text('이미지 로드 실패'),
                        )
                      : const Text('이미지를 찾을 수 없습니다.'),
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