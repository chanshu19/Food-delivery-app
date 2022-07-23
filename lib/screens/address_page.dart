import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tomato/auth/google_auth.dart';
import 'package:tomato/screens/register.dart';

class Address extends StatefulWidget {
  const Address({Key? key}) : super(key: key);

  @override
  _AddressState createState() => _AddressState();
}

class _AddressState extends State<Address> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String userName = "fill your name";
  String userEmail = "fill your email/gmail";
  String address = "fill your address";
  String phone = "fill your phone";

  _fetchUserData(String uid) async {
    final db = FirebaseFirestore.instance;
    var result = await db.collection('/Users').doc(uid).get();
    userName = result.data()!['name'];
    userEmail = result.data()!['email'];
    address = result.data()!['deliveryAddress'];
    phone = result.data()!['phone'];
    nameController.text = userName;
    emailController.text = userEmail;
    addressController.text = address;
    phoneController.text = phone;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    _fetchUserData(user!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () {
              final db = FirebaseFirestore.instance;
              final User? user = FirebaseAuth.instance.currentUser;
              db.collection('/Users').doc(user!.uid).update({
                "name": nameController.text,
                "phone": phoneController.text,
                "email": emailController.text,
                "deliveryAddress": addressController.text
              }).whenComplete(() => debugPrint("updated"));
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Center(
                  child: Text(
                "Update",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.orange,
                ),
              )),
            ),
          )
        ],
        title: const Text("Address"),
        backgroundColor: Colors.white30,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          child: Column(
            children: [
              inputWidget("Name", nameController),
              inputWidget("Phone", phoneController),
              inputWidget("Email", emailController),
              inputWidget("Address", addressController),
              logOutWidget(context),
            ],
          ),
        ),
      ),
    );
  }

  Card logOutWidget(BuildContext context) {
    return Card(
      elevation: 5,
      child: ListTile(
        title: const Text("Log Out"),
        leading: const Icon(
          Icons.logout,
          color: Colors.red,
        ),
        onTap: () {
          googleSignOut(context);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const Register()));
        },
      ),
    );
  }

  Widget inputWidget(String labelText, TextEditingController controller) {
    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: labelText,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
