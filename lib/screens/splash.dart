import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tomato/screens/home.dart';
import 'dart:async';

import 'package:tomato/screens/register.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), navigateTo);
  }

  void navigateTo() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint('User is currently signed out!');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Register()));
      } else {
        debugPrint('User is signed in!');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Home(0)));
      }
    }); //
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x35ff9800), Color(0xe4ff9900), Color(0xffff9900)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 76,
                child: Text(
                  "Villager's Food",
                  style: TextStyle(
                    color: Color(0xff263bff),
                    fontSize: 50,
                    fontFamily: "Jaldi",
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                height: (460 * height) / 640,
              ),
              const SizedBox(
                height: 50,
                child: Text(
                  "Made in India",
                  style: TextStyle(
                    color: Color(0xff263bff),
                    fontSize: 20,
                    fontFamily: "Jaldi",
                    fontWeight: FontWeight.w700,
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
