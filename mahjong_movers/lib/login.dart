import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  String email = "";
  String password = "";
  bool _passwordVisible = false;

  void logInUser(String userEmail, String userPass) async {
    int userInClient = 0;
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: userEmail, password: userPass);

      // if (userCredential.user?.emailVerified == false) {
      //   print("User not verified!");
      //   Navigator.of(context).popUntil((route) => route.isFirst);
      //   Navigator.popAndPushNamed(context, '/userVerification');
      // }
      // Verify Admin Account

      FirebaseFirestore.instance
          .collection('admin')
          .snapshots()
          .listen((snapshot) {
        for (var admin in snapshot.docs) {
          if (userCredential.user?.uid == admin.id) {
            if (userCredential.user?.emailVerified == false) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    duration: new Duration(seconds: 4),
                    content: Row(
                      children: <Widget>[
                        new Text("Verify your email! Check your spam folder!")
                      ],
                    )),
              );
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.popAndPushNamed(
                context,
                '/admin',
                arguments: {
                  'uid': userCredential.user?.uid,
                  'fname': admin['fname']
                },
              );
            }
          }
        }
      });

      //check if user is user
      FirebaseFirestore.instance
          .collection('user')
          .snapshots()
          .listen((snapshot) {
        for (var client in snapshot.docs) {
          if (userCredential.user?.uid == client.id) {
            if (userCredential.user?.emailVerified == true) {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.popAndPushNamed(
                context,
                '/home',
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    duration: new Duration(seconds: 4),
                    content: Row(
                      children: <Widget>[
                        new Text("Verify your email! Check your spam folder!")
                      ],
                    )),
              );
            }
          }
        }
      });

      await Future.delayed(const Duration(seconds: 3));

      // if (userCredential.user?.emailVerified == true) {
      //   var findUser = await FirebaseFirestore.instance
      //       .collection('client')
      //       .doc(userCredential.user?.uid)
      //       .get();
      //   if (findUser.exists == false) {
      //     Navigator.of(context).popUntil((route) => route.isFirst);
      //     Navigator.popAndPushNamed(context, '/rekeyUserData');
      //   }
      // } else {
      //   Navigator.of(context).popUntil((route) => route.isFirst);
      //   Navigator.popAndPushNamed(context, '/userVerification');
      // }
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("Wrong Email/Password"),
              actions: [
                TextButton(
                  child: const Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
      //TODO: remove for production
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      } else if (e.code == 'invalid-email') {
        print('Invalid Email Format');
      } else {
        print(e);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 33, 126, 50),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Image(
              image: AssetImage("assets/icons/mm_logo.png"),
              width: 100,
              height: 100,
            ),
            const SizedBox(
              height: 48.0,
            ),
            TextField(
              style: const TextStyle(
                  color: Colors.black, backgroundColor: Colors.white),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                //Do something with the user input.
                email = value;
              },
              decoration: const InputDecoration(
                hintText: 'Enter your email',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            TextField(
              obscureText: !_passwordVisible,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (value) {
                //Do something with the user input.
                password = value;
              },
              decoration: const InputDecoration(
                hintText: 'Enter your password.',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
              ),
            ),
            const SizedBox(
              height: 24.0,
            ),
            ElevatedButton(
              onPressed: () {
                //Implement login functionality.
                if (mounted) {
                  setState(() {
                    logInUser(email, password);
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                primary: Colors.white, // <-- Button color
                onPrimary: Colors.black, // <-- Splash color
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.black,
                size: 24.0,
              ),
            ),
            const SizedBox(
              height: 24.0,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                TextSpan(
                    text: 'Sign Up',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(context, '/signup');
                      }),
              ]),
            ),
            const SizedBox(
              height: 24.0,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                TextSpan(
                    text: 'Forgot Password',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(context, '/forgotPassword');
                      }),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
