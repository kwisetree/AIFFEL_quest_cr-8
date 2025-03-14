
import 'package:flutter/material.dart'; // 기본 패키지 불러오기

'''
이혜승 회고:
- 지난번보다 과제가 간단해서 시간에 쫒기지 않고 작업할 수 있었다.
- 지난 퀘스트에도 주호님과 페어프로그래밍 퀘스트를 함께 했었는데,이번에도 팀으로 만나서 협업 방식을 개선할 수 있었다.
- 예를 들면, 코드를 짜기 전에 구조를 같이 세워보는 방식을 주호님이 먼저 제안해주셔서 생각을 정리하는데 도움이 되었다.
- 시간적인 여유가 생기니 여러가지 기능을 더해보고 싶은 욕심이 들었지만 퀘스트 요구사항을 해치지 않기 위해 참았다.
- TIP: 고양이 발바닥을 누르면 주호님이 구현하신 화면과 제가 구현한 화면을 번갈아 확인하실 수 있어요!
- 두 사람의 코드를 하나로 보여주기 위해: bool 로 화면 전환 상태값을 설정해주고 토글함수로 body 부분만 따로 위젯을 만들어 변경해주었다.

천주호 회고:
- 처음엔 어려워 보였다가 혜승님과함께 아웃라인을 잡았을때는 쉬워보였다가 막상 다시 들어가니, 디버깅 과정에서 꼬였습니다
- 처음에 만들때 제대로 만들어 야지 나중에 수정하다보니 꼬이게 되고 ai의 도움을 받아도 더 코드가 꼬이게 되는 이상한 경험을 하게되었습니다
- 간단해 보여도 만만치 않다는걸 느끼고 더 공부해야겠다 생각했습니다

디버깅 흔적:
// class TestStack extends StatelessWidget {
//   // 클래스
//   const TestStack();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Stack(
//           alignment: Alignment.center, // 스택의 자식들을 중앙 정렬
//           children: [
//             Container(width: 300, height: 300, color: Colors.red),
//             Container(width: 240, height: 240, color: Colors.blue),
//             Container(width: 180, height: 180, color: Colors.green),
//             Container(width: 120, height: 120, color: Colors.yellow),
//             Container(width: 60, height: 60, color: Colors.purple),
//           ],
//         ),
//       ),
//     );
//   }
// }
'''


void main() => runApp(MyApp()); // main 함수로 진입점 표시, MyApp 구동

class MyApp extends StatefulWidget {
  // MyApp을 StatefulWidget 상속받아 만들고 state 객체 생성
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // State 객체 정의
  bool isSecondPage = false; //현재 화면 상태 변수

  void togglePage() {
    setState(() {
      isSecondPage = !isSecondPage; // 두번째 페이지로 토글할 수 있게 세팅
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFFFAF6F0),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.pets, size: 20),
            onPressed: togglePage,
          ),
          backgroundColor: Color(0xFFBFECFF), // 배경색: blue
          title: Center(child: Text('플러터 앱 만들기')), // 중앙 정렬로 제목 입력
        ),
        // 본문 body: isSecondPage 값에 따라 전환
        body: isSecondPage ? secondBody() : firstBody(), // 바디 페이지 바꾸기
      ), //Scaffold
    );
  } //build

  // 첫 번째 바디
  Widget firstBody() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: ElevatedButton(
              child: Text(
                "이혜승",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              onPressed: () {
                print("버튼이 눌렸습니다.");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFBFECFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // 직사각형 모양
                ),
              ), //버튼 스타일
            ),
          ),
        ),
        Stack(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 50),
              alignment: Alignment(0, 0),
              width: 300,
              height: 300,
              color: Color(0xFFBFECFF), //연한 하늘색
            ),
            Container(
              width: 240,
              height: 240,
              color: Color(0xFFCDC1FF), //연한 보라색
            ),
            Container(
              width: 180,
              height: 180,
              color: Color(0xFFFFF6E3), //크림 베이지
            ),
            Container(
              width: 120,
              height: 120,
              color: Color(0xFFFFCCEA), //연한 핑크
            ),
            Container(
              width: 60,
              height: 60,
              color: Color(0xFFFFFFFF), //흰색
            ),
          ],
        ), // Stack
      ],
    ); // body column
  } //firstBody

  Widget secondBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
        children: [
          ElevatedButton(
            onPressed: () {
              print('두 번째 화면의 버튼이 눌렸습니다');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFCCEA), // 연한 핑크 배경
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ), // 버튼 크기 조정
            ),
            child: Text(
              '천주호',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          const SizedBox(height: 20), // 버튼과 정사각형 사이 간격
          Stack(
            children: [
              Container(width: 300, height: 300, color: Colors.red),
              Container(width: 240, height: 240, color: Colors.blue),
              Container(width: 180, height: 180, color: Colors.green),
              Container(width: 120, height: 120, color: Colors.yellow),
              Container(width: 60, height: 60, color: Colors.purple),
            ],
          ),
        ],
      ),
    );
  }
}
