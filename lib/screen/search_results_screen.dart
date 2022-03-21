import 'package:flutter/material.dart';
import 'package:packnary/widgets/search_bar.dart';

class SearchResultsScreen extends StatelessWidget {
  static const routeName = '/search-results';
  @override
  Widget build(BuildContext context) {
    final typedText = ModalRoute.of(context).settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        actions: [
          SearchBar(typedText),
        ],
      ),
    );
  }
}