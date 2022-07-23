// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tomato/auth/google_auth.dart';
import 'package:tomato/screens/register.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userName = "Chanshu Kumar";
  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    userName = user!.displayName!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.location_on),
          onPressed: () {},
        ),
        title: const Text("Punawan, Wazirganj"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: 140,
              child: Row(
                children: [
                  profileDetails(),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                favoriteIcon(Icons.favorite_rounded, "Favourites"),
                SizedBox(
                  width: 30,
                ),
                favoriteIcon(Icons.notifications, "Notifications"),
                SizedBox(
                  width: 30,
                ),
                favoriteIcon(Icons.settings, "Settings"),
                SizedBox(
                  width: 30,
                ),
                favoriteIcon(Icons.payments, "Payments"),
              ],
            ),
            Divider(),
            ListTile(
              title: Text("Your Orders"),
              leading: Icon(Icons.category),
              onTap: () {},
            ),
            ListTile(
              title: Text("Favotire Orders"),
              leading: Icon(Icons.favorite_border),
              onTap: () {},
            ),
            ListTile(
              title: Text("Address Book"),
              leading: Icon(Icons.book),
              onTap: () {},
            ),
            ListTile(
              title: Text("Your Bookings"),
              leading: Icon(Icons.book_online),
              onTap: () {},
            ),
            ListTile(
              title: Text("About"),
              leading: Icon(Icons.info),
              onTap: () {},
            ),
            ListTile(
              title: Text("Log Out"),
              leading: Icon(Icons.logout),
              onTap: () {
                googleSignOut(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Register()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Column favoriteIcon(IconData icons, String text) {
    return Column(
      children: [
        Icon(icons),
        Text(text),
      ],
    );
  }

  Column profileDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          userName,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
      ],
    );
  }
}
