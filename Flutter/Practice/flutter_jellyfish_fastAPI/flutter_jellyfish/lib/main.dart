import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'gallery_screen.dart';
import 'gallery_service.dart';

void main() {
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
        items: [
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
  Map<String, dynamic>? predictionResult; // 예측 결과 저장용 변수

  // API URL - ngrok URL로 변경 필요
  final String apiUrl = "https://18da-125-241-205-143.ngrok-free.app";
  final ImagePicker _picker = ImagePicker();

  // 카메라로 이미지 캡쳐
  Future<void> captureImage() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          imageBytes = bytes;
          selectedImageUrl = null;
          predictionResult = null;
          result = "";
        });
        
        // 갤러리에 이미지 저장
        await GalleryService.addImage(bytes);
      }
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
      final file = uploadInput.files!.first;
      final reader = html.FileReader();
      
      reader.onLoadEnd.listen((event) async {
        final bytes = reader.result as Uint8List;
        setState(() {
          imageBytes = bytes;
          selectedImageUrl = null;
          predictionResult = null;
          result = "";
        });
        
        // 갤러리에 이미지 저장
        await GalleryService.addImage(bytes);
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
      // 이미지 파일 생성
      final uri = Uri.parse('$apiUrl/predict');
      var request = http.MultipartRequest('POST', uri);
      
      // 파일 첨부
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes!,
        filename: 'image.jpg',
      ));

      // 요청 보내기
      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseString);
        setState(() {
          predictionResult = data;
          result = ""; // 결과를 초기화 (버튼으로 확인하도록)
          isLoading = false;
        });
        
        // 갤러리 이미지 업데이트 (예측 결과 포함)
        if (predictionResult != null) {
          String? label = predictionResult!['predicted_label'];
          double? score = predictionResult!['prediction_score'] != null
              ? double.parse(predictionResult!['prediction_score'].toString())
              : null;
              
          // 새 이미지로 저장 (원래는 기존 이미지 업데이트 기능이 필요하지만 간단하게 구현)
          await GalleryService.addImage(
            imageBytes!,
            predictionLabel: label,
            predictionScore: score,
          );
        }
      } else {
        setState(() {
          result = "오류 발생: ${response.statusCode}";
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
                            'https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FxxXTR%2FbtsICmL1hJf%2FQ9nUBkmaMCDW12y0oZrZ5k%2Fimg.png',
                            fit: BoxFit.contain,
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