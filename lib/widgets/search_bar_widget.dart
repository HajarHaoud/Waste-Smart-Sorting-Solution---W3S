import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            SizedBox(width: 12,),
            Icon(
              Icons.search,
              color: Colors.grey[600],
            ),
            SizedBox(width: 8,),
            Text(
              'Search',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16
              ),
            )
          ],
        ),
      ),

    );
  }
}
