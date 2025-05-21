import 'package:flutter/material.dart';

class RecyclingWidget extends StatefulWidget {
  const RecyclingWidget({super.key});

  @override
  State<RecyclingWidget> createState() => _RecyclingWidgetState();
}

class _RecyclingWidgetState extends State<RecyclingWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  void dispose(){
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView(
            controller: _pageController,
            onPageChanged: (int page){
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              _buildRecycleBin('METAL' , Colors.green),
              _buildRecycleBin('METAL' , Colors.yellow),
              _buildRecycleBin('METAL' , Colors.blue),
              _buildRecycleBin('METAL' , Colors.red),
            ],
          ),
        ),
        SizedBox(height: 8,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? Colors.black : Colors.grey[300],
                ),
              )
          ),
        )
      ],
    );
  }
}

Widget _buildRecycleBin(String type , Color color) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 8.0),
    child: Container(
      width: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.recycling,
              size: 60,
              color: Colors.white,
            ),
          ),
          Positioned(
            bottom: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16 , vertical: 8),
              decoration: BoxDecoration(
                color : Colors.white,
                borderRadius: BorderRadius.circular(16)
              ),
              child: Text(
                type,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          )
        ],
      ),
    ),
  );
}



