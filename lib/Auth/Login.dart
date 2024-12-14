// ignore_for_file: use_build_context_synchronously, use_super_parameters, file_names

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sequel/Screens/Home.dart';

import '../Components/PanelPick.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController userpassController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        automaticallyImplyLeading: false,
        actions: [PassButton()],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 60),
                // Username Input Field
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                // Password Field
                TextFormField(
                  controller: userpassController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 50),
                // Login Button
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      setState(() => loading = true);

                      try {
                        await auth.signInWithEmailAndPassword(
                          email: '${usernameController.text}@domain.com',
                          password: userpassController.text,
                        );

                        if (auth.currentUser != null) {
                          Fluttertoast.showToast(msg: 'Login Successful');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const House(),
                            ),
                          );
                        } else {
                          Fluttertoast.showToast(
                              msg: 'Login Failed. Please try again.');
                        }
                      } on FirebaseAuthException catch (e) {
                        Fluttertoast.showToast(msg: e.message ?? 'Login error');
                      } finally {
                        setState(() => loading = false);
                      }
                    }
                  },
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
