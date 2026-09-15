# Flutter Quiz App — Static Data Version

This branch preserves the original version of the quiz application.

In this implementation, quiz questions, answer options, and correct answers
are stored locally in Dart instead of being fetched from Cloud Firestore.

## 📌 Purpose

This branch is preserved as part of the project's development history and
shows the earlier static-data architecture before the application was
expanded into a Firebase-powered quiz and assessment platform.

## 🧩 Static Question Model

```dart
class QuestionModel {
  final String qus;
  final List<String> opt;
  final int ans;

  const QuestionModel({
    required this.qus,
    required this.opt,
    required this.ans,
  });
}
