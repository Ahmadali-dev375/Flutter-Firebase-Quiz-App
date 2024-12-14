// ignore_for_file: use_key_in_widget_constructors, file_names

import 'package:flutter/material.dart';

import '../Auth/Register.dart';

class PassButton extends StatelessWidget {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        _showPasswordDialog(context);
      },
      icon: const Icon(
        Icons.admin_panel_settings,
        size: 30,
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Admin Panel\n',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: 'only for admin',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            textAlign: TextAlign.center, // Centers the text
          ),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_passwordController.text == '123456') {
                  // Replace with your password
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const Panel(), // Replace with your destination screen
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect Password')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
