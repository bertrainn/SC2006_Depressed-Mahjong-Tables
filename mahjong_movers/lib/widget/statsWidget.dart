// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class StatsWidget extends StatelessWidget {
  int statNum;
  String statType;
  StatsWidget(this.statType, this.statNum, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          statNum.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2),
        Text(
          statType,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
