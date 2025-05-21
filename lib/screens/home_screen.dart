import 'package:flutter/material.dart';
import 'package:w3s/widgets/category_header_widget.dart';
import 'package:w3s/widgets/material_categories_widget.dart';
import 'package:w3s/widgets/recycling_widget.dart';
import 'package:w3s/widgets/search_bar_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
          Column(
            children: [
              SearchBarWidget(),
              RecyclingWidget(),
              CategoryHeaderWidget(),
              MaterialCategoriesWidget(),
            ],
          )
      ),

    );
  }
}
