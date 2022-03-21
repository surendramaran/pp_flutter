import 'package:flutter/material.dart';
import 'package:packnary/screen/search_results_screen.dart';

class SearchBar extends StatelessWidget {
  final String initialText;

  SearchBar(this.initialText);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () {
        showSearch(context: context, delegate: DataSearch(), query: initialText);
      },
    );
  }
}

class DataSearch extends SearchDelegate<String> {

  final cities = ['a', 'ab', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'];
  final recentCities = ['b', 'c', 'd', 'e'];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  void showResults(BuildContext context) {
    // TODO: implement showResults
    Navigator.of(context).popAndPushNamed(
      SearchResultsScreen.routeName,
      arguments: query,
    );
    super.showResults(context);
  }

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentCities
        : cities.where((element) => element.startsWith(query)).toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          Navigator.of(context).popAndPushNamed(
            SearchResultsScreen.routeName,
            arguments: suggestionList[index],
          );
        },
        leading: Icon(Icons.location_city),
        title: RichText(
          text: TextSpan(
            text: suggestionList[index].substring(0, query.length),
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: suggestionList[index].substring(query.length),
                style: TextStyle(
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
      itemCount: suggestionList.length,
    );
    // throw UnimplementedError();
  }
}
