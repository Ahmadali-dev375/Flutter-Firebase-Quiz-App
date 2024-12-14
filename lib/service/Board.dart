// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sequel/Components/PanelPick.dart';

class Leaderboard extends StatefulWidget {
  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  final userCollection = FirebaseFirestore.instance.collection('Users');
  final ScrollController _scrollController = ScrollController();
  String currentUsername = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUsername();
  }

  Future<void> _fetchCurrentUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await userCollection.doc(user.uid).get();
      setState(() {
        currentUsername = userData.data()?['username'] ?? 'Unknown';
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchLeaderboardData() async {
    final querySnapshot = await userCollection.get();
    List<Map<String, dynamic>> leaderboardData = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final username = data['username'] ?? 'Unknown';
      final finalResults = data['finalResults'] as List<dynamic>? ?? [];

      if (finalResults.isNotEmpty) {
        final highestScore = finalResults
            .map((result) => result['score'] as int)
            .reduce((a, b) => a > b ? a : b);
        leaderboardData.add({'username': username, 'score': highestScore});
      }
    }

    leaderboardData.sort((a, b) => b['score'].compareTo(a['score']));
    return leaderboardData;
  }

  void _scrollToCurrentUser(List<Map<String, dynamic>> leaderboardData) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = leaderboardData.indexWhere(
        (entry) => entry['username'] == currentUsername,
      );
      if (index != -1) {
        _scrollController.animateTo(
          index * 80.0, // Approximate card height
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Leaderboard'),
        actions: [PassButton()],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {}); // Refresh leaderboard
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchLeaderboardData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading leaderboard'));
            }

            final leaderboardData = snapshot.data ?? [];
            if (leaderboardData.isEmpty) {
              return const Center(child: Text('No leaderboard data available'));
            }

            if (snapshot.connectionState == ConnectionState.done) {
              _scrollToCurrentUser(leaderboardData);
            }

            int rank = 1;
            int previousScore = leaderboardData[0]['score'];

            return ListView.builder(
              controller: _scrollController,
              itemCount: leaderboardData.length,
              itemBuilder: (context, index) {
                final entry = leaderboardData[index];
                if (entry['score'] != previousScore) {
                  rank = index + 1;
                }
                previousScore = entry['score'];

                final bool isCurrentUser = entry['username'] == currentUsername;

                return _buildUserCard(entry, rank, isCurrentUser);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserCard(
      Map<String, dynamic> entry, int rank, bool isCurrentUser) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isCurrentUser ? Colors.green : Colors.transparent,
          width: 2,
        ),
      ),
      // color: isCurrentUser ? Colors.green.withOpacity(0.1) : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildRankCircle(rank),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry['username'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      isCurrentUser ? FontWeight.bold : FontWeight.normal,
                  color: isCurrentUser ? Colors.green[800] : Colors.black,
                ),
              ),
            ),
            Text(
              'Score: ${entry['score']}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankCircle(int rank) {
    final colors = [Colors.amber, Colors.grey, Colors.brown];
    return CircleAvatar(
      radius: 20,
      backgroundColor: rank <= 3 ? colors[rank - 1] : Colors.blue,
      child: Text(
        '$rank',
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
