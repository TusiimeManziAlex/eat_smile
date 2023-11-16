import 'package:flutter/material.dart';
import 'package:nutrition_app/screens/main_screen.dart';

class UserDataScreen extends StatefulWidget {
  const UserDataScreen({super.key});

  @override
  State<UserDataScreen> createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  double sugar = 0.0;
  String? time;
  String? diet;
  String? fruitSuggestion; // To store the suggested fruit

  // Define your conditional statements to suggest fruits based on user input.

  void suggestFruit() {
    if (time == 'Breakfast') {
      if (sugar < 80) {
        // Suggest fruits for low blood sugar during breakfast.
        fruitSuggestion = 'Try an apple or some berries.';
      } else {
        // Suggest fruits for other breakfast scenarios.
        fruitSuggestion = 'Consider having a banana or some oatmeal.';
      }
    } else if (time == 'lunch') {
      if (diet == 'Low-Carb Diet') {
        // Suggest low-carb fruits for lunch if the user prefers a low-carb diet.
        fruitSuggestion = 'Opt for strawberries or cucumber slices.';
      } else {
        // Suggest other fruits for lunch.
        fruitSuggestion = 'Enjoy a serving of mixed fruit salad.';
      }
    } else if (time == 'dinner') {
      if (diet == 'Vegan') {
        // Suggest vegan-friendly fruits for dinner if the user is vegan.
        fruitSuggestion = 'Have a bowl of mixed berries or a grapefruit.';
      } else {
        // Suggest other fruits for dinner.
        fruitSuggestion = 'Try a small serving of pineapple or watermelon.';
      }
    } else if (time == 'snack') {
      if (sugar < 70) {
        // Suggest fruits for low blood sugar during snacks.
        fruitSuggestion =
            'Grab a banana or some dried apricots for a quick energy boost.';
      } else if (diet == 'High-Fiber Diet') {
        // Suggest high-fiber fruits for snacks if the user prefers a high-fiber diet.
        fruitSuggestion =
            'Snack on apple slices or pear wedges for added fiber.';
      } else {
        // Suggest other fruits for snacks.
        fruitSuggestion =
            'Consider having a small orange or a handful of grapes.';
      }
    }

    // Add a condition to recommend seeing a doctor based on user data.
    if (sugar > 200 || (time == 'snack' && sugar > 150)) {
      fruitSuggestion =
          '\n\nPlease consult with a doctor regarding your blood sugar levels.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('User Data', style: TextStyle(fontSize: 12)),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  cursorColor: const Color(0xFF8352A1),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                    labelText: 'Current Blood sugar level (mg/dL)',
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 1, color: Color(0xFF49A329)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 1, color: Color(0xFF8352A1)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 1, color: Color(0xFF8352A1)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    sugar = double.tryParse(value) ?? 0.0;
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter the Current Blood sugar level';
                    }

                    // Return null if the entered ammount is valid
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                    labelText: 'Time of day',
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 1, color: Color(0xFF49A329)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 1, color: Color(0xFF8352A1)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 1, color: Color(0xFF8352A1)),
                    ),
                  ),
                  value: time,
                  onChanged: (value) {
                    setState(() {
                      time = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select time of day.';
                    }
                    return null;
                  },
                  items:
                      ['breakfast', 'lunch', 'dinner', 'snack'].map((gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                    labelText: 'Dietary preferences',
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 1, color: Color(0xFF49A329)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 1, color: Color(0xFF8352A1)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 1, color: Color(0xFF8352A1)),
                    ),
                  ),
                  value: diet,
                  onChanged: (value) {
                    setState(() {
                      diet = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select Dietary preferences.';
                    }
                    return null;
                  },
                  items: [
                    'Low-Carb Diet',
                    'Vegan',
                    'High-Fiber Diet'
                  ].map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: double.maxFinite,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF49A329),
                    ),
                    child: isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            // ignore: prefer_const_literals_to_create_immutables
                            children: [
                              Text(
                                'Loading...',
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ],
                          )
                        : const Text('Next'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });
                        // Call the suggestFruit function to determine the fruit suggestion.
                       await Future.delayed(const Duration(seconds: 5), () {
                          suggestFruit();
                          setState(() {
                            isLoading = false;
                          });
                        });

                        // Show the suggestion to the user.
                        // ignore: use_build_context_synchronously
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Fruit Suggestion'),
                              content: Text(fruitSuggestion ??
                                  'No suggestion available.',style: const TextStyle(fontSize: 18,fontWeight: FontWeight.normal),),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MainScreen()));
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
