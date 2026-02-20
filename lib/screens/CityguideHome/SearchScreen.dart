import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  final String cityName;
  const SearchScreen({super.key, required this.cityName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search in $cityName'),
      ),
      body: const Center(
        child: Text('Search screen – implement your search UI here'),
      ),
    );
  }
}