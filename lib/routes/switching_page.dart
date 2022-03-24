import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:pawgo/assets/custom_colors.dart';
import 'package:pawgo/routes/profile_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class SwitchPage extends StatefulWidget {
  const SwitchPage({Key? key}) : super(key: key);

  @override
  _SwitchPageState createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      navBarStyle: NavBarStyle.style1,
      resizeToAvoidBottomInset: true,
      hideNavigationBarWhenKeyboardShows: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white
      ),
      screens: [
        ProfilePage(),
        ProfilePage(),
        ProfilePage(),
        ProfilePage(),
        ProfilePage(),
      ],
      items: [
        PersistentBottomNavBarItem(
            activeColorPrimary: CustomColors.pawrange,
            icon: FaIcon(FontAwesomeIcons.home), title: 'Home'),
        PersistentBottomNavBarItem(
            activeColorPrimary: CustomColors.pawrange,
            icon: FaIcon(FontAwesomeIcons.search), title: 'Search'),
        PersistentBottomNavBarItem(
            activeColorPrimary: CustomColors.pawrange,
            icon: FaIcon(FontAwesomeIcons.dog), title: 'Dog'),
        PersistentBottomNavBarItem(
            activeColorPrimary: CustomColors.pawrange,
            icon: FaIcon(FontAwesomeIcons.cat), title: 'Cat'),
        PersistentBottomNavBarItem(
            activeColorPrimary: CustomColors.pawrange,
            icon: FaIcon(FontAwesomeIcons.user), title: 'Profile'),
      ],
    );
  }
}
