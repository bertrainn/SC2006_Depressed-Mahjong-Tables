import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'dart:developer';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'main.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  int currentNavIndex = 2;

  int noOfRewards = 0;
  List<double> rewardIDR = [];
  List<String> nameR = [];
  List<String> descriptionR = [];
  List<String> picURLR = [];
  List<double> priceR = [];
  var r = Random();
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  double points = 0;
  String name = "";

  @override
  void initState() {
    super.initState();
    RetrieveRewardData();
  }

  void RetrieveRewardData() async {
    FirebaseFirestore.instance
        .collection('rewards')
        .snapshots()
        .listen((snapshot) {
      //iterate each client
      snapshot.docs.forEach((reward) {
        setState(() {
          //_controllerList.add(Completer());
          rewardIDR.add(reward.get('rewardID').toDouble());
          nameR.add(reward.get('name'));
          descriptionR.add(reward.get('description'));
          picURLR.add(reward.get('picURL'));
          priceR.add(reward.get('price').toDouble());
          ++noOfRewards;
        });
      });
    });
    await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        name = data['name'];
        points = data['points'].toDouble();
        print(points);
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  void updatePointValue(double newValue) {
    FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({"points": newValue});
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      "Mahjong Movers",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text("Point Balance: ${points}",
                        style: TextStyle(
                          fontSize: 14,
                        )),
                  ],
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
        child: ListView.builder(
          itemCount: noOfRewards,
          itemBuilder: (context, index) {
            return Card(
                elevation: 4.0,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  ListTile(
                    title: Text(nameR[index]),
                  ),
                  Container(
                    height: 100.0,
                    child: Ink.image(
                      image: NetworkImage(picURLR[index]),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      descriptionR[index],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                    child: Text(
                      "${priceR[index].round()} Points",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ButtonBar(
                    children: [
                      TextButton(
                          child: const Text("Redeem"),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                        "${nameR[index]} - ${priceR[index]} Points"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(16.0),
                                          child: Image.network(picURLR[index],
                                              fit: BoxFit.contain),
                                        ),
                                        Text(descriptionR[index]),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text("Redeem"),
                                        onPressed: () {
                                          if (priceR[index] > points) {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "Insufficient Points"),
                                                    content: const Text(
                                                        "You do not have enough points to redeem this reward."),
                                                    actions: [
                                                      TextButton(
                                                        child: const Text("Ok"),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      )
                                                    ],
                                                  );
                                                });
                                          } else {
                                            updatePointValue(
                                                points - priceR[index]);

                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  String code = List.generate(
                                                      10,
                                                      (index) => _chars[
                                                          r.nextInt(_chars
                                                              .length)]).join();
                                                  ;
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "Redemption Successful"),
                                                    content: Text(
                                                        "Your voucher code for Grab is shown below: " +
                                                            code),
                                                    actions: [
                                                      TextButton(
                                                        child: const Text("Ok"),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .popUntil((route) =>
                                                                  route
                                                                      .isFirst);

                                                          Navigator
                                                              .popAndPushNamed(
                                                                  context,
                                                                  '/rewards',
                                                                  arguments: {});
                                                        },
                                                      )
                                                    ],
                                                  );
                                                });
                                          }
                                        },
                                      )
                                    ],
                                  );
                                });
                            //print("Pee Pee ${priceR[index]}");
                          }),
                    ],
                  )
                ]));
          },
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
