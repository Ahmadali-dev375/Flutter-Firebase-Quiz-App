// ignore_for_file: file_names

import 'package:flutter/material.dart';

class AnswerCard extends StatelessWidget {
  const AnswerCard({
    super.key,
    required this.question,
    required this.isSelected,
    required this.selectedAnswerIndex,
    required this.correctAnswerIndex,
    required this.options,
    required String answerText,
    required Null Function() onPressed,
  });

  final String question;
  final bool isSelected;
  final int selectedAnswerIndex;
  final int correctAnswerIndex;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    // Determine if the selected answer is correct
    final bool isCorrectAnswer = selectedAnswerIndex == correctAnswerIndex;
    // Determine if the selected answer is wrong
    final bool isWrongAnswer = !isCorrectAnswer && isSelected;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? (isCorrectAnswer ? Colors.green : Colors.red)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? (isCorrectAnswer ? Colors.green : Colors.red)
                : Colors.grey,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (isWrongAnswer) // Show the correct answer if the user selected wrong
                    Text(
                      'Correct answer: ${options[correctAnswerIndex]}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                isCorrectAnswer ? Icons.check_circle : Icons.cancel,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}
