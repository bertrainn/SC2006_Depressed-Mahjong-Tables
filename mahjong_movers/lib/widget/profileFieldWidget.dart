import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ProfileFieldWidget extends StatelessWidget {
  String label;
  String text;

  ProfileFieldWidget(this.label, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 300,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white70,
          boxShadow: [
            BoxShadow(
              color: Color(0xFFe8e8e8),
              blurRadius: 3.0,
              offset: Offset(0, 3.4),
            )
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              )),
          SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ]));
  }
}
