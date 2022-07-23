import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tomato/screens/mycart/payment_summary.dart';

class MyCart extends StatefulWidget {
  const MyCart({Key? key}) : super(key: key);

  @override
  _MyCartState createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  final User? user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("My Cart"),
        centerTitle: true,
        backgroundColor: Colors.white30,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: SizedBox(
          height: size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: size.height * 0.5,
                child: displayCartItems(size),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: db.collection("/Users/${user!.uid}/mycart").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading");
                  }

                  if (snapshot.data!.docs.isEmpty) return Container();
                  int itemTotal = 0;
                  int tax = 0;
                  int deliveryServices = 0;
                  for (var doc in snapshot.data!.docs) {
                    itemTotal +=
                        int.parse(doc['price']) * int.parse(doc['qty']);
                  }
                  int total = itemTotal + tax + deliveryServices;
                  return priceDetails(itemTotal, tax, deliveryServices, total);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget displayCartItems(Size size) {
    User? user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: db.collection("/Users/${user!.uid}/mycart").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("Your cart is empty!"),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            QueryDocumentSnapshot<Object?> ds = snapshot.data!.docs[index];
            return itemBuilder(size, ds, user.uid);
          },
        );
      },
    );
  }

  Widget itemBuilder(
      Size size, QueryDocumentSnapshot<Object?> cart, String uid) {
    return Card(
      elevation: 3,
      child: SizedBox(
        height: size.height * 0.18,
        width: size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              width: size.width * 0.22,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(cart["imageUrl"]),
                  fit: BoxFit.cover,
                ),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(
              width: size.width * 0.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cart["title"],
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        (int.parse(cart["price"]) * int.parse(cart["qty"]))
                            .toString(),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      increamentDecreament(int.parse(cart["qty"]), uid, cart),
                      IconButton(
                        onPressed: () {
                          db
                              .collection("/Users/$uid/mycart")
                              .doc(cart.id)
                              .delete();
                        },
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                          size: 40,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget increamentDecreament(
      int qty, String uid, QueryDocumentSnapshot<Object?> cart) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            if (qty > 1) {
              db.collection("/Users/$uid/mycart").doc(cart.id).update({
                "qty": (qty - 1).toString(),
              });
            }
          },
          child: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.red,
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
              qty.toString(),
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
            db.collection("/Users/$uid/mycart").doc(cart.id).update({
              "qty": (qty + 1).toString(),
            });
          },
          child: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.red,
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

  Widget checkoutButton(User? user) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Card(
        elevation: 3,
        color: Colors.black,
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PaymentSummary()));
          },
          child: const Center(
            child: Text(
              "Checkout",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget priceDetails(int itemTotal, int tax, int deliveryServices, int total) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Item Total:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              itemTotal.toString(),
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Tax:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              tax.toString(),
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Delivery Services:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              deliveryServices.toString(),
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Total:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              total.toString(),
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        checkoutButton(user)
      ],
    );
  }
}
