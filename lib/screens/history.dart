import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nutrition_app/models/models.dart';
import 'package:nutrition_app/screens/tips.dart';
import 'package:nutrition_app/screens/user_infor.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _userID = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  // get the user ID
  void getData() async {
    final User? user = _auth.currentUser;
    // ignore: no_leading_underscores_for_local_identifiers
    final _uid = user?.uid;
    setState(() {
      _userID = _uid!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your History",
          style: TextStyle(fontSize: 12),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                // Perform delete action here
                removeActivityFromDatabase(); // Pass the activity ID to the remove function
              } else if (value == "content") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ContentScreen()));
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete history'),
              ),
              const PopupMenuItem<String>(
                value: 'content',
                child: Text('About Diabetes'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: StreamBuilder<DatabaseEvent>(
            stream: FirebaseDatabase.instance
                .ref()
                .child('recentHistory')
                .child(_userID)
                .onValue,
            builder:
                (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                return const Center(
                  child: Text(
                    'Your have no history Available!.',
                    style: TextStyle(
                      color: Color(0xFF495F75),
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              DatabaseEvent databaseEvent = snapshot.data!;
              dynamic data = databaseEvent.snapshot.value;

              // Convert the data into a list of activity objects
              List<Activity> activities = [];
              if (data != null) {
                data.forEach((key, value) {
                  String date = value['date'];
                  String activityId = value['activityId'];
                  String time = value['time'];
                  String title = value['title'];

                  Activity activity = Activity(
                    date: date,
                    activityId: activityId,
                    time: time,
                    title: title,
                  );
                  activities.add(activity);
                });
                // Sort activities in descending order based on date
                activities.sort((a, b) => b.date.compareTo(a.date));
              }

              return ListView.builder(
                itemCount: activities.length,
                itemBuilder: (BuildContext context, int index) {
                  Activity activity = activities[index];

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.all(1),
                    elevation: 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: SizedBox(
                        height: 55.0,
                        child: InkWell(
                          splashColor: const Color(0xFF00BFA5),
                          onTap: () {},
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.title,
                                  style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity.time,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      activity.date,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const UserDataScreen()));
        },
        foregroundColor: Colors.white,
        label: const Text("Recommendation"),
      ),
      // floatingActionButton: const SpeedDial(
      //   backgroundColor: Colors.green,
      //   foregroundColor: Colors.white,
      //   icon: Icons.water_drop_rounded,
      // ),
    );
  }

  void removeActivityFromDatabase() {
    final DatabaseReference activityRef =
        FirebaseDatabase.instance.ref().child('recentHistory').child(_userID);
    activityRef.remove();
  }
}
