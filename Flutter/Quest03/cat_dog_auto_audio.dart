import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '반려동물 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/cat',
      routes: {
        '/cat': (context) => const CatPage(),
        '/dog': (context) => const DogPage(),
      },
    );
  }
}

// 오디오 플레이어 믹스인
mixin AudioPlayerMixin<T extends StatefulWidget> on State<T> {
  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> playSound(String audioPath) async {
    await audioPlayer.play(AssetSource(audioPath));
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}

// 공통 기능을 가진 베이스 페이지
class PetPage extends StatelessWidget {
  final String title;
  final Color appBarColor;
  final IconData icon;
  final Color iconColor;
  final Widget content;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final VoidCallback onSoundButtonPressed;

  const PetPage({
    Key? key,
    required this.title,
    required this.appBarColor,
    required this.icon,
    required this.iconColor,
    required this.content,
    required this.buttonText,
    required this.onButtonPressed,
    required this.onSoundButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(10.0),
          child: Icon(icon, size: 30, color: iconColor),
        ),
        backgroundColor: appBarColor,
        title: Text(title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: onButtonPressed,
                    child: Text(buttonText, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: onSoundButtonPressed,
                    icon: const Icon(Icons.volume_up),
                    label: const Text('소리 재생'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: content,
          ),
        ],
      ),
    );
  }
}

// 고양이 페이지
class CatPage extends StatefulWidget {
  const CatPage({Key? key}) : super(key: key);

  @override
  State<CatPage> createState() => _CatPageState();
}

class _CatPageState extends State<CatPage> with AudioPlayerMixin<CatPage> {
  static const String catAudioPath = 'audios/meow_male.wav';

  @override
  void initState() {
    super.initState();
    // 페이지가 로드되면 자동으로 오디오 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      playSound(catAudioPath);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Navigator로 이전 페이지에서 돌아올 때도 오디오 재생
    if (ModalRoute.of(context)?.isCurrent == true) {
      playSound(catAudioPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PetPage(
      title: '고양이 페이지',
      appBarColor: const Color(0xFFFB9C9C),
      icon: FontAwesomeIcons.cat,
      iconColor: const Color(0xFFFFFFFF),
      content: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/pets/kitten.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text(
                '고양이',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )
            ),
            SizedBox(height: 10),
            Text(
                '소리 버튼을 눌러 고양이 소리를 들어보세요!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                )
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
      buttonText: '강아지 보기',
      onButtonPressed: () => Navigator.pushNamed(context, '/dog'),
      onSoundButtonPressed: () => playSound(catAudioPath),
    );
  }
}

// 강아지 페이지
class DogPage extends StatefulWidget {
  const DogPage({Key? key}) : super(key: key);

  @override
  State<DogPage> createState() => _DogPageState();
}

class _DogPageState extends State<DogPage> with AudioPlayerMixin<DogPage> {
  static const String dogAudioPath = 'audios/naughty_dog.wav';

  @override
  void initState() {
    super.initState();
    // 페이지가 로드되면 자동으로 오디오 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      playSound(dogAudioPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PetPage(
      title: '강아지 페이지',
      appBarColor: const Color(0xFFFAD25A),
      icon: FontAwesomeIcons.dog,
      iconColor: const Color(0xFFFFFFFF),
      content: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/pets/puppy.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text(
                '강아지',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )
            ),
            SizedBox(height: 10),
            Text(
                '소리 버튼을 눌러 강아지 소리를 들어보세요!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                )
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
      buttonText: '고양이 보기',
      onButtonPressed: () => Navigator.pop(context),
      onSoundButtonPressed: () => playSound(dogAudioPath),
    );
  }
}