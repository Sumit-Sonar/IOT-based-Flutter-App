// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:djec_app/auth.dart';
// import 'bluetooth.dart';
// import 'package:djec_app/welcome_screen.dart';
// // import 'switch_ui.dart';

// class HomePage extends StatelessWidget {
//   HomePage({super.key});

//   final User? user = Auth().currentUser;

//   Future<void> signOut() async {
//     await Auth().signOut();
//   }

//   Widget _title() {
//     return const Text('BSmart app');
//   }

//   Widget _userid() {
//     return Text(user?.email ?? 'User email');
//   }

//   Widget _signOutButton(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () async {
//         await signOut();
//         // ignore: use_build_context_synchronously
//         Navigator.of(context).popUntil((route) => route.isFirst);
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => WelcomeUi()),
//         ); // Perform the sign-out action
//         // Close the popup
//       },
//       child: const Text('Sign Out'),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: _title(),
//           actions: [
//             Builder(
//               builder: (context) => PopupMenuButton<String>(
//                 itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                   PopupMenuItem<String>(
//                     value: 'userid',
//                     child: _userid(),
//                   ),
//                   PopupMenuItem<String>(
//                     value: 'signout',
//                     child: _signOutButton(context),
//                   ),
//                 ],
//                 icon: const Icon(Icons.more_vert), // Vertical icon
//               ),
//             )
//           ],
//         ),
//         body: BluetoothUi());
//   }
// }
