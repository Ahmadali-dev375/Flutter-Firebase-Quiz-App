// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Components/DialogueLook.dart';
import '../Components/PanelPick.dart';
import '../Models/Question.dart';
import '../Widgets/Answer.dart';
import '../service/Board.dart';

class House extends StatefulWidget {
  const House({super.key});

  @override
  State<House> createState() => _HouseState();
}

class _HouseState extends State<House> {
  int? selectedans;
  int questindex = 0;
  int score = 0;
  bool isAnswered = false;
  String username = "Wait"; // Default username
  bool hasAttemptedQuiz = false;
  bool isLoading = true; // Loading state to manage data fetching

  final userCollection = FirebaseFirestore.instance.collection('Users');
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data on widget initialization
  }

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
      } finally {
        setState(() {
          isLoading = false; // Data fetching complete
        });
      }
    } else {
      setState(() {
        isLoading = false; // No user logged in
      });
    }
  }

  Future<void> _storeResults() async {
    if (userId == null) {
      debugPrint('User ID is null. Cannot store results.');
      return;
    }

    try {
      final userDoc = userCollection.doc(userId);
      final snapshot = await userDoc.get();
      if (!snapshot.exists) {
        await userDoc.set({
          'username': username,
          'hasAttemptedQuiz': false,
          'finalResults': [],
        });
      }

      await userDoc.update({
        'hasAttemptedQuiz': true,
        'finalResults': FieldValue.arrayUnion([
          {
            'score': score,
            'date': DateTime.now().toIso8601String(),
          }
        ]),
      });

      debugPrint('Results stored successfully for userId: $userId');
    } catch (e) {
      debugPrint('Error storing results: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz App')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                  setState(() {
                    isLoading = true; // Show loading while navigating
                  });
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Leaderboard()),
                  );
                  await _fetchUserData(); // Refresh state after returning
                  setState(() {
                    isLoading = false; // Hide loading
                  });
                },
                child: const Text('Go to Leaderboard'),
              ),
            ],
          ),
        ),
      );
    }

    final currentquest = question[questindex];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        automaticallyImplyLeading: false,
        actions: [PassButton()],
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
              currentquest.qus,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: currentquest.opt.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: isAnswered
                        ? null
                        : () {
                            setState(() {
                              selectedans = index;
                              isAnswered = true;
                            });
                          },
                    child: AnswerCard(
                      question: currentquest.opt[index],
                      answerText: currentquest.opt[index],
                      isSelected: selectedans == index,
                      selectedAnswerIndex: selectedans ?? -1,
                      correctAnswerIndex: currentquest.ans,
                      options: currentquest.opt,
                      onPressed: () {
                        setState(() {
                          selectedans = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: isAnswered
                    ? () async {
                        if (selectedans == currentquest.ans) {
                          setState(() {
                            score++; // Increment score for correct answers
                          });
                        }
                        if (questindex < question.length - 1) {
                          setState(() {
                            questindex++;
                            selectedans = null;
                            isAnswered = false;
                          });
                        } else {
                          int wrongAnswers = question.length - score;
                          try {
                            await _storeResults();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                title: const Text('Quiz Completed!'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Results',
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(children: [
                                          const Text('Correct'),
                                          const SizedBox(height: 5),
                                          ColoredCircle(
                                            color: Colors.green,
                                            text: '$score',
                                          ),
                                        ]),
                                        Column(children: [
                                          const Text('Wrong'),
                                          const SizedBox(height: 5),
                                          ColoredCircle(
                                            color: Colors.red,
                                            text: '$wrongAnswers',
                                          ),
                                        ])
                                      ],
                                    ),
                                    Column(children: [
                                      const SizedBox(height: 10),
                                      const Text('Total Score'),
                                      ColoredCircle(
                                        height: 40,
                                        width: 40,
                                        color: Colors.blue,
                                        text: '$score/${question.length}',
                                      ),
                                    ]),
                                    const SizedBox(height: 30),
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
                                        child: const Text('Go to Leaderboard'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } catch (e) {
                            debugPrint('Error during quiz completion: $e');
                          }
                        }
                      }
                    : null,
                child:
                    Text(questindex < question.length - 1 ? 'Next' : 'Finish'),
              ),
            ),
            const SizedBox(height: 120)
          ],
        ),
      ),
    );
  }
}
