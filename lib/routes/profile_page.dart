import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:pawgo/models/dogsList.dart';
import 'package:pawgo/models/loggedUser.dart';
import 'package:pawgo/routes/profile_editing.dart';
import 'package:pawgo/routes/sign_in_page.dart';
import 'package:pawgo/services/authentication.dart';
import 'package:pawgo/services/mongodb_service.dart';
import 'package:pawgo/size_config.dart';
import 'package:flutter/material.dart';
import 'package:pawgo/utils/mobile_library.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:pawgo/assets/custom_colors.dart';
import 'package:pawgo/routes/dogs_profile_edit.dart';

import '../models/dog.dart';
import '../services/mongodb_service.dart';
import '../models/currentUser.dart';
import '../widget/custom_alert_dialog.dart';


class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  LoggedUser _miUser = LoggedUser.instance!;
  User? user = FirebaseAuth.instance.currentUser;
  bool check = false;
  final usernameController = TextEditingController();
  final userAgeController = TextEditingController();
  final userDescController = TextEditingController();
  String username = LoggedUser.instance!.username;
  String userId = LoggedUser.instance!.userId;
  String userAge = CurrentUser.instance!.userAge;
  String userDesc = CurrentUser.instance!.userDesc;
  String imageUrl = LoggedUser.instance!.image.url;
  bool imgInserted = false;
  bool _alreadyClicked = false;
  File? f;

  List<Dog>? dogsList = DogsList.instance!.dogsList;

  // Use to get user information
  Future<void> getUser() async {
    setState(() {
    });
    CurrentUser? currentUser = await MongoDB.instance.getUser(userId);
    if(currentUser != null) {
      userAge = currentUser.getUserAge();
      userDesc = currentUser.getUserDesc();
    }
  }

  Future<void> getDogs() async {
    setState(() {
    });
    List<Dog>? list = await MongoDB.instance.getDogsByUserId(userId);
    if(list != null) {
      dogsList = list;
    }
  }

  Future<void> removeDogByDogId(String dogId, String userId) async {
    setState(() {
      check = true;
    });
    try
    {
      // TODO loading icon problem
      await MongoDB.instance.removeDogByDogId(dogId, userId);
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return buildCustomAlertOKDialog(context, "",
              "Successfully removed this dog!");
        },
      );
      List<Dog>? dogsList = await updateDogList(userId);
      if(dogsList != null) {
        DogsList.instance!.updateDogsList(dogsList);
      }
    }
    finally
    {
      setState(() {
        check = false;
      });
    }
  }

  Future<List<Dog>?> updateDogList(String userId) async {
    try
    {
      List<Dog>? dogsList = await MongoDB.instance.getDogsByUserId(userId);
      return dogsList;
    }
    finally
    {}
  }

  @override
  void initState() {
    _miUser.addListener(() => setState(() {}));
    print("userId of the logged user is: " + _miUser.userId);
    this.getDogs();
    this.getUser();
    super.initState();
  }

  Widget header() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(
            left: 30.0, right: 30.0, top: 10 * SizeConfig.heightMultiplier!, bottom: 2.5 * SizeConfig.heightMultiplier!),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  height: 11 * SizeConfig.heightMultiplier!,
                  width: 11 * SizeConfig.heightMultiplier!,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      _miUser.image.url,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object object,
                          StackTrace? stacktrace) {
                        return Image.asset("lib/assets/app_icon.png");
                      },
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes as num)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 5 * SizeConfig.widthMultiplier!,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _miUser.username,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 3 * SizeConfig.textMultiplier!,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 1 * SizeConfig.heightMultiplier!,
                    ),
                    Row(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              nStringToNNString(_miUser.mail),
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 2 * SizeConfig.textMultiplier!,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 7 * SizeConfig.widthMultiplier!,
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
            SizedBox(
              height: 1 * SizeConfig.heightMultiplier!,
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await Authentication.signOut(context: context);
                    setState(() {
                      Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                          _routeToSignInScreen(), (_) => false);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white60),
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.lightGreen,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                      child: Text(
                        "SIGN OUT",
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: 1.8 * SizeConfig.textMultiplier!),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 4 * SizeConfig.widthMultiplier!,
                ),
                GestureDetector(
                  onTap: () {
                    pushNewScreen(context,
                        screen: ProfileEditing(),
                        pageTransitionAnimation:
                        PageTransitionAnimation.cupertino);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white60),
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.lightGreen,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "EDIT USER PROFILE",
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: 1.8 * SizeConfig.textMultiplier!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [

                SizedBox(
                  height: 1 * SizeConfig.heightMultiplier!,
                ),
                GestureDetector(
                  onTap: () async {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => DogsProfilePage(),),).then(
                            (data) {
                              this.getUser();
                              this.getDogs();
                            });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white60),
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.lightGreen,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "ADD NEW DOG",
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: 1.8 * SizeConfig.textMultiplier!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.pawrange,
      body: Column(
        children: <Widget>[
          header(),
          Container(
            child: Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      CustomColors.pawrange,
                      Colors.white,
                    ],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    topLeft: Radius.circular(30.0),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        userInfo(),
                        Divider(
                          color: Colors.white,
                        ),
                        dogsInfo(),
                        SizedBox(
                          height: 3 * SizeConfig.heightMultiplier!,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget userInfo() {
    return
      Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 1 * SizeConfig.heightMultiplier!),
              child: Text(
                "User's Profile",
                style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 3 * SizeConfig.textMultiplier!),
              ),
            ),
            SizedBox(
              height: 2 * SizeConfig.heightMultiplier!,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                color: Colors.grey.shade200,
                border: Border.all(
                  color: Colors.black26.withOpacity(0.1),
                ),
              ),
            child: Padding(
              padding: EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Column(
                        children: [
                        Padding(
                          padding: EdgeInsets.all(0),
                          child: Column(
                            children: [
                              Container(
                                height: 40 * SizeConfig.heightMultiplier!,
                                width: 40 * SizeConfig.heightMultiplier!,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    _miUser.image.url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (BuildContext context, Object object,
                                        StackTrace? stacktrace) {
                                      return Image.asset("lib/assets/app_icon.png");
                                    },
                                    loadingBuilder: (BuildContext context, Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                              (loadingProgress.expectedTotalBytes as num)
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 1 * SizeConfig.heightMultiplier!,
                              ),
                            Text(
                              "Username:",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 2.5 * SizeConfig.textMultiplier!,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            Text(
                              LoggedUser.instance!.username,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 2.2 * SizeConfig.textMultiplier!,
                              ),
                            ),
                            SizedBox(
                              height: 1 * SizeConfig.heightMultiplier!,
                            ),
                            Text(
                              "Age:",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 2.5 * SizeConfig.textMultiplier!,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            Text(
                              CurrentUser.instance!.userAge,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 2.2 * SizeConfig.textMultiplier!,
                              ),
                            ),
                            SizedBox(
                              height: 1 * SizeConfig.heightMultiplier!,
                            ),
                            Text(
                              "Email:",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 2.5 * SizeConfig.textMultiplier!,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            Text(
                              LoggedUser.instance!.mail,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 2.2 * SizeConfig.textMultiplier!,
                              ),
                            ),
                            SizedBox(
                              height: 1 * SizeConfig.heightMultiplier!,
                            ),
                            Text(
                              "About Me:",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 2.5 * SizeConfig.textMultiplier!,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                              SizedBox(
                                height: 1 * SizeConfig.heightMultiplier!,
                              ),
                            Container(
                              child: (CurrentUser.instance!.userDesc != "Update your desc here")
                                  ? Padding(
                                padding: EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
                                child: Text(
                                  CurrentUser.instance!.userDesc,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 2.2 * SizeConfig.textMultiplier!,
                                  ),
                                ),
                              ) :
                              Padding(
                                padding: EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
                              child: Text(
                                " - ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 2.2 * SizeConfig.textMultiplier!,
                                ),
                               ),
                              ),
                             ),
                           ],
                          ),
                         ),
                        ],
                      ),
                    ],
                  ),
              //),
            ),),
          ],
        )
      ),
    );
  }

  Widget dogsInfo() {
    return Container(
        child: DogsList.instance!.dogsList.isEmpty
            ? SizedBox()
            : Container(
          child: SingleChildScrollView(

              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 1 * SizeConfig.heightMultiplier!),
                    child: Text(
                      "Dog's Profile",
                      style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 3 * SizeConfig.textMultiplier!),
                    ),
                  ),
                  displayDog(),
                ],
              )
          ),)
    );
  }

  Widget displayDog() {
    return ListView.builder(
        itemCount: DogsList.instance!.dogsList.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  color: Colors.grey.shade200,
                  border: Border.all(
                    color: Colors.black26.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5 * SizeConfig.heightMultiplier!),
                          child: Column(
                            children: [
                              Container(
                                height: 40 * SizeConfig.heightMultiplier!,
                                width: 40 * SizeConfig.heightMultiplier!,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(DogsList.instance!.dogsList[index].imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (BuildContext context, Object object,
                                        StackTrace? stacktrace) {
                                      return Image.asset("lib/assets/default_dog.jpg");
                                    },
                                  ),
                                ),
                              ),
                              Text(
                                "Name:",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 2.5 * SizeConfig.textMultiplier!,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              Text(
                                DogsList.instance!.dogsList[index].dogName,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 2.2 * SizeConfig.textMultiplier!,
                                ),
                              ),
                              SizedBox(
                                height: 1 * SizeConfig.heightMultiplier!,
                              ),
                              Text(
                                "Age:",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 2.5 * SizeConfig.textMultiplier!,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              Text(
                                DogsList.instance!.dogsList[index].dogAge,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 2.2 * SizeConfig.textMultiplier!,
                                ),
                              ),
                              SizedBox(
                                height: 1 * SizeConfig.heightMultiplier!,
                              ),
                              Text(
                                "Breed:",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 2.5 * SizeConfig.textMultiplier!,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              Text(
                                DogsList.instance!.dogsList[index].dogBreed,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 2.2 * SizeConfig.textMultiplier!,
                                ),
                              ),
                              SizedBox(
                                height: 1 * SizeConfig.heightMultiplier!,
                              ),
                              Text(
                                "Hobbies:",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 2.5 * SizeConfig.textMultiplier!,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              DogsList.instance!.dogsList[index].dogHobby == "What's your dog's hobbies?" ?
                              Text(
                                " - ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 2.2 * SizeConfig.textMultiplier!,
                                ),
                              ) :
                              Text(
                                DogsList.instance!.dogsList[index].dogHobby,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 2.2 * SizeConfig.textMultiplier!,
                                ),
                              ),
                              SizedBox(
                                height: 1 * SizeConfig.heightMultiplier!,
                              ),
                              Text(
                                "Personality:",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 2.5 * SizeConfig.textMultiplier!,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              DogsList.instance!.dogsList[index].dogPersonality == "What's your dog's personality?"
                                  ?
                              Text(
                                " - ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 2.2 * SizeConfig.textMultiplier!,
                                ),
                              ) :
                              Text(
                                DogsList.instance!.dogsList[index].dogPersonality,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 2.2 * SizeConfig.textMultiplier!,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 1 * SizeConfig.heightMultiplier!),
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 250),
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 250),
                                    child: ElevatedButton(
                                        onPressed: () async{
                                          if(!check)
                                          {
                                            // TODO: To add dog's data grab from MongoDB
                                            Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (context) => DogsProfilePage(
                                                  data: DogsList.instance!.dogsList[index].id,
                                                ),
                                              ),
                                            ).then((data) {
                                              this.getUser();
                                              this.getDogs();
                                            });
                                          }
                                        },
                                        child: Text("Update Dog's Profile"),
                                        style: ButtonStyle(
                                            fixedSize: MaterialStateProperty.all(
                                                Size(200, 35)),
                                            backgroundColor: MaterialStateProperty.all(
                                                CustomColors.pawrange),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(18.0))))),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 1 * SizeConfig.heightMultiplier!),
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 250),
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 250),
                                    child: ElevatedButton(
                                      child: Text("Remove Profile"),
                                      style: ButtonStyle(
                                      fixedSize: MaterialStateProperty.all(
                                      Size(200, 35)),
                                      backgroundColor: MaterialStateProperty.all(
                                      CustomColors.pawrange),
                                          shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(18.0))),
                                      ),
                                        onPressed: () async{
                                          if(!_alreadyClicked)
                                                {
                                                  showDialog<bool>(
                                                    context: context,
                                                    barrierDismissible: false, // user must tap button!
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        backgroundColor: Colors.white,
                                                        title: Text(
                                                          "",
                                                          style: TextStyle(color: Colors.black),
                                                        ),
                                                        content: SingleChildScrollView(
                                                          child: ListBody(
                                                            children: <Widget>[
                                                              Text(
                                                                "Are you sure you want to remove\n" + DogsList.instance!.dogsList[index].dogName + "?",
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(color: Colors.black),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            child: Text(
                                                              'YES',
                                                              style: TextStyle(color: CustomColors.pawrange),
                                                            ),
                                                            onPressed: () async {
                                                              buttonUpdate(context);
                                                              await removeDogByDogId(DogsList.instance!.dogsList[index].id, LoggedUser.instance!.userId);
                                                            },
                                                          ),
                                                          TextButton(
                                                              onPressed: () {
                                                                buttonUpdate(context);
                                                              },
                                                              child: Text('NO',
                                                                  style: TextStyle(color: CustomColors.pawrange))),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  setState(() {
                                                    _alreadyClicked = true;
                                                  });
                                                }
                                              }),

                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
           ],
          );
        });
    }

void buttonUpdate(BuildContext context) {
  Navigator.of(context).pop();
  setState(() {
    _alreadyClicked = false;
  });
}

  String nStringToNNString(String? str) {
    return str ?? "";
  }

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(-1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.ease;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
                position: animation.drive(tween),
                child: child,
            );
         },
    );
  }
}