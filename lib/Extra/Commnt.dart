//  style: Theme.of(context)
//                     .textTheme
//                     .displayLarge!
//                     .copyWith(fontSize: 25),
//************************************************************************************************
// elevatedButtonTheme: ElevatedButtonThemeData(
          //   style: ButtonStyle(
          //     shadowColor: MaterialStateProperty.all<Color>(Colors.black),
          //     backgroundColor:
          //         MaterialStateProperty.all<Color>(Colors.white), //button color
          //   ),
          // ),
          // appBarTheme: AppBarTheme(color:),
          // scaffoldBackgroundColor: ,
 // textTheme: const TextTheme(
        //     displayLarge: TextStyle(
        //         fontSize: 40,
        //         fontWeight: FontWeight.w500,
        //         color: Color(0xFF4EE489)),
        //     titleSmall: TextStyle(
        //       fontSize: 9,
        //       fontStyle: FontStyle.italic,
        //     ),
        //     titleMedium:
        //         TextStyle(fontSize: 90, fontWeight: FontWeight.normal)),
//****************************************************************************************************

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: House(),
//     );
//   }
// }

// class House extends StatefulWidget {
//   @override
//   _HouseState createState() => _HouseState();
// }

// class _HouseState extends State<House> {
//   late TextEditingController _nameController;
//   List<String> savedItems = [];
//   String savedItemText = '';

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController();
//     _loadSavedItems();
//   }

//   // Load saved items from SharedPreferences
//   _loadSavedItems() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       savedItems = prefs.getStringList('items') ?? [];
//       savedItemText =
//           savedItems.isNotEmpty ? savedItems.join(', ') : 'No saved items yet.';
//     });
//   }

//   // Save a new item to SharedPreferences
//   _saveItemToPreferences(String newItem) async {
//     if (newItem.isNotEmpty && !savedItems.contains(newItem)) {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       savedItems.add(newItem); // Add new item to list
//       await prefs.setStringList(
//           'items', savedItems); // Save updated list to SharedPreferences
//       _loadSavedItems(); // Reload saved items
//     }
//   }

//   // Navigate to Saved Items screen
//   void _navigateToSavedItemsScreen(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SavedItemsScreen(savedItems: savedItems),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Save Items")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: <Widget>[
//             // Input field to enter new data
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: 'Enter an Item',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 String newItem = _nameController.text;
//                 if (newItem.isNotEmpty) {
//                   _saveItemToPreferences(newItem); // Save new item
//                   _nameController.clear(); // Clear input field
//                 }
//               },
//               child: Text('Save Item'),
//             ),
//             SizedBox(height: 32),
//             // Display saved item(s)
//             Text(savedItemText),
//             SizedBox(height: 16),
//             // Button to navigate to Saved Items screen
//             ElevatedButton(
//               onPressed: () => _navigateToSavedItemsScreen(context),
//               child: Text('View Saved Items'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SavedItemsScreen extends StatelessWidget {
//   final List<String> savedItems;

//   const SavedItemsScreen({Key? key, required this.savedItems})
//       : super(key: key);

// ignore_for_file: file_names

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Saved Items")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: savedItems.isEmpty
//             ? Center(child: Text('No items saved yet.'))
//             : ListView.builder(
//                 itemCount: savedItems.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(title: Text(savedItems[index]));
//                 },
//               ),
//       ),
//     );
//   }
// }