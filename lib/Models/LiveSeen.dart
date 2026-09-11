// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class LiveStream extends StatelessWidget {
//   const LiveStream({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final activityCollection =
//         FirebaseFirestore.instance.collection('UserActivities');

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text('User Activity Stream'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: activityCollection
//             .orderBy('timestamp', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           final activities = snapshot.data?.docs ?? [];

//           if (activities.isEmpty) {
//             return const Center(child: Text('No activities to display.'));
//           }

//           return ListView.builder(
//             itemCount: activities.length,
//             itemBuilder: (context, index) {
//               final activity = activities[index];
//               final data = activity.data() as Map<String, dynamic>;
//               final userId = data['userId'] ?? 'Unknown';
//               final action = data['action'] ?? 'Unknown action';
//               final timestamp =
//                   data['timestamp']?.toDate().toString() ?? 'Unknown time';

//               return Container(
//                 margin:
//                     const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'User: $userId',
//                       style: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 8),
//                     Text('Action: $action'),
//                     const SizedBox(height: 8),
//                     Text('Time: $timestamp'),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Extra/More.dart';

class UserList extends StatelessWidget {
  const UserList({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final userCollection = FirebaseFirestore.instance.collection('Users');
    final snapshot = await userCollection.get();
    return snapshot.docs
        .map((doc) => {
              'uid': doc.id,
              'username': doc['username'] ?? 'Unknown',
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Users List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return GestureDetector(
                onTap: () {
                  // Navigate to UserActivityDetails screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserActivityDetails(
                        userId: user['uid'],
                        username: user['username'],
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username: ${user['username']}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('UID: ${user['uid']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
