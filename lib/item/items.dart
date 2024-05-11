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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Map<int, int> quantityMap = {};

  Future<List<Map<String, dynamic>>> fetchData({String url = "items"}) async {
  final String clientId = '${await SharedPreferencesHelper.getPreference('user_id')}';
  final String clientToken = await SharedPreferencesHelper.getPreference('access_token');

  final response = await http.get(
    Uri.parse(baseUrl + url),
    headers: {
      'Authorization': 'Bearer $clientToken',
      'Client-ID': clientId,
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    List<Map<String, dynamic>> fetchedData = [];
    for (var item in jsonData) {
      fetchedData.add(Map<String, dynamic>.from(item));
    }
    return fetchedData;
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
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(context: context, builder: (context) {
                return AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        SharedPreferencesHelper.deletePreference('user_id');
                        SharedPreferencesHelper.deletePreference('access_token');
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginRegisterPage()), (route) => false);
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
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    final String keyword = _searchController.text;
                    if (keyword.isEmpty) {
                      await fetchData(); // Wait for all items to be fetched if search keyword is empty
                    } else {
                      await fetchData(url: 'search_items/$keyword'); // Wait for items based on search keyword to be fetched
                    }
                  },
                  child: const Icon(Icons.search))
            ],
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchData(), // Assuming fetchData() returns a Future<List<Map<String, dynamic>>>
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Display a loading indicator while waiting for data
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Display an error message if fetching data fails
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                // Display the list view once data is loaded
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    final food = snapshot.data![index];
                    final int itemId = food['id'];
                    return ListTile(
                      leading: ImageDownloadWidget('${baseUrl}items_image/$itemId'),
                      title: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food['title'],
                                  style: const TextStyle(fontSize: 14.0),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  food['description'],
                                  style: const TextStyle(fontSize: 12.0),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Rp${food['price']}',
                                  style: const TextStyle(fontSize: 12.0),
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
                            style: const TextStyle(fontSize: 20),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
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
                );
              }
            },
          ),

          ),
        ],
      ),
    );
  }
}
