import 'package:djec_app/bluetooth/bluetooth.dart';
import 'package:djec_app/admin%20pages/adminuserpageorbuttons.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebaseAuth/userAuth.dart';

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({Key? key});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  String? errorMessage = "";
  String text1 = "LogIn";
  bool isUserLogin = true;

  final TextEditingController _controllerUserEmail = TextEditingController();
  final TextEditingController _controllerUserPassword = TextEditingController();

  Future<void> signInUserWithEmailAndPassword() async {
    try {
      await UserAuth().signInUserWithEmailAndPassword(
        email: _controllerUserEmail.text,
        password: _controllerUserPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return Text(
      'BSmart app',
      style: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _entryField(
    String title,
    TextEditingController userController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: userController,
        decoration: InputDecoration(
          labelText: title,
        ),
      ),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : 'Hmm.. $errorMessage',
      style: TextStyle(
        color: Colors.red,
        fontSize: 16.0,
      ),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (isUserLogin) {
          await signInUserWithEmailAndPassword();
          final User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => BluetoothUi(
                        pageProvider: PageProvider(),
                      )),
            );
          } else {
            setState(() {
              errorMessage = "Sign-in failed.";
            });
          }
        } else {
          // Handle other cases if needed
        }
      },
      child: const Text('Login'),
    );
  }

  Widget _condition() {
    return Center(
      child: Text(
        '$text1',
        style: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 34.0,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        shadowColor: Colors.white,
        title: _title(),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          children: [
            SingleChildScrollView(
              child: Container(
                height: screenHeight * 0.1,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: _condition(),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  height: 550,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(screenWidth * 0.1),
                    ),
                  ),
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _entryField('Email', _controllerUserEmail),
                      _entryField('Password', _controllerUserPassword),
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        child: _errorMessage(),
                      ),
                      _submitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
