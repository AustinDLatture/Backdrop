import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/global.dart' as global;
import '../ui/category_card.dart';

class CategoriesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CategoriesPageState();
  }
}

class CategoriesPageState extends State<CategoriesPage> {
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  String errorMessage;
  
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

    return Scaffold(
      key: homeScaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: global.seafoamGreen,
        title: const Text(
          "Categories",
          style: TextStyle(color: Colors.white, fontFamily: "Freight Sans", fontStyle: FontStyle.italic)
        )
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              new Builder(builder: (BuildContext context) { return new CategoryCard("nature"); }),
              new Builder(builder: (BuildContext context) { return new CategoryCard("Not yeety"); }) 
            ],
          )
        ]
      )
    );
  }
}