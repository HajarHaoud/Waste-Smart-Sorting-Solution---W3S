import 'package:flutter/material.dart';

class BottomNagivationWidget extends StatefulWidget {
  const BottomNagivationWidget({super.key});

  @override
  State<BottomNagivationWidget> createState() => _BottomNagivationWidgetState();
}

class _BottomNagivationWidgetState extends State<BottomNagivationWidget> {
  int _selectedIndex = 0;

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, -2)
          )
        ]
      ),
    );
  }
}
