import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tomato/screens/home.dart';

class PaymentSummary extends StatefulWidget {
  const PaymentSummary({Key? key}) : super(key: key);

  @override
  _PaymentSummaryState createState() => _PaymentSummaryState();
}

class _PaymentSummaryState extends State<PaymentSummary> {
  final User? user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;
  List<ListTile> ordersList = [];
  String phone = "";
  String deliveryAddress = "";
  int lengthOfItems = 0;
  void _fetchPhoneAndAddress() async {
    var result = await db.collection('/Users').doc(user!.uid).get();
    setState(() {
      phone = result['phone'];
      deliveryAddress = result['deliveryAddress'];
    });
  }

  void _fetchOrders() async {
    var result = await db.collection("/Users/${user!.uid}/mycart").get();
    for (var doc in result.docs) {
      ordersList.add(ListTile(
        leading: Text(doc['qty']),
        title: Text(doc['title']),
        subtitle: Text(doc['hotel']),
        trailing: Text(doc['price']),
      ));
    }
    setState(() {
      lengthOfItems = result.docs.length;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPhoneAndAddress();
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Summary"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text(user!.displayName!),
              subtitle: Text(deliveryAddress),
            ),
            const Divider(),
            ListTile(
              title: const Text("Phone"),
              subtitle: Text(phone),
            ),
            const Divider(),
            ExpansionTile(
              title: Text("Ordered items $lengthOfItems"),
              children: ordersList,
            ),
            const Divider(),
            StreamBuilder<QuerySnapshot>(
              stream: db.collection("/Users/${user!.uid}/mycart").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading");
                }
                int itemTotal = 0;
                int tax = 0;
                int deliveryServices = 0;
                for (var doc in snapshot.data!.docs) {
                  itemTotal += int.parse(doc['price']) * int.parse(doc['qty']);
                }
                int total = itemTotal + tax + deliveryServices;
                return priceDetails(itemTotal, tax, deliveryServices, total);
              },
            ),
            const ListTile(
              title: Text("Payment Options:"),
              subtitle: Text("Cash on delivery"),
            ),
            placeOrderButton(),
          ],
        ),
      ),
    );
  }

  Widget placeOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Card(
        elevation: 3,
        color: Colors.black,
        child: InkWell(
          onTap: () async {
            addOrderToDB().whenComplete(() {
              showModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                    top: Radius.circular(25),
                  )),
                  isDismissible: false,
                  context: context,
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'images/vector4.png',
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                          const Text(
                            "Thank You!",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "For your order",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return const Home(0);
                              }));
                            },
                            child: const Text("Go to Home"),
                          )
                        ],
                      ),
                    );
                  });
            });
          },
          child: const Center(
            child: Text(
              "Place Order",
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
    return Column(children: [
      ListTile(
        title: Text(itemTotal.toString()),
        subtitle: const Text("itemTotal"),
      ),
      ListTile(
        title: Text(tax.toString()),
        subtitle: const Text("tax"),
      ),
      ListTile(
        title: Text(deliveryServices.toString()),
        subtitle: const Text("deliveryServices"),
      ),
      ListTile(
        title: Text(total.toString()),
        subtitle: const Text("total"),
      ),
    ]);
  }

  addOrderToDB() async {
    var result = await db.collection('Users/${user!.uid}/mycart').get();
    if (result.docs.isEmpty) return;
    CollectionReference myOrder = db.collection("/Orders");
    for (var doc in result.docs) {
      myOrder.add({
        "customerName": user!.displayName,
        "phone": phone,
        "orderBy": user!.uid,
        "orderStatus": "pending",
        "deliveryAddress": deliveryAddress,
        "order": doc.data(),
        "paymentStatus": "payondelivery",
        "totalPrice": int.parse(doc['qty']) * int.parse(doc['price'])
      });
    }
  }
}
