import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:djec_app/firebaseAuth/auth.dart';
import 'adminuserpageorbuttons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = "";
  String? erro1 = "Create New Account";
  String textTop1 = "Admin LogIn";
  String textTop2 = "Add User";
  bool isLogin = true;
  bool _isPasswordVisible = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      // Check if the email starts with "admin"
      if (_controllerEmail.text.toLowerCase().startsWith('admin')) {
        await Auth().signInWithEmailAndPassword(
          adminEmail: _controllerEmail.text,
          adminPassword: _controllerPassword.text,
        );
      } else {
        setState(() {
          errorMessage = "Invalid email for admin login";
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = "$e";
      });
    }
  }

  Widget _title() {
    return Text(
      'BSmart app',
      style: TextStyle(
        fontSize: 24.0, // Adjust font size
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
        ),
      ),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : 'Hmm.. $errorMessage $erro1',
      style: TextStyle(
        color: Colors.red,
        fontSize: 16.0, // Adjust font size
      ),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (isLogin) {
          await signInWithEmailAndPassword();
          if (FirebaseAuth.instance.currentUser != null) {
            setState(() {
              isLogin = !isLogin;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Admin logged in successfully! Now add a user.'),
                duration: Duration(seconds: 5),
              ),
            );

            _controllerEmail.text = '';
            _controllerPassword.text = '';

            setState(() {
              errorMessage = '';
            });
          }
        } else {
          await createUserWithEmailAndPassword();
          if (FirebaseAuth.instance.currentUser != null) {
            setState(() {
              Navigator.pushReplacement(
                context,
                // ignore: non_constant_identifier_names
                MaterialPageRoute(
                    builder: (context) => PagesScreen(
                          pageProvider: PageProvider(),
                          sendDataToESP32: (Uint8List) {},
                        )),
              );
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('User added successfully! Now add pages.'),
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      },
      child: Text(isLogin ? 'Login' : 'Add User'),
    );
  }

  Widget _condition1() {
    return Text(
      isLogin ? '$textTop1' : '$textTop2',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 34.0, // Adjust font size
        fontWeight: FontWeight.w300,
        color: Colors.white,
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
        padding: EdgeInsets.all(screenWidth * 0.05), // Adjust padding
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.1, // Adjust height
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: _condition1(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  height: 550,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft:
                          Radius.circular(screenWidth * 0.1), // Adjust radius
                    ),
                  ),
                  padding: EdgeInsets.all(screenWidth * 0.05), // Adjust padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _entryField('Email', _controllerEmail),
                      TextField(
                        controller: _controllerPassword,
                        obscureText: _isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            child: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(
                            screenWidth * 0.02), // Adjust padding
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
