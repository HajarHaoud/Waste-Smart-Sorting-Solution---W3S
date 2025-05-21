import 'package:flutter/material.dart';

class MaterialCategoriesWidget extends StatelessWidget {
  const MaterialCategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MaterialCategoryItem(
            title: 'Plastic',
            icon: 'lib/assets/icons/plastic.jpg',
            color: Colors.blue,
            //placeholder: Icons.bubble_chart,
          ),
          MaterialCategoryItem(
            title: 'Plastic',
            icon: 'lib/images/apple.png',
            color: Colors.blue,
            //placeholder: Icons.bubble_chart,
          ),
          MaterialCategoryItem(
            title: 'Plastic',
            icon: 'lib/images/apple.png',
            color: Colors.blue,
            //placeholder: Icons.bubble_chart,
          ),
          MaterialCategoryItem(
            title: 'Plastic',
            icon: 'lib/images/apple.png',
            color: Colors.blue,
            //placeholder: Icons.bubble_chart,
          ),
          MaterialCategoryItem(
            title: 'Plastic',
            icon: 'lib/images/apple.png',
            color: Colors.blue,
            //placeholder: Icons.bubble_chart,
          ),
        ],
      ),
    );
  }
}

class MaterialCategoryItem extends StatelessWidget{
  final String title;
  final String icon;
  final Color color;
  //final IconData placeholder;

  MaterialCategoryItem({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    //required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2)
              )
            ]
          ),
        ),
        SizedBox(height: 8,),
        Text(
          title,
          style: TextStyle(
            fontSize: 14
          ),

        )
      ],
    );
  }
}
