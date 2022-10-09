import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ProfileFieldWidget extends StatelessWidget {
  String label;
  String text;

  ProfileFieldWidget(this.label, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          )),
      SizedBox(height: 5),
      Text(
        text,
        style: TextStyle(fontSize: 13),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 30),
    ]);
  }
}
