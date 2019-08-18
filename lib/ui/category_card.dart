import 'dart:async';
import 'dart:collection';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/global.dart' as global;

class CategoryCard extends StatefulWidget {
  List<String> categories;

  CategoryCard(categories) {
    this.categories = categories;
  }

  @override
  State<StatefulWidget> createState() {
    return CategoryCardState();
  }
}

class CategoryCardState extends State<CategoryCard> {
  Widget build(BuildContext context) {
    return SizedBox(height: 200, width: 200,
    child: Text("TestCatBox",
      style: TextStyle(color: global.seafoamGreen, fontFamily: "Freight Sans", fontSize: 50, fontStyle: FontStyle.italic),
      textAlign: TextAlign.center,
      )
    );
  }
}