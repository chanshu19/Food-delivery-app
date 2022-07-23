import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tomato/screens/myOrder/order_details.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({Key? key}) : super(key: key);

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  final db = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> myOrderList = [];
  _fetchData(String query) async {
    final db = FirebaseFirestore.instance;
    var result =
        await db.collection('/Orders').where('orderBy', isEqualTo: query).get();
    for (var doc in result.docs) {
      debugPrint(doc['phone']);
      myOrderList.add(doc);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchData(user!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        elevation: 0,
        backgroundColor: Colors.white30,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: myOrderList.isNotEmpty
            ? ListView.builder(
                itemCount: myOrderList.length,
                itemBuilder: (context, i) {
                  QueryDocumentSnapshot<Map<String, dynamic>> ds =
                      myOrderList[i];
                  return Card(
                    elevation: 3,
                    child: ListTile(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return OrderDetails(ds);
                        }));
                      },
                      leading: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(ds['order']['imageUrl']),
                          ),
                        ),
                      ),
                      title: Text(ds['order']['title']),
                      subtitle: Text(
                        ds['orderStatus'],
                        style: TextStyle(
                            color: ds['orderStatus'] == "Delivered"
                                ? Colors.green
                                : Colors.red),
                      ),
                      trailing: Text(ds['totalPrice'].toString()),
                    ),
                  );
                })
            : const Center(
                child: Text("No orders"),
              ),
      ),
    );
  }
}
