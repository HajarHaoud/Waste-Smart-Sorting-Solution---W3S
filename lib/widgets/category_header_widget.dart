import 'package:flutter/material.dart';

class CategoryHeaderWidget extends StatelessWidget {
  const CategoryHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0 , right: 16.0 , top: 16.0 , bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Category' ,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.chevron_right,
              color: Colors.black,
            ),
          )
        ],
      ),
    );
  }
}
