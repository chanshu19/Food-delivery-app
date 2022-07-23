// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:tomato/screens/home_page.dart';
import 'package:tomato/screens/myOrder/my_order.dart';
import 'package:tomato/screens/mycart/my_cart.dart';
import 'package:tomato/screens/address_page.dart';

class Home extends StatefulWidget {
  final int index;
  const Home(this.index, {Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  int index = 0;
  @override
  void initState() {
    super.initState();
    setState(() {
      index = widget.index;
    });
  }

  final screens = [
    HomePage(),
    MyCart(),
    MyOrders(),
    Address(),
  ];
  @override
  Widget build(BuildContext context) {
    final items = [
      Icon(Icons.home, size: 30),
      Icon(Icons.shopping_cart_sharp, size: 30),
      Icon(Icons.shopify, size: 30),
      Icon(Icons.location_city, size: 30),
    ];
    return Container(
      color: Colors.blue,
      child: SafeArea(
        top: false,
        child: Scaffold(
          extendBody: true,
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              iconTheme: IconThemeData(color: Colors.white),
            ),
            child: CurvedNavigationBar(
              key: navigationKey,
              animationCurve: Curves.easeInOut,
              animationDuration: Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
              buttonBackgroundColor: Colors.black,
              color: Colors.orange,
              height: 75,
              index: index,
              items: items,
              onTap: (index) {
                setState(() {
                  this.index = index;
                });
              },
            ),
          ),
          body: screens[index],
        ),
      ),
    );
  }
}
