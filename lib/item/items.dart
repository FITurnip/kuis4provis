import 'package:flutter/material.dart';
import 'package:kuis4/auth/auth.dart';
import 'package:kuis4/auth/shared_preferences_helper.dart';
import 'package:kuis4/barayafood_uri.dart';
import 'package:kuis4/cart/carts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kuis4/test_oauth.dart';

class FoodListPage extends StatefulWidget {
  const FoodListPage({super.key});

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
    final String clientId =
        '${await SharedPreferencesHelper.getPreference('user_id')}';
    final String clientToken =
        await SharedPreferencesHelper.getPreference('access_token');

    final response = await http.get(
      Uri.parse('${baseUrl}items'),
      headers: {
        'Authorization': 'Bearer $clientToken',
        'Client-ID': clientId,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        foodList.clear();
        List<dynamic> jsonData = json.decode(response.body);
        for (var item in jsonData) {
          foodList.add(Map<String, dynamic>.from(item));
        }
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food List'),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              SharedPreferencesHelper.deletePreference(
                                  'user_id');
                              SharedPreferencesHelper.deletePreference(
                                  'access_token');
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          LoginRegisterPage()),
                                  (route) => false);
                            },
                            child: const Text('Logout'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    });
              },
            ),
            IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CartPage(foodList: foodList)));
                }),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 10, left: 10),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 3.0 / 4,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 15, right: 10),
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
                    child: const Icon(Icons.search))
              ],
            ),
            SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: foodList.length,
                itemBuilder: (BuildContext context, int index) {
                  final food = foodList[index];
                  final int itemId = food['id'];
                  return ListTile(
                    leading: SizedBox(
                      height: 100, // Specify your desired height
                      width: 100, // Specify your desired width
                      child: Image.network(
                        '${baseUrl}items_image/$itemId',
                        fit: BoxFit
                            .cover, // Adjust this according to your requirement
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food['title'],
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight
                                        .bold), // Mengubah ukuran dan gaya judul
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                food['description'],
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Rp${food['price']}',
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors
                                        .green), // Mengubah ukuran dan warna harga
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          iconSize: 15.0,
                          onPressed: () {
                            setState(() {
                              if (quantityMap.containsKey(itemId)) {
                                if (quantityMap[itemId]! > 0) {
                                  quantityMap[itemId] =
                                      quantityMap[itemId]! - 1;
                                }
                              }
                            });
                          },
                        ),
                        Text(
                          quantityMap[itemId]?.toString() ?? '0',
                          style: const TextStyle(fontSize: 15),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          iconSize: 15.0,
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
      ),
    );
  }
}
