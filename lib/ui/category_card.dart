import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/global.dart' as global;
import 'package:backdrop/pages/map_page.dart';

//Handles how the cards look but does no logic for manipulating the places in memory.

class CategoryCard extends StatefulWidget {
  String category;

  CategoryCard(categories) {
    this.category = categories;
  }

  @override
  State<StatefulWidget> createState() {
    return CategoryCardState();
  }
}

class CategoryCardState extends State<CategoryCard> {
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

    return SizedBox(height: 180, width: 180,
    child: addDisplayPropertiesToCard(widget.category));
  }

  Builder addDisplayPropertiesToCard(String categories) {
    switch(categories) {
      case "nature":
        return new Builder(builder: (BuildContext context) {
           return new Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: global.seafoamGreen),
              borderRadius: BorderRadius.all(Radius.circular(14))
            ),
            margin: EdgeInsets.all(16.0),
            child: FittedBox(
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
                      MaterialPageRoute(builder: (context) => MapPage(
                          filterCategory: 'nature',
                        )
                      ),
                    );
                  }
                )
              )
            ); 
          }
        );
      case "travel":
        return new Builder(builder: (BuildContext context) {
           return new Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: global.seafoamGreen),
              borderRadius: BorderRadius.all(Radius.circular(14))
            ),
            margin: EdgeInsets.all(16.0),
            child: FittedBox(
                fit: BoxFit.contain,
                child: new InkWell(
                  child: new Column(
                    children: <Widget>[
                      Icon(
                        Icons.airplanemode_active,
                        size: 26,
                        color: global.seafoamGreen
                      ),
                      Text("Travel",
                      style: TextStyle(fontSize: 4, color: global.seafoamGreen))
                    ]
                  ),
                  onTap: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapPage(
                          filterCategory: 'travel',
                        )
                      ),
                    );
                  }
                )
              )
            ); 
          }
        );
      case "fun":
        return new Builder(builder: (BuildContext context) {
           return new Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: global.seafoamGreen),
              borderRadius: BorderRadius.all(Radius.circular(14))
            ),
            margin: EdgeInsets.all(16.0),
            child: FittedBox(
                fit: BoxFit.contain,
                child: new InkWell(
                  child: new Column(
                    children: <Widget>[
                      Icon(
                        Icons.hot_tub,
                        size: 26,
                        color: global.seafoamGreen
                      ),
                      Text("Fun",
                      style: TextStyle(fontSize: 4, color: global.seafoamGreen))
                    ]
                  ),
                  onTap: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapPage(
                          filterCategory: 'fun',
                        )
                      ),
                    );
                  }
                )
              )
            ); 
          }
        );
      case "art":
        return new Builder(builder: (BuildContext context) {
           return new Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: global.seafoamGreen),
              borderRadius: BorderRadius.all(Radius.circular(14))
            ),
            margin: EdgeInsets.all(16.0),
            child: FittedBox(
                fit: BoxFit.contain,
                child: new InkWell(
                  child: new Column(
                    children: <Widget>[
                      Icon(
                        Icons.format_paint,
                        size: 26,
                        color: global.seafoamGreen
                      ),
                      Text("Art",
                      style: TextStyle(fontSize: 4, color: global.seafoamGreen))
                    ]
                  ),
                  onTap: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapPage(
                          filterCategory: 'art',
                        )
                      ),
                    );
                  }
                )
              )
            ); 
          }
        );
      case "food":
        return new Builder(builder: (BuildContext context) {
           return new Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: global.seafoamGreen),
              borderRadius: BorderRadius.all(Radius.circular(14))
            ),
            margin: EdgeInsets.all(16.0),
            child: FittedBox(
                fit: BoxFit.contain,
                child: new InkWell(
                  child: new Column(
                    children: <Widget>[
                      Icon(
                        Icons.restaurant,
                        size: 26,
                        color: global.seafoamGreen
                      ),
                      Text("Food",
                      style: TextStyle(fontSize: 4, color: global.seafoamGreen))
                    ]
                  ),
                  onTap: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapPage(
                          filterCategory: 'food',
                        )
                      ),
                    );
                  }
                )
              )
            ); 
          }
        );
      case "shopping":
        return new Builder(builder: (BuildContext context) {
           return new Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: global.seafoamGreen),
              borderRadius: BorderRadius.all(Radius.circular(14))
            ),
            margin: EdgeInsets.all(16.0),
            child: FittedBox(
                fit: BoxFit.contain,
                child: new InkWell(
                  child: new Column(
                    children: <Widget>[
                      Icon(
                        Icons.shopping_cart,
                        size: 26,
                        color: global.seafoamGreen
                      ),
                      Text("Shopping",
                      style: TextStyle(fontSize: 4, color: global.seafoamGreen))
                    ]
                  ),
                  onTap: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapPage(
                          filterCategory: 'shopping',
                        )
                      ),
                    );
                  }
                )
              )
            ); 
          }
        );
      case "architecture": 
        return new Builder(builder: (BuildContext context) {
           return new Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: global.seafoamGreen),
              borderRadius: BorderRadius.all(Radius.circular(14))
            ),
            margin: EdgeInsets.all(16.0),
            child: FittedBox(
                fit: BoxFit.contain,
                child: new InkWell(
                  child: new Column(
                    children: <Widget>[
                      Icon(
                        Icons.home,
                        size: 26,
                        color: global.seafoamGreen
                      ),
                      Text("Architecture",
                      style: TextStyle(fontSize: 4, color: global.seafoamGreen))
                    ]
                  ),
                  onTap: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapPage(
                          filterCategory: 'Architecture',
                        )
                      ),
                    );
                  }
                )
              )
            ); 
          }
        );
        case "placeholder": 
          return new Builder(builder: (BuildContext context) {
            return new Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2.0, color: global.seafoamGreen),
                borderRadius: BorderRadius.all(Radius.circular(14))
              ),
              margin: EdgeInsets.all(16.0),
              child: FittedBox(
                  fit: BoxFit.contain,
                  child: new InkWell(
                    child: new Column(
                      children: <Widget>[
                        Icon(
                          Icons.grid_off,
                          size: 26,
                          color: global.seafoamGreen
                        ),
                        Text("Placeholder",
                        style: TextStyle(fontSize: 4, color: global.seafoamGreen))
                      ]
                    ),
                    /*onTap: () {
                      
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MapPage(
                            filterCategory: 'Architecture',
                          )
                        ),
                      );
                    }*/
                  )
                )
              ); 
            }
          );
      
      default:
        return new Builder(builder: (BuildContext context) { return new Text(""); });
      } 
    }
  }

