// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/container.dart';
// import 'package:flutter/src/widgets/framework.dart';

// class EditFieldWidget extends StatelessWidget {
//   final VoidCallback show; 
//   String label; 
//   String placeholder; 
//   bool isPassword; 
//   bool showPassword = false; 
//   EditFieldWidget(this.label, this.placeholder, this.isPassword, {super.key});
//   @override
//   Widget build(BuildContext context) {

//     return TextField(
//       obscureText: isPassword,
//       decoration: InputDecoration(
//         suffixIcon: isPassword ? IconButton(
//           onPressed: show,
//           icon: Icon(
//             Icons.remove_red_eye, 
//             color: Colors.grey,)) : null,
//         contentPadding: EdgeInsets.only(bottom: 30), 
//         labelText: label, 
//         floatingLabelBehavior: FloatingLabelBehavior.always, 
//         hintText: placeholder,
//         hintStyle: TextStyle(
//           fontSize: 16, 
//           color: Colors.black,
//         )
//     ));
//   }
// }
