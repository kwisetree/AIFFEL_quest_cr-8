// 네트워크와 CORS 설정의 중요성을 체험할 수 있었다.
// FlutLab.io 애뮬레이터에서 “XMLHttpRequest error”가 발생함으로써, 작은 설정 하나가 큰 에러로 이어질 수 있다는 점을 깨닫고 네트워크 요청 및 CORS 설정의 중요성을 배울 수 있었다.

// 시스템 간 연결 확인의 필요성을 깨달을 수 있었다.
// FastAPI 서버는 정상적으로 작동함에도 불구하고, LMS Jupyter와 Firefox 사이에서 “Unable to Connect” 오류가 나타나면서, 각 시스템의 설정과 호환성을 꼼꼼히 확인하는 방법을 익힐 수 있었다.

// 대용량 파일 다운로드 관리의 중요성을 실감할 수 있었다.
// vgg16 모델 다운로드가 중간에 끊기는 문제를 경험하면서, 안정적인 다운로드 방법과 에러 핸들링, 그리고 재시도 로직 마련의 필요성을 배울 수 있었다.

// URL 매핑과 포워딩 문제 해결의 중요성을 깨달을 수 있었다.
// 내부 FastAPI URL과 포워딩 링크가 일치하지 않아 발생한 문제를 통해, URL 설정과 리버스 프록시 같은 네트워크 라우팅 부분을 정확하게 맞추는 방법을 터득할 수 있었다.

// 엔드포인트 정의의 정확성을 다시 확인할 수 있었다.
// “GET /sample” 요청 시 반복적으로 404 Not Found 오류가 발생한 경험으로, FastAPI에서 엔드포인트를 올바르게 정의하고 라우팅하는 것이 얼마나 중요한지 재확인할 수 있었다.

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter_svg/flutter_svg.dart';

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
      home: MyHomePage(),
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
  Map<String, dynamic>? predictionResult; // 예측 결과 저장용 변수 추가

  // API URL - ngrok URL로 변경 필요
  final String apiUrl = "https://YOUR_NGROK_URL";

  // 이미지 업로드 처리
  void pickImage() {
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files!.first;
      final reader = html.FileReader();
      
      reader.onLoadEnd.listen((event) {
        setState(() {
          imageBytes = reader.result as Uint8List;
          selectedImageUrl = null;
          // 새 이미지를 선택하면 이전 예측 결과 초기화
          predictionResult = null;
          result = "";
        });
      });
      
      reader.readAsArrayBuffer(file);
    });
  }

  // 예측 API 호출 - 분석 버튼용
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
          predictionResult = data; // 예측 결과 저장
          result = ""; // 분석 버튼은 결과를 표시하지 않음
          isLoading = false;
        });
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              'assets/icons/cute_jellyfish.svg',
              height: 30,
              width: 30,
            ),
          ),
          title: const Text('Jellyfish Classifier'),
          centerTitle: true,
        ),
        body: Container(
          color: const Color(0xFFFFFF99),
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
                    ElevatedButton(
                      onPressed: pickImage,
                      child: const Text('이미지 선택'),
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
      ),
    );
  }
}
