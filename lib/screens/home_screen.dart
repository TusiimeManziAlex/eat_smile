import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nutrition_app/db/Boxes.dart';
import 'package:nutrition_app/models/meal/meal.dart';
import 'package:nutrition_app/models/water/water.dart';
import 'package:nutrition_app/pages/detailScreen.dart';
import 'package:nutrition_app/screens/main_screen.dart';
import 'package:tflite/tflite.dart';
import 'package:nutrition_app/providers/preferences.dart';
import 'package:nutrition_app/widgets/info_row.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  File? _image;
  List? _result;

  String _userName = '';
  String _userID = '';

  String fruitName = '';

  @override
  void initState() {
    super.initState();
    getData();
    loadModelData().then((value) {
      setState(() {});
    });
  }

  loadModelData() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  // get the user data
  void getData() async {
    final User? user = _auth.currentUser;
    // ignore: no_leading_underscores_for_local_identifiers
    final _uid = user?.uid;

    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection("users").doc(_uid).get();
    setState(() {
      _userName = userDoc.get("lastName");
      _userID = _uid!;
    });
  }

  // From camera
  takeImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
//image is null, then return
    if (image == null) return null;
    File? img = File(image.path);
    setState(() {
      _image = img;
    });
  }

  // From Gallery
  pickGalleryImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//image is null, then return
    if (image == null) return null;
    File? img = File(image.path);
    setState(() {
      _image = img;
    });
  }

  List<Meal> getTodaysMeals() {
    final currentDate = formatDate(DateTime.now(), [dd, '-', mm, '-', yyyy]);
    final mealsBox = Boxes.getMealsBox();
    final meals = mealsBox.values.toList().cast<Meal>();
    return meals
        .where((meal) =>
            currentDate == formatDate(meal.dateTime, [dd, '-', mm, '-', yyyy]))
        .toList()
        .cast<Meal>();
  }

  double calcTodaysCals() {
    final meals = getTodaysMeals();
    double calories = 0;
    for (var meal in meals) {
      calories += ((meal.food.calories / 100) * meal.quantity);
    }
    return calories;
  }

  double calcNutritionPercentage() {
    double calories = calcTodaysCals();
    print(calories);
    if (calories > context.read<Preferences>().calories) {
      return 1.0;
    }
    return (calories / context.read<Preferences>().calories);
  }

  List<Water> getTodaysWater() {
    final currentDate = formatDate(DateTime.now(), [dd, '-', mm, '-', yyyy]);
    final watersBox = Boxes.getWaterBox();
    final waters = watersBox.values.toList().cast<Water>();
    return waters
        .where((water) =>
            currentDate == formatDate(water.datetime, [dd, '-', mm, '-', yyyy]))
        .toList()
        .cast<Water>();
  }

  double getWaterAmount() {
    final waters = getTodaysWater();
    if (waters.isEmpty) return 0.0;
    return waters.first.amount;
  }

  double calcWaterPercentage() {
    final waterAmount = getWaterAmount();
    if (waterAmount < 0) {
      return 0.0;
    }
    if (waterAmount > context.read<Preferences>().waterAmount) {
      return 1.0;
    }
    return (waterAmount / context.read<Preferences>().waterAmount);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: _image != null
            ? testImage(size, _image)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Consumer<Preferences>(
                    builder: ((context, value, child) =>
                        Text("Welcome back, $_userName",
                            // ignore: deprecated_member_use
                            style: Theme.of(context).textTheme.headline1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      "Eat the right amount of fruits and stay hydrated through the day",
                      style: Theme.of(context)
                          .textTheme
                          // ignore: deprecated_member_use
                          .bodyText1!
                          .copyWith(fontWeight: FontWeight.w300),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      'Capture Your Fruit',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: ValueListenableBuilder(
                        valueListenable: Boxes.getMealsBox().listenable(),
                        builder: (context, box, _) {
                          return InkWell(
                            onTap: () {
                              takeImage();
                            },
                            child: InfoRow(
                              "Upload Fruit Image",
                              "From Camera",
                              "assets/icons/nutrition_icon.png",
                              Colors.green,
                              calcNutritionPercentage(),
                            ),
                          );
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: ValueListenableBuilder(
                      valueListenable: Boxes.getWaterBox().listenable(),
                      builder: (context, box, _) => InkWell(
                        onTap: () {
                          pickGalleryImage();
                        },
                        child: InfoRow(
                          "Upload Fruit Image",
                          "From Gallery",
                          "assets/icons/nutrition_icon.png",
                          Colors.blue,
                          calcWaterPercentage(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _image = null;
          });
        },
        foregroundColor: Colors.white,
        label: const Text("Reflesh"),
        icon: const Icon(Icons.refresh),
      ),
      // floatingActionButton: const SpeedDial(
      //   backgroundColor: Colors.green,
      //   foregroundColor: Colors.white,
      //   icon: Icons.water_drop_rounded,
      // ),
    );
  }

  testImage(size, image) {
    return SingleChildScrollView(
      child: SizedBox(
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.40,
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(
                      image!,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.40,
              width: double.infinity,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36.0),
                    topRight: Radius.circular(36.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      // _result != null
                      //     ? Text(
                      //         'This fruit is ${_result![0]['label']}.',
                      //         style:
                      //             const TextStyle(fontWeight: FontWeight.bold),
                      //       )
                      //     :
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 60),
                            elevation: 4,
                            primary: const Color(0xFF49A329),
                          ),
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                            });
                            detectFruit();
                            Future.delayed(const Duration(seconds: 3), () {
                              isLoading = false;
                            });
                          },
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
                              : const Text(
                                  'Analyze Fruit',
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void detectFruit() async {
    if (_image != null) {
      try {
        _result = await Tflite.runModelOnImage(
          path: _image!.path,
          numResults: 2,
          threshold: 0.6,
          imageMean: 127.5,
          imageStd: 127.5,
        );
        setState(() {
          fruitName = _result![0]['label'];
        });

        if (fruitName == "apple") {
          // Create the history entry
          final DateTime now = DateTime.now();
          final String date = DateFormat('MMM d, yyyy | EEEEEE').format(now);
          final String time = DateFormat.jm().format(now);
          String title = fruitName;

          // Get a reference to the "recentHistories" node in the Realtime Database
          final DatabaseReference recentHistoriesRef = FirebaseDatabase.instance
              .ref()
              .child('recentHistory')
              .child(_userID);

          // Generate a unique key for the new history entry
          final DatabaseReference newHistoryRef = recentHistoriesRef.push();
          final String? historyId = newHistoryRef.key;

          try {
            // Set the values of the fields for the new history entry
            await newHistoryRef.set({
              'activityId': historyId,
              'date': date,
              'time': time,
              'title': title,
            });
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(1102644),
              ),
            );
          } catch (error) {
            // Handle any errors that may occur during the database update
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Transfer Failed'),
                  content: const Text(
                      'There was an error while keeping records. Please try again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else if (fruitName == "banana") {
          // Create the history entry
          final DateTime now = DateTime.now();
          final String date = DateFormat('MMM d, yyyy | EEEEEE').format(now);
          final String time = DateFormat.jm().format(now);
          String title = fruitName;

          // Get a reference to the "recentHistories" node in the Realtime Database
          final DatabaseReference recentHistoriesRef = FirebaseDatabase.instance
              .ref()
              .child('recentHistory')
              .child(_userID);

          // Generate a unique key for the new history entry
          final DatabaseReference newHistoryRef = recentHistoriesRef.push();
          final String? historyId = newHistoryRef.key;

          try {
            // Set the values of the fields for the new history entry
            await newHistoryRef.set({
              'activityId': historyId,
              'date': date,
              'time': time,
              'title': title,
            });
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(1102653),
              ),
            );
          } catch (error) {
            // Handle any errors that may occur during the database update
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Transfer Failed'),
                  content: const Text(
                      'There was an error while keeping records. Please try again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else if (fruitName == "blackberry") {
          // Create the history entry
          final DateTime now = DateTime.now();
          final String date = DateFormat('MMM d, yyyy | EEEEEE').format(now);
          final String time = DateFormat.jm().format(now);
          String title = fruitName;

          // Get a reference to the "recentHistories" node in the Realtime Database
          final DatabaseReference recentHistoriesRef = FirebaseDatabase.instance
              .ref()
              .child('recentHistory')
              .child(_userID);

          // Generate a unique key for the new history entry
          final DatabaseReference newHistoryRef = recentHistoriesRef.push();
          final String? historyId = newHistoryRef.key;

          try {
            // Set the values of the fields for the new history entry
            await newHistoryRef.set({
              'activityId': historyId,
              'date': date,
              'time': time,
              'title': title,
            });
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(1102700),
              ),
            );
          } catch (error) {
            // Handle any errors that may occur during the database update
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Transfer Failed'),
                  content: const Text(
                      'There was an error while keeping records. Please try again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else if (fruitName == "blueberry") {
          // Create the history entry
          final DateTime now = DateTime.now();
          final String date = DateFormat('MMM d, yyyy | EEEEEE').format(now);
          final String time = DateFormat.jm().format(now);
          String title = fruitName;

          // Get a reference to the "recentHistories" node in the Realtime Database
          final DatabaseReference recentHistoriesRef = FirebaseDatabase.instance
              .ref()
              .child('recentHistory')
              .child(_userID);

          // Generate a unique key for the new history entry
          final DatabaseReference newHistoryRef = recentHistoriesRef.push();
          final String? historyId = newHistoryRef.key;

          try {
            // Set the values of the fields for the new history entry
            await newHistoryRef.set({
              'activityId': historyId,
              'date': date,
              'time': time,
              'title': title,
            });
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(1102702),
              ),
            );
          } catch (error) {
            // Handle any errors that may occur during the database update
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Transfer Failed'),
                  content: const Text(
                      'There was an error while keeping records. Please try again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else if (fruitName == "gauva") {
          // Create the history entry
          final DateTime now = DateTime.now();
          final String date = DateFormat('MMM d, yyyy | EEEEEE').format(now);
          final String time = DateFormat.jm().format(now);
          String title = fruitName;

          // Get a reference to the "recentHistories" node in the Realtime Database
          final DatabaseReference recentHistoriesRef = FirebaseDatabase.instance
              .ref()
              .child('recentHistory')
              .child(_userID);

          // Generate a unique key for the new history entry
          final DatabaseReference newHistoryRef = recentHistoriesRef.push();
          final String? historyId = newHistoryRef.key;

          try {
            // Set the values of the fields for the new history entry
            await newHistoryRef.set({
              'activityId': historyId,
              'date': date,
              'time': time,
              'title': title,
            });
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(1102666),
              ),
            );
          } catch (error) {
            // Handle any errors that may occur during the database update
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Transfer Failed'),
                  content: const Text(
                      'There was an error while keeping records. Please try again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else if (fruitName == "grapes") {
          // Create the history entry
          final DateTime now = DateTime.now();
          final String date = DateFormat('MMM d, yyyy | EEEEEE').format(now);
          final String time = DateFormat.jm().format(now);
          String title = fruitName;

          // Get a reference to the "recentHistories" node in the Realtime Database
          final DatabaseReference recentHistoriesRef = FirebaseDatabase.instance
              .ref()
              .child('recentHistory')
              .child(_userID);

          // Generate a unique key for the new history entry
          final DatabaseReference newHistoryRef = recentHistoriesRef.push();
          final String? historyId = newHistoryRef.key;

          try {
            // Set the values of the fields for the new history entry
            await newHistoryRef.set({
              'activityId': historyId,
              'date': date,
              'time': time,
              'title': title,
            });
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(1102665),
              ),
            );
          } catch (error) {
            // Handle any errors that may occur during the database update
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: const Text(
                      'There was an error while keeping records. Please try again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else if (fruitName == "mango") {
          // Create the history entry
          final DateTime now = DateTime.now();
          final String date = DateFormat('MMM d, yyyy | EEEEEE').format(now);
          final String time = DateFormat.jm().format(now);
          String title = fruitName;

          // Get a reference to the "recentHistories" node in the Realtime Database
          final DatabaseReference recentHistoriesRef = FirebaseDatabase.instance
              .ref()
              .child('recentHistory')
              .child(_userID);

          // Generate a unique key for the new history entry
          final DatabaseReference newHistoryRef = recentHistoriesRef.push();
          final String? historyId = newHistoryRef.key;

          try {
            // Set the values of the fields for the new history entry
            await newHistoryRef.set({
              'activityId': historyId,
              'date': date,
              'time': time,
              'title': title,
            });
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(1102670),
              ),
            );
          } catch (error) {
            // Handle any errors that may occur during the database update
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Transfer Failed'),
                  content: const Text(
                      'There was an error while keeping records. Please try again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else if (fruitName == "orange") {
          // Create the history entry
          final DateTime now = DateTime.now();
          final String date = DateFormat('MMM d, yyyy | EEEEEE').format(now);
          final String time = DateFormat.jm().format(now);
          String title = fruitName;

          // Get a reference to the "recentHistories" node in the Realtime Database
          final DatabaseReference recentHistoriesRef = FirebaseDatabase.instance
              .ref()
              .child('recentHistory')
              .child(_userID);

          // Generate a unique key for the new history entry
          final DatabaseReference newHistoryRef = recentHistoriesRef.push();
          final String? historyId = newHistoryRef.key;

          try {
            // Set the values of the fields for the new history entry
            await newHistoryRef.set({
              'activityId': historyId,
              'date': date,
              'time': time,
              'title': title,
            });
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(1102597),
              ),
            );
          } catch (error) {
            // Handle any errors that may occur during the database update
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Transfer Failed'),
                  content: const Text(
                      'There was an error while keeping records. Please try again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else if (fruitName == "papaya") {
          // Create the history entry
          final DateTime now = DateTime.now();
          final String date = DateFormat('MMM d, yyyy | EEEEEE').format(now);
          final String time = DateFormat.jm().format(now);
          String title = fruitName;

          // Get a reference to the "recentHistories" node in the Realtime Database
          final DatabaseReference recentHistoriesRef = FirebaseDatabase.instance
              .ref()
              .child('recentHistory')
              .child(_userID);

          // Generate a unique key for the new history entry
          final DatabaseReference newHistoryRef = recentHistoriesRef.push();
          final String? historyId = newHistoryRef.key;

          try {
            // Set the values of the fields for the new history entry
            await newHistoryRef.set({
              'activityId': historyId,
              'date': date,
              'time': time,
              'title': title,
            });
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(1102674),
              ),
            );
          } catch (error) {
            // Handle any errors that may occur during the database update
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Transfer Failed'),
                  content: const Text(
                      'There was an error while keeping records. Please try again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else if (fruitName == "passion") {
          // Create the history entry
          final DateTime now = DateTime.now();
          final String date = DateFormat('MMM d, yyyy | EEEEEE').format(now);
          final String time = DateFormat.jm().format(now);
          String title = fruitName;

          // Get a reference to the "recentHistories" node in the Realtime Database
          final DatabaseReference recentHistoriesRef = FirebaseDatabase.instance
              .ref()
              .child('recentHistory')
              .child(_userID);

          // Generate a unique key for the new history entry
          final DatabaseReference newHistoryRef = recentHistoriesRef.push();
          final String? historyId = newHistoryRef.key;

          try {
            // Set the values of the fields for the new history entry
            await newHistoryRef.set({
              'activityId': historyId,
              'date': date,
              'time': time,
              'title': title,
            });
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(1102676),
              ),
            );
          } catch (error) {
            // Handle any errors that may occur during the database update
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Transfer Failed'),
                  content: const Text(
                      'There was an error while keeping records. Please try again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else if (fruitName == "pineapple") {
          // Create the history entry
          final DateTime now = DateTime.now();
          final String date = DateFormat('MMM d, yyyy | EEEEEE').format(now);
          final String time = DateFormat.jm().format(now);
          String title = fruitName;

          // Get a reference to the "recentHistories" node in the Realtime Database
          final DatabaseReference recentHistoriesRef = FirebaseDatabase.instance
              .ref()
              .child('recentHistory')
              .child(_userID);

          // Generate a unique key for the new history entry
          final DatabaseReference newHistoryRef = recentHistoriesRef.push();
          final String? historyId = newHistoryRef.key;

          try {
            // Set the values of the fields for the new history entry
            await newHistoryRef.set({
              'activityId': historyId,
              'date': date,
              'time': time,
              'title': title,
            });
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(1102688),
              ),
            );
          } catch (error) {
            // Handle any errors that may occur during the database update
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Transfer Failed'),
                  content: const Text(
                      'There was an error while keeping records. Please try again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else if (fruitName == "tomato") {
          // Create the history entry
          final DateTime now = DateTime.now();
          final String date = DateFormat('MMM d, yyyy | EEEEEE').format(now);
          final String time = DateFormat.jm().format(now);
          String title = fruitName;

          // Get a reference to the "recentHistories" node in the Realtime Database
          final DatabaseReference recentHistoriesRef = FirebaseDatabase.instance
              .ref()
              .child('recentHistory')
              .child(_userID);

          // Generate a unique key for the new history entry
          final DatabaseReference newHistoryRef = recentHistoriesRef.push();
          final String? historyId = newHistoryRef.key;

          try {
            // Set the values of the fields for the new history entry
            await newHistoryRef.set({
              'activityId': historyId,
              'date': date,
              'time': time,
              'title': title,
            });
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(1103280),
              ),
            );
          } catch (error) {
            // Handle any errors that may occur during the database update
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Transfer Failed'),
                  content: const Text(
                      'There was an error while keeping records. Please try again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else if (fruitName == "watermelon") {
          // Create the history entry
          final DateTime now = DateTime.now();
          final String date = DateFormat('MMM d, yyyy | EEEEEE').format(now);
          final String time = DateFormat.jm().format(now);
          String title = fruitName;

          // Get a reference to the "recentHistories" node in the Realtime Database
          final DatabaseReference recentHistoriesRef = FirebaseDatabase.instance
              .ref()
              .child('recentHistory')
              .child(_userID);

          // Generate a unique key for the new history entry
          final DatabaseReference newHistoryRef = recentHistoriesRef.push();
          final String? historyId = newHistoryRef.key;

          try {
            // Set the values of the fields for the new history entry
            await newHistoryRef.set({
              'activityId': historyId,
              'date': date,
              'time': time,
              'title': title,
            });
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(1102698),
              ),
            );
          } catch (error) {
            // Handle any errors that may occur during the database update
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Transfer Failed'),
                  content: const Text(
                      'There was an error while keeping records. Please try again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else if (fruitName == "not recognized") {
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error!"),
                content: const Text("The fruit image is not recognized!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MainScreen())); // Close the dialog
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        } else {
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error!"),
                content:
                    const Text("Unknown error happen while loading the model."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("No image"),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }

      setState(() {});
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("No image"),
            content: const Text("Please input the fruit image !"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
}
