import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserActivityDetails extends StatelessWidget {
  final String userId;
  final String username;

  const UserActivityDetails({
    Key? key,
    required this.userId,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activityCollection =
        FirebaseFirestore.instance.collection('UserActivities');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('$username\'s Activity'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: activityCollection
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final activities = snapshot.data?.docs ?? [];
          if (activities.isEmpty) {
            return const Center(
              child: Text('No activities to display for this user.'),
            );
          }

          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              final data = activity.data() as Map<String, dynamic>;
              final question = data['question'] ?? 'Unknown question';
              final selectedAnswer = data['selectedAnswer'] ?? 'Unknown answer';
              final timestamp =
                  data['timestamp']?.toDate().toString() ?? 'Unknown time';

              return Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question: $question',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Answer Selected: $selectedAnswer'),
                    const SizedBox(height: 8),
                    Text('Time: $timestamp'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
