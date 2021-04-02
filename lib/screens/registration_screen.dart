import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/Components/PaddingWidgetReusable.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'RegistrationScreen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Firebase auth instance is created
  final FirebaseAuth fu = FirebaseAuth.instance;
  String emailId;
  String password;
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  emailId = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter Your Email',
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration,
              ),
              SizedBox(
                height: 24.0,
              ),
              Paddy(
                      op: () async {
                        setState(() {
                          showSpinner = true;
                        });
                        try {
                          final newUser =
                              await fu.createUserWithEmailAndPassword(
                                  email: emailId, password: password);
                          if (newUser != null) {
                            //success
                            setState(() {
                              showSpinner = false;
                            });

                            Navigator.pushNamed(context, ChatScreen.id);
                          }
                        } catch (e) {
                          print(e);
                        }
                      },
                      textVal: 'Register',
                      bColor: Colors.blue)
                  .getPadding(),
            ],
          ),
        ),
      ),
    );
  }
}
