import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({Key? key}) : super(key: key);

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  String? _correctOption; // Nullable type to handle initial state
  bool _isLoading = false; // To track form submission status

  Future<void> _addQuestion() async {
    setState(() {
      _isLoading = true;
    });

    final questionText = _questionController.text.trim();
    final options =
        _optionControllers.map((controller) => controller.text.trim()).toList();

    if (questionText.isEmpty ||
        options.any((option) => option.isEmpty) ||
        _correctOption == null) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: "Please fill all fields correctly");
      return;
    }

    try {
      await firestore.collection('Questions').add({
        'questionText': questionText,
        'options': options,
        'correctOption': _correctOption,
      });
      Fluttertoast.showToast(msg: "Question added successfully!");
      setState(() {
        _isLoading = false;
      });
      // Optionally, clear the form fields after successful submission
      _questionController.clear();
      _optionControllers.forEach((controller) => controller.clear());
      setState(() {
        _correctOption = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: "Failed to add question: $e");
    }
  }

  void _updateDropdown() {
    setState(() {
      // Reset the correct option if it no longer matches the current options
      if (_correctOption != null &&
          !_optionControllers
              .any((controller) => controller.text.trim() == _correctOption)) {
        _correctOption = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Question'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question Text',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Options:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _optionControllers[index],
                    onChanged: (_) {
                      _updateDropdown(); // Call the method to update the dropdown when text changes
                    },
                    decoration: InputDecoration(
                      labelText: 'Option ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              const Text(
                'Select Correct Option:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _correctOption ??
                    (null as String?), // Initialize with null if no selection
                items: _optionControllers
                    .map((controller) {
                      final option = controller.text.trim();
                      return DropdownMenuItem(
                        value: option.isEmpty ? null : option,
                        child:
                            Text(option.isEmpty ? 'Select an option' : option),
                      );
                    })
                    .where((item) => item.value != null)
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _correctOption = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _addQuestion,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Add Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
