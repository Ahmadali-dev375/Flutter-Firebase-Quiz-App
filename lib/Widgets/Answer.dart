import 'package:flutter/material.dart';

class AnswerCard extends StatelessWidget {
  const AnswerCard({
    super.key,
    required this.question,
    required this.isSelected,
    required this.selectedAnswerIndex,
    required this.correctAnswerIndex,
    required this.options,
    required this.onTap,
  });

  final String question;
  final bool isSelected;
  final int selectedAnswerIndex;
  final int correctAnswerIndex;
  final List<String> options;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Validate correctAnswerIndex
    final bool isValidIndex =
        correctAnswerIndex >= 0 && correctAnswerIndex < options.length;

    // Safe-check for correct answer
    final bool isCorrectAnswer =
        isValidIndex && selectedAnswerIndex == correctAnswerIndex;

    // Determine if the selected answer is wrong
    final bool isWrongAnswer = isSelected && !isCorrectAnswer;

    // Safe correct answer display
    final String correctAnswerText =
        isValidIndex ? options[correctAnswerIndex] : "Invalid answer";

    return GestureDetector(
      onTap: isSelected ? null : onTap,
      child: Padding(
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
              if (isWrongAnswer)
                Text(
                  'Correct answer: $correctAnswerText',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              if (isSelected)
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    isCorrectAnswer ? Icons.check_circle : Icons.cancel,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
