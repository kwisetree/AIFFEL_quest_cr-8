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
  // 카메라에 접근하여 사진 촬영
  Future<void> captureImage() async {
    try {
      // HTML 요소 생성
      html.DivElement cameraContainer = html.DivElement()
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

      html.VideoElement videoElement = html.VideoElement()
        ..style.width = '100%'
        ..style.maxWidth = '500px'
        ..style.backgroundColor = 'black'
        ..autoplay = true;

      html.CanvasElement canvasElement = html.CanvasElement()
        ..style.display = 'none';

      html.DivElement buttonContainer = html.DivElement()
        ..style.display = 'flex'
        ..style.margin = '20px';

      html.ButtonElement captureButton = html.ButtonElement()
        ..text = '촬영'
        ..style.padding = '10px 20px'
        ..style.margin = '0 10px'
        ..style.backgroundColor = '#4CAF50'
        ..style.color = 'white'
        ..style.border = 'none'
        ..style.borderRadius = '5px'
        ..style.cursor = 'pointer';

      html.ButtonElement cancelButton = html.ButtonElement()
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
        // 비디오 크기 설정
        canvasElement.width = videoElement.videoWidth;
        canvasElement.height = videoElement.videoHeight;

        // 비디오 프레임을 캔버스에 그리기
        canvasElement.context2D.drawImage(videoElement, 0, 0);
        
        // 캔버스를 이미지로 변환
        final dataUrl = canvasElement.toDataUrl('image/png');
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
        
        // 카메라로 찍은 이미지는 분석 전까지 갤러리에 저장하지 않음
        // 분석 완료 후 predictImage() 메서드에서 저장
      });

      // 취소 버튼 클릭 이벤트
      cancelButton.onClick.listen((_) {
        // 트랙 정지 및 리소스 해제
        mediaStream.getTracks().forEach((track) => track.stop());
        
        // 카메라 UI 제거
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
        
        // 갤러리에 이미지 저장하는 코드 제거
        // 분석 시에만 저장하도록 predictImage() 메서드에서 처리
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
        
        // 분석 완료 후 갤러리에 이미지 저장 (예측 결과 포함)
        if (predictionResult != null && imageBytes != null) {
          String? label = predictionResult!['predicted_label'];
          double? score = predictionResult!['prediction_score'] != null
              ? double.parse(predictionResult!['prediction_score'].toString())
              : null;
              
          // 이미지를 갤러리에 저장
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