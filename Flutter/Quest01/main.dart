//import 'package:flutter/material.dart';
import 'dart:async';

// 회고를 작성합니다.
// 이혜승:
// 너무 어렵고 정신없었습니다. 생각보다 구조를 짠 이후에도 카운트 다운하면서 출력 부분을 세심하게 신경써야 동작하는 부분이 눈에 보인다는 걸 배웠고, Timer.periodic 은 새로운 문법이라 정확히 이해하고 사용하는 지 확신은 들지 않지만 동작은 하는 것 같아서 기뻐요. 생성자와 세션마다 상태를 전환해주는 부분의 조건을 맞춰주는 부분이 특히 어려웠습니다. 조금 더 파트너와 대화를 나누면서 코드를 짜면 좋았을텐데 아쉽습니다. 대화를 나누면서 코드를 발전시켜가기에 시간이 벅차게 느껴졌어요.
// 천주호:
// 처음엔 어떻게 시작해야할지 아예 감도 안잡혀서 시작하지 못했었는데 조금씩 공부해가며 구조를 배우게 되어서 좋았습니다 . Timer.periodic 이라는 좋은 기능을 배우게 되어서 좋았습니다. 하면 할수록 좀더 잘하고 싶은 욕심이 나는데 아직 역부족이라 공부를 더 해야겠다고 생각했습니다

조금씩 공부해가며 구조를 배우게 되어서 좋았습니다 . Timer.periodic 이라는 좋은 기능을 배우게 되어서 좋았습니다. 하면 할수록 좀더 잘하고 싶은 욕심이 나는데 아직 역부족이라 공부를 더 해야겠다고 생각했습니다


void main() {
  // 디버깅: runApp(PomodoroTimerApp());
  // PomodoroTimer가 위젯이 아니라 Dart 클래스여서 runApp() 함수를 통해 루트 위젯으로 사용 불가
  // 플러터 위젯은 StatelessWidget 이나 StatefulWidget을 상속받아야 함
  PomodoroTimer timer = PomodoroTimer(cycleCount: 4); // 초기 사이클 값 4 설정
  // PomodoroTimer의 timer에 cycleCount 변수값 전달
  timer.start(); // timer 객체에서 시작 메서드 호출
}

//CLI 출력 버전
//사이클 (현재 사이클 (동적)/ 설정 사이클 (정적))
//사이클 카운트는 (작업시간 1회 + 휴식시간 1회 종료 후)
//상태 (bool 작업중 / 휴식 중)
//남은 시간 (동적)
//작업시간 25초 (정적)
//휴식시간 5초 (정적)
//긴 휴식시간 15초 (조건: 4번째 사이클 마다) (정적)
//타이머 중지 기능
//time.periodic 으로 초당 상태 출력

class PomodoroTimer {
  final int cycleCount; // 사이클 변수 설정 고정
  final int workTime = 25; // 작업시간 25초 고정
  final int shortBreak = 5; // 짧은 휴식 5초 고정
  final int longBreak = 15; // 긴 휴식 15초 고정
  int currentCycle = 0; // 사이클 초기값
  int remainingTime;
  bool workingStatus = true; // 작업중 상태
  Timer? timer; // 타이머 객체
  // timer가 null이 아닌 경우에만 다음 메서드 호출하는 nullable 객체

  // 타이머 생성자
  // 왼쪽은 사이클 변수 초기값 설정 : 오른쪽은 생성자 선언부 (초기화)
  PomodoroTimer({this.cycleCount = 4 }) : remainingTime = 25;

  // 시작 함수
  void start() {
    print( "시작~! 전체 사이클: ${cycleCount}");

    // 카운트 다운 객체 생성
    // timer 는 이 클래스에서 시작할 대만 설정됨
    // 1초 간격으로 반복되는 타이머
    // (timer) 함수 내에 남은 시간 출력
    timer = Timer.periodic(Duration(seconds: 1), (timer){
      updateTimer(); // 남은 시간 업데이트
      // 타이머 동작하는 지 디버깅용 출력
      print("타이머 카운트 다운 진행되고 있음~");
      if (remainingTime > 0) {
        print(" ${workingStatus? '작업':'휴식'} 시간: ${remainingTime} 초 남음");
        remainingTime--;
      } else { nextSession(); }

    });
  }

  // 타이머 종료 시점 상태 업데이트
  void updateTimer() {
    //조건: 남은 시간 > 0 일때
    if (remainingTime > 0) {
      // 1초 차감
    } else {
      // 다음 세션으로 상태 변경 (함수 호출)
      nextSession();
    }
  }

// 세션 구간 별 동작과 출력 메시지
  void nextSession(){
    timer?.cancel(); // 타이머 중지
    // timer가 null이 아닐때만 cancel() 함수 호출

    switch (workingStatus) {
      case true: // workingStatus 가 bool 타입이기 때문에 true/false 로 케이스 구분
      // 작업시간 종료 시 세션 변경
        switch (currentCycle) {
          case 3: // currentCycle 이 정수형 변수이기 때문에 4번째 사이클 지정(0~3)
            remainingTime = longBreak;
            print("\n 4회차 종료! 기지개 쭉 펴고 수분 섭취 합시다");
            break; //switch 문에서 나가기
          default:
            remainingTime = shortBreak;
            print("\n 5초만 쉬고 다시 집중하실께여~");
            break;
        }
        break;
      case false:
      // 휴식시간 종료 시 세션 변경
        currentCycle++; // 사이클 1회 증가
        if (currentCycle >= cycleCount) {
          print("\n 모든 사이클 종료! 고생했으니 고양이숏츠를 맘껏 즐기세요!!");
          return;
        }
        remainingTime = workTime;
        print("\n 작업 시작!\n");
        break;
    }

    // 세션 변경 (작업 <-> 휴식)
    workingStatus = !workingStatus;
    start();
  }
}