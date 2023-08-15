// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrition_app/pages/darsh.dart';
import 'package:nutrition_app/screens/history.dart';
import 'package:nutrition_app/screens/home_screen.dart';
import 'package:nutrition_app/screens/login_page.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final int _index = 0;
  // ignore: prefer_final_fields
  PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    DarshBoardScreen(),
  ];

  final List<Widget> _subScreens = const [
    HomeScreen(),
    HistoryScreen(),
    DarshBoardScreen(),
  ];

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Column(
          children: [
            SvgPicture.asset(
              "assets/icons/home_icon.svg",
              color: _controller.index == 0
                  ? Theme.of(context).primaryColor
                  : Colors.grey.withOpacity(0.5),
              width: 15,
            ),
            Text(
              "Home",
              style: TextStyle(
                fontSize: 12, // Adjust the font size as needed
                color: _controller.index == 0
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
        
        title: ("Home"),
        activeColorPrimary: Theme.of(context).primaryColor,
        inactiveColorPrimary: Colors.grey.withOpacity(0.5),
      ),
      PersistentBottomNavBarItem(
        icon: Column(
          children: [
            SvgPicture.asset(
              "assets/icons/food_icon.svg",
              color: _controller.index == 1
                  ? Theme.of(context).primaryColor
                  : Colors.grey.withOpacity(0.5),
              width: 15,
            ),
            Text(
              "History",
              style: TextStyle(
                fontSize: 12, // Adjust the font size as needed
                color: _controller.index == 1
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
        title: ("History"),
        activeColorPrimary: Theme.of(context).primaryColor,
        inactiveColorPrimary: Colors.grey.withOpacity(0.5),
      ),
      PersistentBottomNavBarItem(
        icon: Column(
          children: [
            SvgPicture.asset(
              "assets/icons/add_icon.svg",
              color: _controller.index == 2
                  ? Theme.of(context).primaryColor
                  : Colors.grey.withOpacity(0.5),
              width: 15,
            ),
            Text(
              "Fruits",
              style: TextStyle(
                fontSize: 12, // Adjust the font size as needed
                color: _controller.index == 2
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
        title: ("Fruit List"),
        activeColorPrimary: Theme.of(context).primaryColor,
        inactiveColorPrimary: Colors.grey.withOpacity(0.5),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Diet Nutrition App ", style: TextStyle(color: Colors.white))
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              _showProfileLogoutDialog(context);
              // Implement user profile navigation here.
            },
          ),
        ],
      ),
      body: _index < 4
          ? PersistentTabView(
              context,
              controller: _controller,
              screens: _screens,
              items: _navBarsItems(),
              confineInSafeArea: true,
              backgroundColor: Theme.of(context).bottomAppBarColor,
              handleAndroidBackButtonPress: true,
              resizeToAvoidBottomInset:
                  true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
              stateManagement: true,
              hideNavigationBarWhenKeyboardShows: true,
              decoration: NavBarDecoration(
                borderRadius: BorderRadius.circular(10.0),
                colorBehindNavBar: Theme.of(context).bottomAppBarColor,
              ),
              popAllScreensOnTapOfSelectedTab: true,
              popActionScreens: PopActionScreensType.all,
              itemAnimationProperties: const ItemAnimationProperties(
                // Navigation Bar's items animation properties.
                duration: Duration(milliseconds: 200),
                curve: Curves.ease,
              ),
              screenTransitionAnimation: const ScreenTransitionAnimation(
                // Screen transition animation on change of selected tab.
                animateTabTransition: true,
                curve: Curves.ease,
                duration: Duration(milliseconds: 200),
              ),
              navBarStyle: NavBarStyle.style12,
              onItemSelected: (index) {},
            )
          : _subScreens[_index],
    );
  }

  void _showProfileLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Profile Options"),
        content: const Text("Choose an option:"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => UserProfileScreen()),
              // );
            },
            child: const Text("Go to Profile"),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignInScreen()));
              });
            },
            child: const Text("Logout"),
          ),
        ],
      );
    },
  );
}
}
