import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutrition_app/db/Boxes.dart';
import 'package:nutrition_app/models/meal/meal.dart';
import 'package:nutrition_app/models/water/water.dart';
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
  File? _image;
  List? _result;

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
                    builder: ((context, value, child) => Text("Welcome back,",
                        // ignore: deprecated_member_use
                        style: Theme.of(context).textTheme.headline1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      "Eat the right amount of food and stay hydrated through the day",
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
                      'Capture Your Meal',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.orangeAccent),
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
                              "Upload Meal Image",
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
                          "Upload Meal Image",
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
      floatingActionButton: FloatingActionButton.extended(onPressed: () {
        setState(() {
          _image = null;
        });

      },
      foregroundColor: Colors.white,
      label: const Text("Reflesh"),
      icon: const  Icon(Icons.refresh) ,
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
                      _result != null
                          ? Text(
                              'This banknote is ${_result![0]['label']}.',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 60),
                                  elevation: 4,
                                  primary: const Color(0xFF49A329),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  'Analyze Meal',
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
}
