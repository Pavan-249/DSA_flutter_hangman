import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hangman/login_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'rounded_button.dart';
import 'constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.0),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xff134E5E), Color(0xff71B280)],
            )),
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
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      filled: true,
                      fillColor: Colors.amber,
                      hintText: 'Enter your email'),
                  style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 20,
                      fontWeight: FontWeight.w900),
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
                  decoration: kTextFieldDecoration.copyWith(
                      filled: true,
                      fillColor: Colors.amber,
                      hintText: 'Enter your password'),
                  style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 20,
                      fontWeight: FontWeight.w900),
                ),
                SizedBox(
                  height: 24.0,
                ),
                RoundedButton(
                  title: 'Register',
                  colour: Colors.blueAccent,
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });
                    try {
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                              email: email, password: password);
                      if (newUser != null) {
                        Alert(
                          context: context,
                          type: AlertType.success,
                          title: "Registration Successful",
                          desc: 'You can now login..!',
                          buttons: [
                            DialogButton(
                              radius: BorderRadius.circular(10),
                              child: Icon(
                                MdiIcons.arrowRightThick,
                                size: 30.0,
                              ),
                              onPressed: () async {
                                Navigator.pushNamed(context, LoginScreen.id);
                              },
                              width: 127,
                              color: Theme.of(context).primaryColor,
                              height: 52,
                            ),
                          ],
                        ).show();
                      }

                      setState(() {
                        showSpinner = false;
                      });
                    } catch (errorMsg) {
                      
                      setState(() {
                        showSpinner = false;
                        Alert(
                      context: context,
                      type: AlertType.error,
                      title: "Incorrect credentials",
                      desc: "User may/may not be already registered",
                      buttons: [
                        DialogButton(
                          radius: BorderRadius.circular(10),
                          child: Icon(
                            MdiIcons.arrowRightThick,
                            size: 30.0,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          width: 127,
                          color: Theme.of(context).primaryColor,
                          height: 52,
                        ),
                      ],
                    ).show();
                      });
                    }
                  },
                ),
                RoundedButton(
                  title: 'Log In instead',
                  colour: Colors.lightBlueAccent,
                  onPressed: () {
                    Navigator.pushNamed(context, LoginScreen.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
