import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  int currentNavIndex = 2;

  int noOfRewards = 0;
  List<int> rewardIDR = [];
  List<String> nameR = [];
  List<String> descriptionR = [];
  List<String> picURLR = [];
  List<int> priceR = [];

  int points = 0;
  String name = "";

  @override
  void initState() {
    super.initState();
    RetrieveRewardData();
  }

  void RetrieveRewardData() {
    FirebaseFirestore.instance
        .collection('rewards')
        .snapshots()
        .listen((snapshot) {
      //iterate each client
      snapshot.docs.forEach((reward) {
        setState(() {
          //_controllerList.add(Completer());
          rewardIDR.add(reward.get('rewardID'));
          nameR.add(reward.get('name'));
          descriptionR.add(reward.get('description'));
          picURLR.add(reward.get('picURL'));
          priceR.add(reward.get('price'));
          ++noOfRewards;
        });
      });
    });
    FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        name = data['name'];
        points = data['points'];
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      //extendBodyBehindAppBar: false,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: AppBar(
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.only()),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 33, 126, 50),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                // ignore: prefer_const_constructors
                const Image(
                  image: AssetImage("assets/icons/mm_logo.png"),
                  width: 70,
                  height: 70,
                ),
                const Text(
                  "Mahjong Movers",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.add_box_rounded),
                onPressed: () {
                  setState(() {
                    Navigator.pushNamed(context, '/newBooking');
                  });
                },
              ),
            ],
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          )),

      body: Container(
        child: GridView.builder(
          itemCount: noOfRewards,
          itemBuilder: (context, index) {
            return rewardCard(nameR[index], descriptionR[index], priceR[index],
                picURLR[index]);
          },
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentNavIndex,
        onTap: (index) {
          setState(() {
            currentNavIndex = index;
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(
                  context,
                  '/task',
                );
                break;
              case 1:
                Navigator.pushReplacementNamed(
                  context,
                  '/home',
                );
                break;
              case 3:
                Navigator.pushReplacementNamed(
                  context,
                  '/profile',
                );
                break;
              case 4:
                Navigator.pushReplacementNamed(
                  context,
                  '/report',
                );
                break;
              default:
                break;
            }
          });
        },
        backgroundColor: const Color.fromARGB(255, 33, 126, 50),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_sharp),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_rounded),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'report',
          )
        ],
      ),
    );
  }
}

Card rewardCard(String name, String description, int price, String picURL) {
  return Card(
      elevation: 4.0,
      child: Column(
        children: [
          ListTile(
            title: Text(name),
          ),
          Container(
            width: 100,
            height: 100,
            child: Ink.image(image: NetworkImage(picURL), fit: BoxFit.contain),
          ),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.centerLeft,
              child: Text(description),
            ),
          ),
        ],
      ));
}
