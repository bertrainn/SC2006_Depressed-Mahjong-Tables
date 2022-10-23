// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class StatsWidget extends StatelessWidget {
  int statNum;
  String statType;
  Color color1;
  StatsWidget(this.statType, this.statNum, this.color1, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Color(0xFFFDFDFD),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFe8e8e8),
              blurRadius: 3.0,
              offset: Offset(0, 3.4),
            )
          ],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              statNum.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: color1,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2),
            Text(
              statType,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: color1,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ));
  }
}
