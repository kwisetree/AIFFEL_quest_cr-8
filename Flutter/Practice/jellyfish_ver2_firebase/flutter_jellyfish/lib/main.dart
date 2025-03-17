import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jellyfish_classifier/firebase_options.dart';
import 'gallery_screen.dart';
import 'gallery_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Flutter 바인딩 초기화 (Firebase 초기화 전에 필요)
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 기존 앱 실행 코드
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jellyfish Classifier',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const MyHomePage(),
    const GalleryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: '갤러리',
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String result = "";
  String? selectedImageUrl;
  Uint8List? imageBytes;
  bool isLoading = false;
  Map<String, dynamic>? predictionResult;

  // API URL - ngrok URL로 변경 필요
  final String apiUrl = "https://2ba8-125-241-205-143.ngrok-free.app";

  // 이미지 리사이징 헬퍼 함수
  Future<Uint8List> _resizeImageIfNeeded(Uint8List imageBytes) async {
    try {
      // 1MB 미만이면 리사이징 안함
      if (imageBytes.length < 1024 * 1024) {
        return imageBytes;
      }

      // Blob 생성
      final blob = html.Blob([imageBytes]);
      final url = html.Url.createObjectUrl(blob);
      
      // 이미지 로드
      final completer = Completer<html.ImageElement>();
      final imgElement = html.ImageElement();
      imgElement.src = url;
      imgElement.onLoad.listen((event) => completer.complete(imgElement));

      final loadedImg = await completer.future;
      
      // 새 크기 계산
      final int maxDimension = 1024;
      int width = loadedImg.width!;
      int height = loadedImg.height!;
      
      if (width > maxDimension || height > maxDimension) {
        if (width > height) {
          height = (height * maxDimension / width).round();
          width = maxDimension;
        } else {
          width = (width * maxDimension / height).round();
          height = maxDimension;
        }
      }
      
      // 캔버스 생성 및 그리기
      final canvas = html.CanvasElement(width: width, height: height);
      canvas.context2D.drawImageScaled(loadedImg, 0, 0, width, height);
      
      // URL 정리
      html.Url.revokeObjectUrl(url);
      
      // JPEG로 변환
      final dataUrl = canvas.toDataUrl('image/jpeg', 0.85);
      final byteString = html.window.atob(dataUrl.split(',')[1]);
      
      final buffer = Uint8List(byteString.length);
      for (var i = 0; i < byteString.length; i++) {
        buffer[i] = byteString.codeUnitAt(i);
      }
      
      print('이미지 리사이징: ${imageBytes.length} -> ${buffer.length} 바이트');
      return buffer;
    } catch (e) {
      print('이미지 리사이징 에러: $e');
      return imageBytes; // 에러 발생 시 원본 반환
    }
  }

  // 카메라로 이미지 캡쳐
  Future<void> captureImage() async {
    try {
      // HTML 요소 생성
      final cameraContainer = html.DivElement()
        ..style.position = 'fixed'
        ..style.top = '0'
        ..style.left = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = 'rgba(0, 0, 0, 0.8)'
        ..style.zIndex = '1000'
        ..style.display = 'flex'
        ..style.flexDirection = 'column'
        ..style.justifyContent = 'center'
        ..style.alignItems = 'center';

      final videoElement = html.VideoElement()
        ..style.width = '100%'
        ..style.maxWidth = '500px'
        ..style.backgroundColor = 'black'
        ..autoplay = true;

      final canvasElement = html.CanvasElement()
        ..style.display = 'none';

      final buttonContainer = html.DivElement()
        ..style.display = 'flex'
        ..style.margin = '20px';

      final captureButton = html.ButtonElement()
        ..text = '촬영'
        ..style.padding = '10px 20px'
        ..style.margin = '0 10px'
        ..style.backgroundColor = '#4CAF50'
        ..style.color = 'white'
        ..style.border = 'none'
        ..style.borderRadius = '5px'
        ..style.cursor = 'pointer';

      final cancelButton = html.ButtonElement()
        ..text = '취소'
        ..style.padding = '10px 20px'
        ..style.margin = '0 10px'
        ..style.backgroundColor = '#f44336'
        ..style.color = 'white'
        ..style.border = 'none'
        ..style.borderRadius = '5px'
        ..style.cursor = 'pointer';

      buttonContainer.children.addAll([captureButton, cancelButton]);
      cameraContainer.children.addAll([videoElement, buttonContainer]);
      
      html.document.body!.append(cameraContainer);

      // 카메라 액세스 요청
      final mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': true,
        'audio': false,
      });

      videoElement.srcObject = mediaStream;

      // 촬영 버튼 클릭 이벤트
      captureButton.onClick.listen((_) async {
        try {
          // 비디오 크기 설정
          canvasElement.width = videoElement.videoWidth;
          canvasElement.height = videoElement.videoHeight;

          // 비디오 프레임을 캔버스에 그리기
          canvasElement.context2D.drawImage(videoElement, 0, 0);
          
          // 더 작은 이미지 크기로 설정 (800px 너비)
          final targetWidth = 800;
          final targetHeight = (800 * canvasElement.height! / canvasElement.width!).round();
          
          final resizeCanvas = html.CanvasElement(
            width: targetWidth,
            height: targetHeight,
          );
          
          // 작은 크기로 그리기
          resizeCanvas.context2D.drawImageScaled(
            canvasElement, 
            0, 0, targetWidth, targetHeight
          );
          
          // JPEG 변환 (85% 품질)
          final dataUrl = resizeCanvas.toDataUrl('image/jpeg', 0.85);
          print('캡처된 이미지 크기(base64): ${dataUrl.length}');
          
          final byteString = html.window.atob(dataUrl.split(',')[1]);
          
          final buffer = Uint8List(byteString.length);
          for (var i = 0; i < byteString.length; i++) {
            buffer[i] = byteString.codeUnitAt(i);
          }

          // 트랙 정지 및 리소스 해제
          mediaStream.getTracks().forEach((track) => track.stop());
          
          // 카메라 UI 제거
          cameraContainer.remove();
          
          // 이미지 업데이트
          setState(() {
            imageBytes = buffer;
            selectedImageUrl = null;
            predictionResult = null;
            result = "";
          });
        } catch (e) {
          print('카메라 캡처 에러: $e');
          
          // 리소스 정리
          try {
            mediaStream.getTracks().forEach((track) => track.stop());
            cameraContainer.remove();
          } catch (_) {}
          
          setState(() {
            result = "카메라 에러: $e";
          });
        }
      });

      // 취소 버튼 클릭 이벤트
      cancelButton.onClick.listen((_) {
        mediaStream.getTracks().forEach((track) => track.stop());
        cameraContainer.remove();
      });
    } catch (e) {
      setState(() {
        result = "카메라 에러: $e";
      });
    }
  }

  // 이미지 업로드 처리
  void pickImage() {
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) async {
      if (uploadInput.files!.isEmpty) return;
      
      final file = uploadInput.files!.first;
      final reader = html.FileReader();
      
      reader.onLoadEnd.listen((event) async {
        if (reader.result == null) return;
        
        final bytes = reader.result as Uint8List;
        setState(() {
          imageBytes = bytes;
          selectedImageUrl = null;
          predictionResult = null;
          result = "";
        });
      });
      
      reader.readAsArrayBuffer(file);
    });
  }

  // 예측 API 호출
  Future<void> predictImage() async {
    if (imageBytes == null) {
      setState(() {
        result = "이미지를 먼저 선택해주세요.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      result = "분석 중...";
    });

    try {
      // 이미지 리사이징
      final optimizedImage = await _resizeImageIfNeeded(imageBytes!);
      print('API 전송 이미지 크기: ${optimizedImage.length} 바이트');
      
      // 이미지 파일 생성
      final uri = Uri.parse('$apiUrl/predict');
      var request = http.MultipartRequest('POST', uri);
      
      // 파일 첨부
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        optimizedImage,
        filename: 'image.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));

      // 요청 보내기
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        
        setState(() {
          predictionResult = responseData;
          isLoading = false;
        });
        
        // 갤러리에 저장 시도
        if (predictionResult != null && imageBytes != null) {
          try {
            String? label = predictionResult!['predicted_label'];
            double? score;
            
            if (predictionResult!['prediction_score'] != null) {
              score = double.parse(predictionResult!['prediction_score'].toString());
            }
            
            print('Firebase 저장 이미지 크기: ${optimizedImage.length} 바이트');
            
            await GalleryService.addImage(
              optimizedImage,
              predictionLabel: label,
              predictionScore: score,
            );
            
            setState(() {
              result = "이미지가 갤러리에 저장되었습니다.";
            });
          } catch (saveError) {
            setState(() {
              result = "갤러리 저장 실패: $saveError";
            });
          }
        }
      } else {
        setState(() {
          result = "오류 발생: ${response.statusCode} - ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        result = "Error: $e";
        isLoading = false;
      });
    }
  }

  // 확률 버튼 - 예측 확률 표시
  void showPredictionScore() {
    if (predictionResult == null) {
      setState(() {
        result = "먼저 이미지를 분석해주세요.";
      });
      return;
    }

    setState(() {
      result = "확률: ${predictionResult!['prediction_score']}";
    });
  }

  // 종류 버튼 - 예측된 클래스 표시
  void showPredictedLabel() {
    if (predictionResult == null) {
      setState(() {
        result = "먼저 이미지를 분석해주세요.";
      });
      return;
    }

    setState(() {
      result = "종류: ${predictionResult!['predicted_label']}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            'assets/icons/jelly.svg',
            height: 30,
            width: 30,
          ),
        ),
        title: const Text('Jellyfish Classifier'),
        centerTitle: true,
      ),
      body: Container(
        color: const Color.fromARGB(255, 191, 142, 231),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.black),
                ),
                child: imageBytes != null
                    ? Image.memory(imageBytes!, fit: BoxFit.contain)
                    : selectedImageUrl != null
                        ? Image.network(selectedImageUrl!, fit: BoxFit.contain)
                        : Image.network(
                            'https://fastly.picsum.photos/id/40/4106/2806.jpg?hmac=MY3ra98ut044LaWPEKwZowgydHZ_rZZUuOHrc3mL5mI',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => 
                                const Center(child: Text('이미지를 불러올 수 없습니다')),
                          ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text('이미지 선택'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: captureImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('카메라'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: predictImage,
                    child: const Text('분석하기'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: showPredictedLabel,
                    child: const Text('종류'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: showPredictionScore,
                    child: const Text('확률'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // 결과를 보여주기 위한 텍스트 위젯
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  color: Colors.white,
                ),
                child: Text(
                  result,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}