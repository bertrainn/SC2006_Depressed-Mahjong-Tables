import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ProfilePicWidget extends StatelessWidget {
  String url = "";
  final String dummyProfilePicUrl = "assets/images/dummy_profile_pic_3.png";
  // Object? pic;
  ProfilePicWidget(this.url, {super.key});

  // ImageProvider whichPicture(){
  //   return (url != "")? NetworkImage(url) : AssetImage(dummyProfilePicUrl);
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            image: DecorationImage(
                fit: BoxFit.fill, image: AssetImage(dummyProfilePicUrl))),
      ),
    );
  }
}

class Picture extends StatelessWidget {
  String url;
  bool dummy;
  Picture(this.url, this.dummy);
  @override
  Widget build(BuildContext buildContext) {
    return dummy ? Image.asset(url) : Image.network(url);
  }
}
