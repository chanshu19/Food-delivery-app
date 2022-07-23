import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tomato/screens/food_detail.dart';

class SearchPage extends StatefulWidget {
  final int toShowBackButton;
  final String query;
  const SearchPage(this.query, this.toShowBackButton, {Key? key})
      : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController queryController = TextEditingController();
  List<Map<String, dynamic>> searchResultList = [];
  _fetchData(String query) async {
    final db = FirebaseFirestore.instance;
    var result =
        await db.collection('Foods').where('tags', arrayContains: query).get();
    for (var doc in result.docs) {
      searchResultList.add(doc.data());
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.query != "") {
      _fetchData(widget.query.toLowerCase());
    }
    setState(() {
      queryController.text = widget.query;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          leading: widget.toShowBackButton == 1
              ? IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.orangeAccent,
                  ),
                )
              : Container(),
          backgroundColor: Colors.white,
          elevation: 3,
          title: SizedBox(
            height: 40,
            child: TextField(
              autofocus: true,
              controller: queryController,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                // hintText: "Search...",
                // hintStyle: TextStyle(
                //   fontSize: 18,
                //   fontWeight: FontWeight.w500,
                // ),
              ),
              onSubmitted: (value) async {
                final db = FirebaseFirestore.instance;
                var result = await db
                    .collection('Foods')
                    .where('tags', arrayContains: value.toLowerCase())
                    .get();
                for (var doc in result.docs) {
                  searchResultList.add(doc.data());
                }
                setState(() {});
                debugPrint(value);
              },
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  queryController.text = "";
                  searchResultList = [];
                });
              },
              icon: const Icon(
                Icons.clear,
                color: Colors.red,
              ),
            )
          ],
        ),
        body: queryController.text == ""
            ? const Center(child: Text("search here"))
            : ListView.builder(
                itemCount: searchResultList.length,
                itemBuilder: (context, index) {
                  return itemBuilder(size, searchResultList[index]);
                }));
  }

  // itemBuilder
  Widget itemBuilder(Size size, Map<String, dynamic> document) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return FoodDetail(document);
            }));
          },
          child: SizedBox(
            height: size.height / 2.7,
            width: size.width,
            child: Column(
              children: [
                Container(
                  height: size.height / 4,
                  width: size.width,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(document["imageUrl"]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 12,
                  width: size.width / 1.2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        document["title"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.green,
                        ),
                        height: size.height / 25,
                        width: size.width / 7,
                        child: Text(
                          document["rating"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: size.width / 1.2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        document["hotel"],
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Rs: " + document["price"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
