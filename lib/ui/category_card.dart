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
import 'package:backdrop/pages/category_list_page.dart';
import 'package:collection/collection.dart';


class CategoryCard extends StatefulWidget {
  String category;

  CategoryCard(categories) {
    this.category = categories;
    //pass it a string representing a category
  }

  @override
  State<StatefulWidget> createState() {
    return CategoryCardState();
  }
}

class CategoryCardState extends State<CategoryCard> {
  Widget build(BuildContext context) {
    return SizedBox(height: 200, width: 200,
    child: addDisplayPropertiesToCard(widget.category));
  }


  Builder addDisplayPropertiesToCard(String categories) {
      if (categories == "nature") {
        return new Builder(builder: (BuildContext context) {
           return new FittedBox(
              fit: BoxFit.contain,
              child: new InkWell(
                child: new Column(
                  children: <Widget>[
                    Icon(
                      Icons.nature,
                      size: 26,
                      color: global.seafoamGreen
                    ),
                    Text("Nature",
                    style: TextStyle(fontSize: 4, color: global.seafoamGreen))
                  ]
                ),
                onTap: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoryListPage('nature')),
                  );
                }
              )
            ); 
          }
        );
      } else {
        return new Builder(builder: (BuildContext context) { return new Text("Yeet"); });
      }
    }
  }

