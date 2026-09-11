import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Components/DialogueLook.dart';
import '../Components/PanelPick.dart';
import '../Widgets/Answer.dart';
import '../service/Board.dart';

class House extends StatefulWidget {
  const House({super.key});

  @override
  State<House> createState() => _HouseState();
}

class _HouseState extends State<House> {
  int? selectedAnswer;
  int questionIndex = 0;
  int score = 0;
  bool isAnswered = false;
  String username = "Wait";
  bool hasAttemptedQuiz = false;
  bool isLoading = true;

  final userCollection = FirebaseFirestore.instance.collection('Users');
  final firestore = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser?.uid;

  List<Question> questions = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchQuestions();
  }

  // Fetch user data from Firebase
  Future<void> _fetchUserData() async {
    if (userId != null) {
      try {
        final userDoc = await userCollection.doc(userId).get();
        if (userDoc.exists) {
          setState(() {
            username = userDoc['username'] ?? "User";
            hasAttemptedQuiz = userDoc['hasAttemptedQuiz'] ?? false;
          });
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
      }
    }
  }

  // Fetch quiz questions from Firebase
  Future<void> _fetchQuestions() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection('Questions').get();

      setState(() {
        questions = snapshot.docs.map((doc) {
          final data = doc.data();
          return Question(
            qus: data['question'] ?? '',
            opt: data['options'] != null
                ? List<String>.from(data['options'])
                : [],
            ans: data['answerIndex'] ?? -1,
          );
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching questions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Store quiz results in Firebase
  Future<void> _storeResults() async {
    if (userId == null) return;

    try {
      final userDoc = userCollection.doc(userId);

      // Check if the user document exists
      final snapshot = await userDoc.get();
      if (!snapshot.exists) {
        // If it doesn't exist, create a new document
        await userDoc.set({
          'username': username,
          'hasAttemptedQuiz': false,
          'finalResults': [],
        });
      }

      // Now, update the user's document with the quiz results
      await userDoc.update({
        'hasAttemptedQuiz': true, // Mark quiz as attempted
        'finalResults': FieldValue.arrayUnion([
          {
            'score': score, // Store the score
            'date': DateTime.now()
                .toIso8601String(), // Store the date of the quiz attempt
          }
        ]),
      });

      debugPrint('Results stored successfully for user: $userId');
    } catch (e) {
      debugPrint('Error storing results: $e');
    }
  }

  // Log activity to Firestore
  Future<void> _logActivity(String questionText, String selectedAnswer) async {
    await FirebaseFirestore.instance.collection('ActivityLogs').add({
      'username': username, // Logged-in user's name
      'question': questionText,
      'selectedAnswer': selectedAnswer,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz App')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // If the user has already attempted the quiz, show the result screen
    if (hasAttemptedQuiz) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Quiz App'),
          automaticallyImplyLeading: false,
          actions: [PassButton()],
        ),
        body: Center(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.person, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    username,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 150),
              const Text(
                'You have already taken the quiz!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Leaderboard()),
                  );
                },
                child: const Text('Go to Leaderboard'),
              ),
            ],
          ),
        ),
      );
    }

    // Current question being displayed
    final currentQuestion = questions[questionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $username',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20.0),
            Text(
              currentQuestion.qus,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Questions')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Fetch all questions from the Firestore snapshot
                  final allQuestions = snapshot.data!.docs;

                  // Check if we have questions
                  if (allQuestions.isEmpty) {
                    return const Center(
                      child: Text('No questions available.'),
                    );
                  }

                  // Get the current question based on the questionIndex
                  final currentQuestionData = allQuestions[questionIndex].data()
                      as Map<String, dynamic>;

                  final options =
                      List<String>.from(currentQuestionData['options'] ?? []);
                  final correctOption =
                      currentQuestionData['correctOption'] ?? '';
                  final correctAnswerIndex = options.indexOf(correctOption);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentQuestionData['questionText'] ??
                            'No question text',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: options.length,
                        itemBuilder: (context, optionIndex) {
                          return AnswerCard(
                            question: options[optionIndex],
                            isSelected: selectedAnswer == optionIndex,
                            selectedAnswerIndex: selectedAnswer ?? -1,
                            correctAnswerIndex: correctAnswerIndex,
                            options: options,
                            onTap: () {
                              if (!isAnswered) {
                                setState(() {
                                  selectedAnswer = optionIndex;
                                  isAnswered = true;
                                });
                              }
                              // Log activity
                              _logActivity(currentQuestion.qus,
                                  currentQuestion.opt[optionIndex]);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          // In the onPressed callback of the "Finish" button:
                          onPressed: isAnswered
                              ? () {
                                  // Check if the selected answer is correct
                                  if (selectedAnswer == correctAnswerIndex) {
                                    setState(() {
                                      score++;
                                    });
                                  }

                                  // Calculate wrong answers
                                  int wrongAnswers = questions.length - score;

                                  // Move to the next question or finish quiz
                                  if (questionIndex < questions.length - 1) {
                                    setState(() {
                                      questionIndex++;
                                      selectedAnswer = null;
                                      isAnswered =
                                          false; // Reset answer flag for next question
                                    });
                                  } else {
                                    // Quiz finished
                                    try {
                                      // Store results in Firebase
                                      _storeResults(); // Store results in Firebase

                                      // Show custom completion dialog
                                      showDialog(
                                        context: context,
                                        barrierDismissible:
                                            false, // Prevent closing by tapping outside
                                        builder: (context) => AlertDialog(
                                          title: const Text('Quiz Completed!'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'Results',
                                                style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  // Correct answers section
                                                  Column(
                                                    children: [
                                                      const Text('Correct'),
                                                      const SizedBox(height: 5),
                                                      ColoredCircle(
                                                        color: Colors.green,
                                                        text: '$score',
                                                      ),
                                                    ],
                                                  ),
                                                  // Wrong answers section
                                                  Column(
                                                    children: [
                                                      const Text('Wrong'),
                                                      const SizedBox(height: 5),
                                                      ColoredCircle(
                                                        color: Colors.red,
                                                        text: '$wrongAnswers',
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              // Total score section
                                              Column(
                                                children: [
                                                  const SizedBox(height: 10),
                                                  const Text('Total Score'),
                                                  ColoredCircle(
                                                    height: 40,
                                                    width: 40,
                                                    color: Colors.blue,
                                                    text:
                                                        '$score/${questions.length}',
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 30),
                                              // Button to go to leaderboard
                                              Center(
                                                child: TextButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Leaderboard(),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text(
                                                      'Go to Leaderboard'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      debugPrint(
                                          'Error during quiz completion: $e');
                                    }
                                  }
                                }
                              : null,

                          child: Text(questionIndex < allQuestions.length - 1
                              ? 'Next'
                              : 'Finish'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Question {
  final String qus;
  final List<String> opt;
  final int ans;

  Question({
    required this.qus,
    required this.opt,
    required this.ans,
  });
}
