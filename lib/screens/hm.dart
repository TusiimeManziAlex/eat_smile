// import 'package:flutter/material.dart';

// class HomePageScreen extends StatelessWidget {
//   const HomePageScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Diet App'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.account_circle),
//             onPressed: () {
//               // Implement user profile navigation here.
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 20),
//             const Text(
//               'Capture Your Meal',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton.icon(
//               onPressed: () {
//                 // Implement camera capture functionality here.
//               },
//               icon: Icon(Icons.camera_alt),
//               label: Text('Capture Meal Image'),
//             ),
//             SizedBox(height: 20),
//             LatestMealInfo(),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Implement analyze meal functionality here.
//               },
//               child: Text('Analyze Meal'),
//             ),
//             SizedBox(height: 20),
//             TipsAndSuggestions(),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class LatestMealInfo extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Replace the dummy data with actual meal information from the app state or database.
//     String mealName = 'Chicken Salad';
//     String dateTime = 'July 6, 2023, 12:30 PM';
//     String nutrientSummary = 'Calories: 350 kcal | Protein: 25g | Carbs: 10g';

//     return Column(
//       children: [
//         const Text(
//           'Latest Meal Information',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 10),
//         Text('Meal: $mealName'),
//         Text('Date & Time: $dateTime'),
//         Text('Nutrient Summary: $nutrientSummary'),
//       ],
//     );
//   }
// }

// class TipsAndSuggestions extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Replace the dummy tips with actual daily tips or meal suggestions from the app.
//     List<String> tips = [
//       'Include more vegetables in your meals.',
//       'Drink plenty of water throughout the day.',
//       'Try to have a balanced intake of macronutrients.',
//     ];

//     return Column(
//       children: [
//         const Text(
//           'Tips and Suggestions',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 10),
//         for (String tip in tips) Text('• $tip'),
//       ],
//     );
//   }
// }









