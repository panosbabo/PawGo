import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pawgo/assets/custom_colors.dart';
import 'package:pawgo/size_config.dart';
import 'package:pawgo/utils/mobile_library.dart';
import 'package:provider/provider.dart';
import 'package:pawgo/utils/card_provider.dart';
import 'package:pawgo/widget/tinder_card.dart';

import '../models/cardUser.dart';
import '../widget/custom_alert_dialog.dart';

class MatchPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => CardProvider(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      // title: title,
      home: MatchPages(),
      theme: ThemeData(
        primarySwatch: Colors.red,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(fontSize: 20),
            // elevation: 8,
            primary: Colors.white,
            shape: CircleBorder(),
            minimumSize: Size.square(60),
          ),
        ),
      ),
    ),
  );
}

class MatchPages extends StatefulWidget {
  MatchPages({Key? key}) : super(key: key);

  @override
  _MatchPagesState createState() => _MatchPagesState();
}

class _MatchPagesState extends State<MatchPages> {
  List<CardUser> cardUserList = [];
  bool matchCheck = false;
  bool check = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Container(
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
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon(
                  //   FontAwesomeIcons.dog,
                  //   color: Colors.white,
                  //   size: 36,
                  // ),
                  // const SizedBox(width: 100),
                  Text(
                    'PawGo',
                    style: TextStyle(
                      fontSize: 7 * SizeConfig.textMultiplier!,
                      fontFamily: 'pawfont',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // const SizedBox(width: 80),
                  // buildLikeButtons(),
                ],
              ),
              const SizedBox(height: 5),
              Expanded(child: buildCards()),
              const SizedBox(height: 5),
              buildButtons(),
            ],
          ),
        ),
      ),
    ),
  );

  Widget checkMatch() {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        "Tip",
        style: TextStyle(color: Colors.black),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              "Swipe the pictures right or left.\n\nTap on the pictures to reveal details.\n\nMatch Page is loading...\n",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCards() {
    cardUserList = Provider.of<CardProvider>(context).cardUserList;

    if(cardUserList.length == 5) {
      matchCheck = true;
    }

    return !matchCheck
        ? Container(
            child: checkMatch(),
          ) :
    cardUserList.isEmpty
        ? Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '🐾\nRestart\nfor more users',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),],
    ) :
    Stack(
      children: cardUserList
          .map((cardUser) => TinderCard(
        cardUser: cardUser,
        isFront: cardUserList.last == cardUser,
      ))
          .toList(),
    );
  }

  Widget buildButtons() {
    final provider = Provider.of<CardProvider>(context);
    final status = provider.getStatus();
    final isLike = status == CardStatus.like;
    final isDislike = status == CardStatus.dislike;

    if(cardUserList.length == 5) {
      setState(() {
        check = false;
      });
    }

    return cardUserList.length != 5 && check
        ? CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(CustomColors.pawrange),
    ) :
    cardUserList.isEmpty && !check ?
    ElevatedButton(
      onPressed: () {
        provider.resetUsers();
        setState(() {
          check = true;
        });
      },
      child: Text("Restart"),
      style: ButtonStyle(
          fixedSize: MaterialStateProperty.all(
              Size(125, 35)),
          backgroundColor: MaterialStateProperty.all(
              CustomColors.pawrange),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      18.0)))),
    ) :
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ButtonStyle(
            foregroundColor:
            getColor(Colors.red, Colors.white, isDislike),
            backgroundColor:
            getColor(Colors.white, Colors.red, isDislike),
            side: getBorder(Colors.red, Colors.white, isDislike),
          ),
          child: Icon(Icons.clear, size: 40),
          onPressed: () {
            final provider =
            Provider.of<CardProvider>(context, listen: false);

            provider.dislike();
          },
        ),
        ElevatedButton(
          style: ButtonStyle(
            foregroundColor: getColor(Colors.green, Colors.white, isLike),
            backgroundColor: getColor(Colors.white, Colors.green, isLike),
            side: getBorder(Colors.green, Colors.white, isLike),
          ),
          child: Icon(Icons.favorite, size: 40),
          onPressed: () {
          final provider =
          Provider.of<CardProvider>(context, listen: false);

          provider.like(cardUserList[cardUserList.length - 1].userId, cardUserList[cardUserList.length - 1].dog.id);
          },
        ),
      ],
    );
  }

  MaterialStateProperty<Color> getColor(
      Color color, Color colorPressed, bool force) {
    final getColor = (Set<MaterialState> states) {
      if (force || states.contains(MaterialState.pressed)) {
        return colorPressed;
      } else {
        return color;
      }
    };

    return MaterialStateProperty.resolveWith(getColor);
  }

  MaterialStateProperty<BorderSide> getBorder(
      Color color, Color colorPressed, bool force) {
    final getBorder = (Set<MaterialState> states) {
      if (force || states.contains(MaterialState.pressed)) {
        return BorderSide(color: Colors.transparent);
      } else {
        return BorderSide(color: color, width: 2);
      }
    };

    return MaterialStateProperty.resolveWith(getBorder);
  }
}
