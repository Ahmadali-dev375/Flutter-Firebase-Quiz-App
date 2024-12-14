// ignore_for_file: use_key_in_widget_constructors, file_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:sequel/Auth/Login.dart';

class Checking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Column(
              children: [
                Text('data'),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: const Text('Leaderboard'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
