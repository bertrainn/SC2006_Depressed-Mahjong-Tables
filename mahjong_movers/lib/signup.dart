import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientSignupInfo {
  final String dName;
  final String phoneNumber;
  final String email;

  ClientSignupInfo(this.dName, this.phoneNumber, this.email);
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late UserCredential userCredential;

  void signUp(String inputEmail, String inputPassword, String dName,
      String number) async {
    String? message;
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: inputEmail, password: inputPassword);
      message = 'Account has been created, please verify your email.';
      FirebaseAuth.instance.currentUser?.sendEmailVerification();

      Map<String, dynamic> json = {
        'email': inputEmail,
        'name': dName,
        'phone': int.parse(number),
        'rating': 5,
        'picURL': "",
        'points': 0,
      };
      final newClient = FirebaseFirestore.instance
          .collection('user')
          .doc(userCredential.user?.uid);
      await newClient.set(json);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return accountCreationSuccessDialog(context, message!);
        },
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        //TODO: remove for production
        print('The password provided is too weak.');
        message = 'The password provided is too weak.';
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return accountCreationFailedDialog(context, message!);
          },
        );
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        message = 'The account already exists for that email.';
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return accountCreationFailedDialog(context, message!);
          },
        );
      }
    } catch (e) {
      print(e);
      message = e as String?;
    }
  }

  AlertDialog accountCreationSuccessDialog(
      BuildContext context, String message) {
    return AlertDialog(
      title: const Text("Notice"),
      content: Text(message),
      actions: [
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            //_emailController.clear();
            // _passwordController.clear();
            //firstNameController.clear();
            //_lastNameController.clear();
            // _registerNoController.clear();
            // _teamController.clear();
            Navigator.of(context).popUntil((route) => route.isFirst);

            Navigator.popAndPushNamed(
              context,
              '/login',
            );
          },
        )
      ],
    );
  }

  AlertDialog accountCreationFailedDialog(
      BuildContext context, String message) {
    return AlertDialog(
      title: const Text("Notice"),
      content: Text(message),
      actions: [
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            //_emailController.clear();
            // _passwordController.clear();
            //firstNameController.clear();
            //_lastNameController.clear();
            // _registerNoController.clear();
            // _teamController.clear();
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: AppBar(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            )),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 33, 126, 50),
            title: const Text(
              "Sign Up",
              style: TextStyle(color: Colors.white),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          )),
      body: Form(
        key: _formKey,
        //autovalidateMode: AutovalidateMode.always,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 24.0,
              ),
              TextFormField(
                controller: _displayNameController,
                validator: (value) =>
                    value!.isEmpty ? 'Display Name is required' : null,
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  //Do something with the user input.
                  //email = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'Enter your display name',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white54,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _phoneNumberController,
                inputFormatters: <TextInputFormatter>[
                  // for below version 2 use this
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
// for version 2 and greater youcan also use this
                  FilteringTextInputFormatter.digitsOnly
                ],
                maxLength: 8,
                validator: (value) =>
                    value!.isEmpty ? 'Phone Number is required' : null,
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  //Do something with the user input.
                  //password = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextFormField(
                controller: _emailController,
                validator: (value) =>
                    value!.isEmpty ? 'Email is required' : null,
                style: const TextStyle(color: Colors.black),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  //Do something with the user input.
                  //password = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Email',
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
                    borderSide: BorderSide(color: Colors.black26, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextFormField(
                controller: _passwordController,
                validator: (value) =>
                    value!.isEmpty ? 'Password is required' : null,
                style: const TextStyle(color: Colors.black),
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (value) {
                  //Do something with the user input.
                  //password = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Material(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                  elevation: 5.0,
                  child: MaterialButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() == true) {
                        //form is valid, proceed further
                        //TODO: remove for production

                        signUp(
                          _emailController.text,
                          _passwordController.text,
                          _displayNameController.text,
                          _phoneNumberController.text,
                        );
                        print('valid');
                      }
                    },
                    minWidth: 200.0,
                    height: 42.0,
                    child: const Text(
                      'Sign Up',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
