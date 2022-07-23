// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tomato/screens/food_detail.dart';
import 'package:tomato/screens/const.dart';
import 'package:tomato/screens/search.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "User";
  String deliveryAddress = "address to deliver";
  String userPhoto =
      "https://www.shareicon.net/data/2016/06/27/787350_people_512x512.png";
  void _userDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    final db = FirebaseFirestore.instance;
    var result = await db.collection('/Users').doc(user!.uid).get();
    if (result.exists) debugPrint(result['deliveryAddress']);
    setState(() {
      deliveryAddress = result['deliveryAddress'];
      userName = result['name'];
      userPhoto = result['photo'];
    });
  }

  @override
  void initState() {
    super.initState();
    _userDetails();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height,
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          topWidget(size),
          SizedBox(height: 14),
          carausalWidget(size),
          SizedBox(height: 18),
          InkWell(
            onTap: () {
              debugPrint("tapped...");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchPage("", 1)));
            },
            child: searchBarWIdget(size),
          ),
          SizedBox(height: 18),
          SizedBox(
            width: 106 * size.width / 360,
            height: 20 * size.height / 640,
            child: Text(
              "Catagories",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: "Inter",
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 18),
          SizedBox(
            height: 70,
            width: double.infinity,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: foodItemList.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    width: 62 * size.width / 360,
                    height: 67 * size.height / 640,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          foodItemList[index].imageUrl,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(15),
                      color: Color(0xffff9900),
                    ),
                  );
                }),
          ),
          SizedBox(height: 18),
          SizedBox(
            width: 106 * size.width / 360,
            height: 20 * size.height / 640,
            child: Text(
              "Popular",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: "Inter",
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 18),
          SizedBox(
            height: 220,
            width: size.width - 20,
            child: displayRestaraunts(size),
          )
        ],
      ),
    );
  }

  Widget displayRestaraunts(Size size) {
    final Stream<QuerySnapshot> _foodsStream =
        FirebaseFirestore.instance.collection('Foods').snapshots();
    return StreamBuilder<QuerySnapshot>(
        stream: _foodsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          return ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> document =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return itemBuilder(size, document);
              });
        });
  }

  Widget itemBuilder(Size size, Map<String, dynamic> document) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 1,
        right: 10,
      ),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return FoodDetail(document);
            }));
          },
          child: foodItem(size, document),
        ),
      ),
    );
  }

  Container foodItem(Size size, Map<String, dynamic> document) {
    return Container(
      width: 130 * size.width / 360,
      height: 140 * size.height / 640,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(15),
        ),
        border: Border.all(
          color: Color(0xffcdcdcd),
          width: 2,
        ),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              document['title'],
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: "Inter",
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 7),
          Container(
            width: 100 * size.width / 360,
            height: 100 * size.height / 640,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(document["imageUrl"]),
                fit: BoxFit.cover,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.orange,
                width: 2,
              ),
              color: Color(0xffd9d9d9),
            ),
          ),
          SizedBox(height: 7),
          Text(
            "Rs. " + document["price"],
            style: TextStyle(
              fontSize: 15,
              fontFamily: "Inter",
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Container carausalWidget(Size size) {
    return Container(
      width: 340 * size.width / 360,
      height: 100 * size.height / 640,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xffff2626),
      ),
      padding: const EdgeInsets.only(
        left: 189,
        right: 23,
        top: 15,
        bottom: 6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 123 * size.width / 360,
            height: 26 * size.height / 640,
            child: Text(
              "Up to 49% off",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: "Inter",
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 4),
          SizedBox(
            width: 123 * size.width / 360,
            height: 16 * size.height / 640,
            child: Text(
              "Jan 12 - Feb 10",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: "Inter",
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 4),
          Container(
            width: 95 * size.width / 360,
            height: 30 * size.height / 640,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xffff9900),
            ),
            child: Center(
              child: Text(
                "Ordere Now",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container topWidget(Size size) {
    return Container(
      width: size.width,
      height: 70 * size.height / 640,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: Text(
                  "Hi $userName",
                  style: TextStyle(
                    color: Color(0xffff9900),
                    fontSize: 18,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.orange,
                    ),
                    SizedBox(
                      width: 150,
                      child: Text(
                        deliveryAddress,
                        style: TextStyle(
                          overflow: TextOverflow.clip,
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(width: 103 * size.width / 411),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage(userPhoto)),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xffff9900),
                width: 2,
              ),
              color: Color(0xffd9d9d9),
            ),
          ),
        ],
      ),
    );
  }

  Container searchBarWIdget(Size size) {
    return Container(
      width: 340 * size.width / 360,
      height: 40 * size.height / 640,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xffff9900),
          width: 2,
        ),
        color: Colors.white,
      ),
      padding: const EdgeInsets.only(
        left: 16,
        right: 77,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(Icons.search),
          SizedBox(width: 14),
          Text(
            "Search Your Favorite Food",
            style: TextStyle(
              color: Color(0xff4b4b4b),
              fontSize: 16,
              fontFamily: "Inter",
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
