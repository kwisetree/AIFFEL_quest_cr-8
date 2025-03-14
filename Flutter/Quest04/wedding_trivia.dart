import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wedding Trivia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),
    );
  }
}

// Models
class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final List<int> guestStats;
  final String? imageUrl;

  const Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    required this.guestStats,
    this.imageUrl,
  });
}

class Player {
  final String name;
  List<int> answers = [];
  int score = 0;
  bool isActive = true;

  Player({required this.name});
}

// Sample data
final List<Question> questions = [
  const Question(
    text: 'Where did the couple first meet?',
    options: ['Coffee shop', 'Through friends'],
    correctAnswerIndex: 1,
    guestStats: [45, 55],
    imageUrl: 'assets/images/hands.jpg',
  ),
  const Question(
    text: 'Who said "I love you" first?',
    options: ['The bride', 'The groom'],
    correctAnswerIndex: 0,
    guestStats: [65, 35],
    imageUrl: 'assets/images/date.jpg',
  ),
  const Question(
    text: "What's the groom's most annoying habit?",
    options: ['Leaving socks everywhere', 'Snoring'],
    correctAnswerIndex: 1,
    guestStats: [40, 60],
    imageUrl: 'assets/images/seasons.jpg',
  ),
  const Question(
    text: 'How many times did the bride change her mind about the venue?',
    options: ['Just once', 'Too many to count'],
    correctAnswerIndex: 1,
    guestStats: [35, 65],
    imageUrl: 'assets/images/food.jpg',
  ),
  const Question(
    text: 'What would they name their first pet together?',
    options: ['A food name', 'A movie character'],
    correctAnswerIndex: 0,
    guestStats: [55, 45],
    imageUrl: 'assets/images/talents.jpg',
  ),
];

