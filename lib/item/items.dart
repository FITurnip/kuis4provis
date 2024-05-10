import 'package:flutter/material.dart';
import 'package:kuis4/auth/auth.dart';
import 'package:kuis4/auth/shared_preferences_helper.dart';
import 'package:kuis4/cart/carts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kuis4/test_oauth.dart';

class FoodListPage extends StatefulWidget {
  @override
  _FoodListPageState createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  List<Map<String, dynamic>> foodList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Map<int, int> quantityMap = {};

  void fetchData() async {
    final String clientId = '${await SharedPreferencesHelper.getPreference('user_id')}';
    final String clientToken = await SharedPreferencesHelper.getPreference('access_token');

    final response = await http.get(
      Uri.parse('http://146.190.109.66:8000/items'),
      headers: {
        'Authorization': 'Bearer $clientToken',
        'Client-ID': clientId,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        foodList.clear();
        List<dynamic> jsonData = json.decode(response.body);
        jsonData.forEach((item) {
          foodList.add(Map<String, dynamic>.from(item));
        });
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food List'),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showDialog(context: context, builder: (context) {
                return AlertDialog(
                  title: Text('Logout'),
                  content: Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        SharedPreferencesHelper.deletePreference('user_id');
                        SharedPreferencesHelper.deletePreference('access_token');
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginRegisterPage()), (route) => false);
                      },
                      child: Text('Logout'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                  ],
                );
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CartPage(foodList: foodList)));
            }
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 3 / 4,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    // Add your search onPressed logic here
                  },
                  child: Icon(Icons.search))
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foodList.length,
              itemBuilder: (BuildContext context, int index) {
                final food = foodList[index];
                final int itemId = food['id'];
                return ListTile(
                  leading: ImageDownloadWidget('http://146.190.109.66:8000/items_image/${itemId}'),
                  title: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              food['title'],
                              style: TextStyle(fontSize: 14.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              food['description'],
                              style: TextStyle(fontSize: 12.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text('Rp${food['price']}',
                                style: TextStyle(fontSize: 12.0)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (quantityMap.containsKey(itemId)) {
                              if (quantityMap[itemId]! > 0) {
                                quantityMap[itemId] = quantityMap[itemId]! - 1;
                              }
                            }
                          });
                        },
                      ),
                      Text(
                        quantityMap[itemId]?.toString() ?? '0',
                        style: TextStyle(fontSize: 20),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            if (quantityMap.containsKey(itemId)) {
                              quantityMap[itemId] = quantityMap[itemId]! + 1;
                            } else {
                              quantityMap[itemId] = 1;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Handle item tap
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
