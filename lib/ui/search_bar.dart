import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold (
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Search Backdrops",
          style: TextStyle(color: Colors.grey)
          ),
        actions: <Widget> [
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.grey,
            onPressed: () {
              showSearch(context: context, delegate: DataSearch());
          })
        ],
      ),
    );
  }
}

class DataSearch extends SearchDelegate<String> {

//Populate results from instagram api call 

  //Do API call when map page loads, initially popu

final locations = [
  
];

final recentSearches = [
  //Save previously entered searches to this bar
  "Austin",
  "Joe",
  'Jake',
  "Example",
  "Recent",
  "Searches"
];

  @override
  List<Widget> buildActions(BuildContext context) {
    //actions for app bar
    return [
      IconButton(icon: Icon(Icons.clear), color: Colors.grey, onPressed: () {
        query = "";
      })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        color: Colors.grey,
        progress: transitionAnimation,
      ),
         onPressed: (){
           close(context, null);
         }
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Build results with instagram API call
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty 
    ? recentSearches
    : recentSearches.where((p) => p.startsWith(query)).toList();
    return ListView.builder(
        itemBuilder: (context, index)=>ListTile(
          leading: Icon(Icons.location_on),
          title: RichText(
            text: TextSpan(
              text: suggestionList[index].substring(0, query.length),
              style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: suggestionList[index].substring(query.length),
                  style: TextStyle(color: Colors.grey))
                ]),
              ),
            ),
        itemCount: suggestionList.length,
    );
  }

}