// Welcome Screen
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int guestCount = 27;
  Timer? _timer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Simulate guests joining
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          // Randomly increase guest count
          if (math.Random().nextBool()) {
            guestCount++;
          }
        });
      }
    });
    
    // Auto-scroll for the guest profiles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll();
    });
  }
  
  void _autoScroll() {
    if (!mounted) return;
    
    Future.delayed(const Duration(seconds: 2), () {
      if (_scrollController.hasClients) {
        final double maxExtent = _scrollController.position.maxScrollExtent;
        final double currentPosition = _scrollController.offset;
        
        if (currentPosition < maxExtent) {
          _scrollController.animateTo(
            maxExtent,
            duration: Duration(seconds: 10),
            curve: Curves.linear,
          ).then((_) {
            _scrollController.jumpTo(0);
            _autoScroll();
          });
        } else {
          _scrollController.jumpTo(0);
          _autoScroll();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Time display for mockup
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "9:41",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.signal_cellular_4_bar, size: 16),
                            SizedBox(width: 4),
                            Icon(Icons.wifi, size: 16),
                            SizedBox(width: 4),
                            Icon(Icons.battery_full, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 1),
                // Title and subtitle
                const Text(
                  "Sarah & Michael's",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const Text(
                  "Wedding Trivia",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE57373), // Light red/coral color for "Wedding Trivia"
                  ),
                ),
                const SizedBox(height: 24),
                // Game rules
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Text(
                        "Game Rules",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Answer within 20 seconds"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Only correct answers continue"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Top players win a special prize!"),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Guest counter
                Text(
                  "$guestCount guests joined.",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // QR code placeholder
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, 20),
                        child: Container(
                          width: 100,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(100),
                              topRight: Radius.circular(100),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Guest avatars scrolling
                Container(
                  height: 60,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: 15, // Show more avatars to allow continuous scrolling
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade400,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            (index + 1).toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(flex: 2),
                // Start button
                GestureDetector(
                  onTap: () {
                    // Generate a random guest ID
                    final random = math.Random();
                    final guestNumber = random.nextInt(999) + 1;
                    final player = Player(name: 'Guest #${guestNumber.toString().padLeft(3, '0')}');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          player: player,
                          questionIndex: 0,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE57373), // Match the coral color
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Text(
                        "Start the Quiz!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Quiz Screen
class QuizScreen extends StatefulWidget {
  final Player player;
  final int questionIndex;

  const QuizScreen({
    Key? key,
    required this.player,
    required this.questionIndex,
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool hasAnswered = false;
  int? selectedAnswer;
  int timeRemaining = 3;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeRemaining > 0) {
          timeRemaining--;
        } else {
          // Time's up
          _timer.cancel();
          
          // Auto-select an answer if none selected
          if (!hasAnswered) {
            final random = math.Random();
            selectedAnswer = random.nextInt(questions[widget.questionIndex].options.length);
            hasAnswered = true;
          }
          
          // Now proceed to next screen
          _proceedToNextScreen();
        }
      });
    });
  }

  void _selectAnswer(int index) {
    if (hasAnswered) return;

    setState(() {
      selectedAnswer = index;
      hasAnswered = true;
    });

    // Don't proceed yet - wait for timer to complete
  }

  void _proceedToNextScreen() {
    // Calculate score
    final isCorrect = selectedAnswer == questions[widget.questionIndex].correctAnswerIndex;
    if (isCorrect) {
      int timeBonus = timeRemaining * 5;
      widget.player.score += 100 + timeBonus;
    }
    
    widget.player.answers.add(selectedAnswer!);
    widget.player.isActive = isCorrect;

    // Always go to the wrong answer screen first to show explanation
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => WrongAnswerScreen(
          player: widget.player,
          questionIndex: widget.questionIndex,
          selectedAnswer: selectedAnswer!,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[widget.questionIndex];
    final progressPercentage = widget.questionIndex / questions.length;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Status bar and progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.arrow_back_ios, size: 20, color: Colors.grey),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: timeRemaining <= 10 ? const Color(0xFFE57373) : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$timeRemaining Seconds",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "${widget.questionIndex + 1}/${questions.length}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.info_outline, color: Colors.red, size: 16),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Timer progress bar
              Container(
                width: double.infinity,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * (timeRemaining / 3),
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE57373),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Question
              Text(
                question.text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Question image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 180,
                  color: Colors.grey.shade300,
                  child: Image.asset(
                    question.imageUrl ?? 'assets/images/default.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.grey.shade500,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Legend for pie chart
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Option A legend
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade300,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          questions[widget.questionIndex].options[0],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    // Option B legend
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade300,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          questions[widget.questionIndex].options[1],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Answer options - Made larger
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Option 1
                  Transform.rotate(
                    angle: -0.03,
                    child: GestureDetector(
                      onTap: () => _selectAnswer(0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: selectedAnswer == 0 
                              ? const Color(0xFFE8F5E9) // Light green for selected
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              selectedAnswer == 0 ? Icons.check_circle : null,
                              color: Colors.green,
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              question.options[0],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: selectedAnswer == 0 
                                    ? Colors.green
                                    : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Option 2
                  Transform.rotate(
                    angle: 0.03,
                    child: GestureDetector(
                      onTap: () => _selectAnswer(1),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: selectedAnswer == 1 
                              ? const Color(0xFFE8F5E9) // Changed to green for consistency
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              selectedAnswer == 1 ? Icons.check_circle : null,
                              color: Colors.green,
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              question.options[1],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: selectedAnswer == 1 
                                    ? Colors.green
                                    : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                hasAnswered ? "Wait for timer to complete..." : "Select an answer",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Wrong Answer Screen
class WrongAnswerScreen extends StatefulWidget {
  final Player player;
  final int questionIndex;
  final int selectedAnswer;

  const WrongAnswerScreen({
    Key? key,
    required this.player,
    required this.questionIndex,
    required this.selectedAnswer,
  }) : super(key: key);

  @override
  _WrongAnswerScreenState createState() => _WrongAnswerScreenState();
}

class _WrongAnswerScreenState extends State<WrongAnswerScreen> {
  int countdown = 5;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          _timer.cancel();
          
          // Check if there are more questions
          if (widget.questionIndex < questions.length - 1) {
            // Move to the next question
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) => QuizScreen(
                  player: widget.player,
                  questionIndex: widget.questionIndex + 1,
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          } else {
            // Last question - go to completion screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CompletionScreen(
                  player: widget.player,
                  correctAnswers: widget.player.answers.length,
                  totalQuestions: questions.length,
                ),
              ),
            );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[widget.questionIndex];
    final correctOption = question.options[question.correctAnswerIndex];
    
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.arrow_back_ios, size: 20, color: Colors.grey),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$countdown",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "${widget.questionIndex + 1}/${questions.length}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.info_outline, color: Colors.red, size: 16),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Wrong answer text
              Text(
                widget.selectedAnswer == questions[widget.questionIndex].correctAnswerIndex 
                    ? "Correct!" 
                    : "Wrong!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE57373),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "14 guests got this question right",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE57373),
                ),
              ),
              const SizedBox(height: 40),
              // Pie chart
              Container(
                width: 220,
                height: 220,
                child: CustomPaint(
                  painter: PieChartPainter(guestStats: questions[widget.questionIndex].guestStats),
                ),
              ),
              const SizedBox(height: 30),
              // Explanation
              Text(
                "The real story...",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE57373),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "They actually met through mutual friends at a\nbirthday party. It wasn't love at first sight,\nbut they kept running into each other!",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Text(
                "Next question in ${countdown} seconds...",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              // Show restart button only if the answer was wrong
              widget.selectedAnswer != questions[widget.questionIndex].correctAnswerIndex 
              ? GestureDetector(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    (route) => false,
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE57373),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      "게임 다시 시작하기",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
              : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom pie chart painter
class PieChartPainter extends CustomPainter {
  final List<int> guestStats;
  
  PieChartPainter({required this.guestStats});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Calculate total for percentages
    final total = guestStats[0] + guestStats[1];
    
    // First slice - Option A
    final optionAPaint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.fill;
    
    // Second slice - Option B
    final optionBPaint = Paint()
      ..color = Colors.orange.shade300
      ..style = PaintingStyle.fill;
    
    // Outline
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Draw the pie chart
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // Option A slice
    final optionAAngle = (guestStats[0] / total) * 2 * math.pi;
    canvas.drawArc(
      rect,
      -math.pi / 2, // Start from top
      optionAAngle,
      true,
      optionAPaint,
    );
    
    // Option B slice
    canvas.drawArc(
      rect,
      -math.pi / 2 + optionAAngle,
      2 * math.pi - optionAAngle,
      true,
      optionBPaint,
    );
    
    // Draw outline
    canvas.drawCircle(center, radius, outlinePaint);
    
    // Add labels
    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Option A percentage
    final optionAText = '${guestStats[0]}%';
    textPainter.text = TextSpan(
      text: optionAText,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
    
    textPainter.layout();
    final optionAPosition = Offset(
      center.dx - textPainter.width / 2,
      center.dy - radius * 0.5 - textPainter.height / 2,
    );
    textPainter.paint(canvas, optionAPosition);
    
    // Option B percentage
    final optionBText = '${guestStats[1]}%';
    textPainter.text = TextSpan(
      text: optionBText,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
    
    textPainter.layout();
    final optionBPosition = Offset(
      center.dx - textPainter.width / 2,
      center.dy + radius * 0.3 - textPainter.height / 2,
    );
    textPainter.paint(canvas, optionBPosition);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Completion screen
class CompletionScreen extends StatelessWidget {
  final Player player;
  final int correctAnswers;
  final int totalQuestions;

  const CompletionScreen({
    Key? key,
    required this.player,
    required this.correctAnswers,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create sample top players
    final List<Player> topPlayers = [
      Player(name: 'Guest 102')..score = 350..isActive = false,
      Player(name: 'Guest 031')..score = 480..isActive = true,
      Player(name: 'Guest ${player.name.split('#').last}')..score = player.score..isActive = true,
    ];

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Celebration icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    "🎉",
                    style: TextStyle(fontSize: 50),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Quiz ",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const TextSpan(
                      text: "Completed!",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              const Text(
                "신랑신부의 모든 것을 아는 당신,\n찐친이시군요!",
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Player card - Larger and centered
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orange.shade400,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.orange.shade400,
                            size: 24,
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_rounded,
                              size: 60,
                              color: Colors.black54,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Guest 031",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Score: ${player.score} points",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Correct answers count
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.orange.shade400,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$correctAnswers Correct Answers",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Message
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "마음을 담은 선물을 준비했어요 ",
                    style: TextStyle(fontSize: 18),
                  ),
                  Icon(
                    Icons.favorite,
                    color: Colors.red.shade400,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Photo link
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "인증샷 남기기",
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Start over button
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE57373),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      "Start Over",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
