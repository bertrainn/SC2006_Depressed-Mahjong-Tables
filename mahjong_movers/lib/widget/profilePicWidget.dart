import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ProfilePicWidget extends StatelessWidget {
  String url = "";
  final String dummyProfilePicUrl = "assets/images/dummy_profile_pic_2.jpeg";
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
            border: Border.all(
                width: 4, color: Theme.of(context).scaffoldBackgroundColor),
            boxShadow: [
              BoxShadow(
                  spreadRadius: 2,
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(0, 10))
            ],
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
