import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/screens/favourite_screen.dart';
import 'package:multi_vending_grocery_app/screens/home_screen.dart';
import 'package:multi_vending_grocery_app/screens/my_orders_screen.dart';
import 'package:multi_vending_grocery_app/screens/profile_screen.dart';
import 'package:multi_vending_grocery_app/widgets/cart/cart_notification.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);
  static const String id = 'main-screen-page';

  @override
  Widget build(BuildContext context) {
    PersistentTabController _controller;
    _controller = PersistentTabController(initialIndex: 0);

    List<Widget> _buildScreens() {
      return [
        const HomeScreen(),
        const FavouriteScreen(),
        const MyOrdersScreen(),
        const ProfileScreen(),
      ];
    }

    List<PersistentBottomNavBarItem> _navBarsItems() {
      return [
        PersistentBottomNavBarItem(
          icon: Image.asset('assets/logo.png'),
          title: ("Home"),
          activeColorPrimary: Theme.of(context).primaryColor,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.square_favorites_alt),
          title: ("My Favourites"),
          activeColorPrimary: Theme.of(context).primaryColor,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.bag),
          title: ("My Orders"),
          activeColorPrimary: Theme.of(context).primaryColor,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.profile_circled),
          title: ("My Account"),
          activeColorPrimary: Theme.of(context).primaryColor,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
      ];
    }

    return Scaffold(
      floatingActionButton: const Padding(
        padding: EdgeInsets.only(bottom: 56),
        child: CartNotification(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: PersistentTabView(
        context,
        navBarHeight: 56,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        // Default is Colors.white.
        handleAndroidBackButtonPress: true,
        // Default is true.
        resizeToAvoidBottomInset: true,
        // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
        stateManagement: true,
        // Default is true.
        hideNavigationBarWhenKeyboardShows: true,
        // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
        decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(0.0),
            colorBehindNavBar: Colors.white,
            border: Border.all(color: Colors.black54)),
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
        navBarStyle:
            NavBarStyle.style9, // Choose the nav bar style with this property.
      ),
    );
  }
}
