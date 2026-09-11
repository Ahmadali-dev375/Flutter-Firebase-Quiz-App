// ignore_for_file: use_key_in_widget_constructors, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    _passwordController.clear();
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
              onPressed: () async {
                const String envAdminPin = String.fromEnvironment('ADMIN_PIN');
                final entered = _passwordController.text.trim();

                // 1. Check if compile-time/runtime environment PIN matches
                if (envAdminPin.isNotEmpty) {
                  if (entered == envAdminPin) {
                    _passwordController.clear();
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Panel(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incorrect Password')),
                    );
                  }
                  return;
                }

                // 2. Check if logged-in Firebase user has an admin flag
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  try {
                    final doc = await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(currentUser.uid)
                        .get();
                    if (!context.mounted) return;
                    if (doc.exists && doc.data()?['isAdmin'] == true) {
                      _passwordController.clear();
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Panel(),
                        ),
                      );
                      return;
                    }
                  } catch (e) {
                    debugPrint('Admin check error: $e');
                  }
                }

                if (!context.mounted) return;
                // If neither environment PIN nor admin role is configured
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Admin PIN not configured. Run with --dart-define=ADMIN_PIN=<your_pin>',
                    ),
                  ),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
