import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tomato/screens/home.dart';

class FoodDetail extends StatefulWidget {
  final Map<String, dynamic> foodData;
  const FoodDetail(this.foodData, {Key? key}) : super(key: key);

  @override
  _FoodDetailState createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  int qty = 1;
  int price = 0;

  @override
  void initState() {
    super.initState();
    price = int.parse(widget.foodData["price"]);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.foodData["title"]),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              "Rs. ${price * qty}",
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: size.height * 0.32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(widget.foodData["imageUrl"]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            increamentDecreament(),
            const SizedBox(height: 20),
            about(),
            const SizedBox(height: 20),
            addToCartButton(),
          ],
        ),
      ),
    );
  }

  Widget addToCartButton() {
    return InkWell(
      onTap: () {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          CollectionReference myCart = FirebaseFirestore.instance
              .collection("/Users/${user.uid}/mycart");
          myCart.add({
            "description": widget.foodData["description"],
            "hotel": widget.foodData["hotel"],
            "imageUrl": widget.foodData["imageUrl"],
            "price": widget.foodData["price"],
            "qty": qty.toString(),
            "rating": widget.foodData["rating"],
            "title": widget.foodData["title"],
          }).whenComplete(
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return const Home(1);
              }),
            ),
          );
        } else {
          debugPrint("user is logged OUT!");
        }
      },
      child: Container(
        height: 50,
        child: const Center(
            child: Text(
          "Add to Cart",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        )),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget increamentDecreament() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            if (qty > 1) {
              setState(() {
                qty -= 1;
              });
            }
          },
          child: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.orange,
              boxShadow: const [
                BoxShadow(
                    color: Colors.grey, blurRadius: 3.0, spreadRadius: 1.0),
              ],
            ),
            child: const Center(
              child: Text(
                "-",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          height: 30,
          child: Center(
            child: Text(
              "$qty",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        InkWell(
          onTap: () {
            setState(() {
              qty += 1;
            });
          },
          child: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.orange,
              boxShadow: const [
                BoxShadow(
                    color: Colors.grey, blurRadius: 3.0, spreadRadius: 1.0),
              ],
            ),
            child: const Center(
              child: Text(
                "+",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget about() {
    return ListTile(
      title: Text(
        widget.foodData["hotel"],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      subtitle: Text(widget.foodData["description"]),
      trailing: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.green,
        ),
        height: 35,
        width: 47,
        child: Text(
          widget.foodData["rating"] + " *",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
