// ignore_for_file: use_build_context_synchronously, use_super_parameters, file_names

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Extra/More.dart';
import '../Models/LiveSeen.dart';
import '../service/Board.dart';
import 'Login.dart';

class Panel extends StatefulWidget {
  const Panel({Key? key}) : super(key: key);

  @override
  State<Panel> createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection('Users').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> _addNewUser(String username, String password) async {
    if (username.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a username');
      return;
    }
    if (password.length < 6) {
      Fluttertoast.showToast(msg: 'Password must be at least 6 characters');
      return;
    }

    setState(() => loading = true);
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: '$username@domain.com',
        password: password,
      );
      String uid = userCredential.user!.uid;

      await firestore.collection('Users').doc(uid).set({
        'uid': uid,
        'username': username,
      });

      Fluttertoast.showToast(msg: 'User $username added successfully!');
      _usernameController.clear();
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? 'Failed to add user');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
          ),
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Leaderboard()),
                );
              },
              icon: const Icon(Icons.emoji_events)),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserActivityDetails(
                    userId: 'exampleUserId',
                    username: 'Example Username',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.stream),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Add New User (Username)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Temporary Password (min 6 characters)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final username = _usernameController.text.trim();
                final password = _passwordController.text.trim();
                _addNewUser(username, password);
              },
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Add User'),
            ),
            const Center(
                child: Text(
              'Registerd Users',
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: 17,
              ),
            )),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final users = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text(user['username'] ?? 'Unknown'),
                        subtitle: Text('UID: ${user['uid']}'),
                      );
                    },
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
