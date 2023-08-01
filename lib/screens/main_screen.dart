// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrition_app/screens/add_food_screen.dart';
import 'package:nutrition_app/screens/food_screen.dart';
import 'package:nutrition_app/screens/home_screen.dart';
import 'package:nutrition_app/screens/statistics_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final int _index = 0;
  // ignore: prefer_final_fields
  PersistentTabController _controller = PersistentTabController(initialIndex: 0);
  

  
 
  final List<Widget> _screens = const [
    HomeScreen(),
    FoodScreen(),
    AddFoodScreen(),
  ];

  final List<Widget> _subScreens = const [
    HomeScreen(),
    FoodScreen(),
    AddFoodScreen(),
    StatisticsScreen(),
  ];

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
        PersistentBottomNavBarItem(
            icon: SvgPicture.asset(
              "assets/icons/home_icon.svg",
              color: _controller.index == 0 ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.5),
              width: 15,
            ),
            title: ("Home"),
            activeColorPrimary: Theme.of(context).primaryColor,
            inactiveColorPrimary: Colors.grey.withOpacity(0.5),
        ),
        PersistentBottomNavBarItem(
            icon: SvgPicture.asset(
              "assets/icons/food_icon.svg",
              color: _controller.index == 1 ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.5),
              width: 15,
            ),
            title: ("Foods"),
            activeColorPrimary: Theme.of(context).primaryColor,
            inactiveColorPrimary: Colors.grey.withOpacity(0.5),
        ),
        PersistentBottomNavBarItem(
            icon: SvgPicture.asset(
              "assets/icons/add_icon.svg",
              color: _controller.index == 2 ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.5),              
              width: 15,
            ),
            title: ("Add Food"),
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
              Text(
                "Diet Nutrition App ",
                style: TextStyle(color: Colors.white)
              )
            ],
          ),

          actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Implement user profile navigation here.
            },
          ),
        ],
          
        ),
        body: _index < 4 ? PersistentTabView(
          context,
          controller: _controller,
          screens: _screens,
          items: _navBarsItems(),
          confineInSafeArea: true,
          backgroundColor: Theme.of(context).bottomAppBarColor,
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
          stateManagement: true,
          hideNavigationBarWhenKeyboardShows: true, 
          decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(10.0),
            colorBehindNavBar: Theme.of(context).bottomAppBarColor,
          ),
          popAllScreensOnTapOfSelectedTab: true,
          popActionScreens: PopActionScreensType.all,
          itemAnimationProperties: const ItemAnimationProperties( // Navigation Bar's items animation properties.
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: const ScreenTransitionAnimation( // Screen transition animation on change of selected tab.
            animateTabTransition: true,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          ),
          navBarStyle: NavBarStyle.style12,
          onItemSelected: (index) {
          },
        ) : _subScreens[_index],
      );
    
  }

}