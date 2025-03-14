# 플러터 앱 설계

## 앱 정보  
- Wedding Trivia  
- 결혼식 하객들이 즐길 수 있는 참여형 파티 게임  
- QR스캔을 통해 하객들의 핸드폰으로 실행하는 모바일 웹앱  
- 하객들의 질답을 통해 신랑 신부만의 유니크한 스토리텔링과 인간미 발산!  
   
## 앱 구조도  
![image](https://github.com/user-attachments/assets/8d17a31c-f85c-4fb1-be03-de57a5473329)  

## 앱 와이어프레임    
![image](https://github.com/user-attachments/assets/df557531-12cc-414e-b518-2a4eee47c623)  

## 프로토타입  
![wedding_trivia_proto](https://github.com/user-attachments/assets/5fecb6c7-68a4-4375-ac36-16d7bb55eef9)

## Flutter 구현    
- 와이어프레임에 맞추어 레이아웃 소폭 변경
- 일반 퀴즈와는 달리 파티 게임, 추억 회상의 성격을 띄기 때문에, Flow와 속도 조절이 중요하다고 판단했다. 
- 타이머가 끝날 때까지 다음 퀴즈로 넘어가지 않도록 의도했다.
- 변경 이유: 단체 하객이 답을 누를 시간을 주고, 다같이 다음 단계의 정보를 받는 것이 중요하기 때문
- 버튼을 통해 전체 퀴즈를 한 번에 쭉 진행하는 방식에서, 각 퀴즈가 끝나고 > 정답화면 > 다음 퀴즈로 자동으로 넘어가는 구조로 변경했다.
- 변경 이유: 정답 확인을 통해 커플에 대한 Fun Fact를 하객들과 공유하기 위함
- Retrospect: 마지막 화면은 게스트 각자의 점수보다는 상위 랭크 3명을 보여주는 게 더 좋을 것 같다.

- 뒷부분이 잘려서 압축버전으로 전체 플로우 영상 재업로드
- ![2025-03-10163255-ezgif com-video-to-gif-converter](https://github.com/user-attachments/assets/f0675c3c-9ae1-4a31-a45e-8a83d4e9d8ef)
- 마지막 페이지 리더보드
- ![2025-03-10163255-ezgif com-video-to-gif-converter (1)](https://github.com/user-attachments/assets/a058a742-3a96-4f31-94e0-90f9b1f8bdbf)





## 회고  
- 와이어프레임을 만드는 게 익숙하지 않아서 꼼꼼하게 레이아웃을 나누지 못한게 아쉽다.
- 일단 구동하는 것을 확인하고 조금씩 원하는 기능을 넣고 빼는 식으로 진행했는데, 실무에서는 설계를 잘 하고 넘겨야할 것 같다. 
- 전환 페이지들을 각각의 dart 파일로 저장해서 임포트 하는 식으로 정리했으면 좋았겠지만, 리뷰의 편의를 위해 한 파일에 작성했다.
- QR코드와 사진등의 이미지를 넣어 완성도를 높이지 않았다. 
