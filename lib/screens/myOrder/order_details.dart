import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderDetails extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> ds;
  const OrderDetails(this.ds, {Key? key}) : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final db = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              child: Center(
                child: Text(
                  "Status: ${widget.ds['orderStatus']}",
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text(
                "Deliver to : " + widget.ds['address'],
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "Quantity: " + widget.ds['order']['qty'],
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(widget.ds['order']['imageUrl']),
                  ),
                ),
              ),
              title: Text(widget.ds['order']['title']),
              subtitle: Text(widget.ds['order']['hotel']),
              trailing: Text(widget.ds['totalPrice'].toString()),
            ),
            SizedBox(
              height: 70,
              child: Card(
                color: widget.ds['orderStatus'] == "Delivered"
                    ? Colors.green
                    : Colors.red,
                elevation: 3,
                child: InkWell(
                  onTap: () {
                    db
                        .collection("/Orders")
                        .doc(widget.ds.id)
                        .update({"orderStatus": "Delivered"});
                  },
                  child: Center(
                    child: widget.ds['orderStatus'] == "Delivered"
                        ? const Text(
                            "Delivered",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const Text(
                            "Mark as Delivered",
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
