import 'package:flutter/material.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Educational Content',
          style: TextStyle(fontSize: 12),
        ),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              Text(
                'What is diabetes?.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 2,
                ),
              ),
              Text(
                'Diabetes is a serious complex condition which can affect the entire body. '
                'Diabetes requires daily self care and if complications develop, diabetes can have a significant impact on quality of life and can reduce life expectancy.'
                'While there is currently no cure for diabetes, you can live an enjoyable life by learning about the condition and effectively managing it.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
              ),
              Text(
                'Best fruits for Diabetic patients',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 2,
                ),
              ),
              Text(
                "Certain fruits have lower glycemic index and hence can be consumed without getting high blood sugars."
                "Here are the list of Top 6 fruits that are safe for Diabetic patients",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
              ),
              Text(
                '\n. Cherries',
              ),
              Text(
                '\n. Grapefruit',
              ),
              Text(
                '\n. Berries',
              ),
              Text(
                '\n. Prunes and Plums',
              ),
              Text(
                '\n. Apples',
              ),
              Text(
                '\n. Pears',
              ),
              Text(
                'Worst fruits for Diabetic patients',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 2,
                ),
              ),
              Text(
                "Though generally fruits are considered good for health, certain fruits can cause havoc when it comes to blood sugar levels."
                "These fruits have a high glycemic index which leads to sudden rise of blood sugars which can be very dangerous."
                "Here are the top 6 fruits to be avoided by those who have Diabetes.(Glycemic Index is given in brackets-higher the value,faster it will raise blood sugar)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
              ),
              Text(
                '\n. Watermelon',
              ),
              Text(
                '\n. Chikoo/sapodilla',
              ),
              Text(
                '\n. Pineapple',
              ),
              Text(
                '\n. Raisins',
              ),
              Text(
                '\n. Bananas',
              ),
              Text(
                '\n. Mangoes',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
