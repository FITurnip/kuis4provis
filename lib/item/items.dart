import 'package:flutter/material.dart';
import 'package:kuis4/auth/auth.dart';
import 'package:kuis4/auth/shared_preferences_helper.dart';
import 'package:kuis4/barayafood_uri.dart';
import 'package:kuis4/cart/carts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kuis4/item/image_download_widget.dart';

class FoodListPage extends StatefulWidget {
  const FoodListPage({super.key});

  @override
  _FoodListPageState createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  List<Map<String, dynamic>> foodList = [];
  Map<int, int> foodCart = {}; 
  final TextEditingController _searchController = TextEditingController();
  late String clientId = "", clientToken = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Map<int, int> quantityMap = {};

  void fetchData({String url = "items"}) async {
    clientId = '${await SharedPreferencesHelper.getPreference('user_id')}';
    clientToken = await SharedPreferencesHelper.getPreference('access_token');

    final response = await http.get(
      Uri.parse(baseUrl + url),
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

  void removeOrder(int cartId) async {
    print('berhasil');
    if (clientId.isEmpty || clientToken.isEmpty) {
      print('Error: clientId or clientToken is empty.');
      return;
    }

    final Map<String, dynamic> requestBody = {
      "cart_id": cartId,
    };

    print("Request body: ${jsonEncode(requestBody)}");

    final response = await http.delete(
      Uri.parse('${baseUrl}carts/${cartId}'),
      headers: {
        'Authorization': 'Bearer $clientToken',
        'Client-ID': clientId,
        'Content-Type': 'application/json', // Specify content type as JSON
      },
      body: jsonEncode(requestBody), // Encode the request body as JSON
    );

    print("Response status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      print("Order successfully delete.");
    } else {
      throw Exception('Failed to delete order. Status code: ${response.statusCode}');
    }
    
  }

  void setOrder(int itemId, int total) async {
    if (clientId.isEmpty || clientToken.isEmpty) {
      print('Error: clientId or clientToken is empty.');
      return;
    }

    final Map<String, dynamic> requestBody = {
      "item_id": itemId,
      "user_id": int.parse(clientId),
      "quantity": total,
    };

    print("Request body: ${jsonEncode(requestBody)}");

    final response = await http.post(
      Uri.parse('${baseUrl}carts/'),
      headers: {
        'Authorization': 'Bearer $clientToken',
        'Client-ID': clientId,
        'Content-Type': 'application/json', // Specify content type as JSON
      },
      body: jsonEncode(requestBody), // Encode the request body as JSON
    );

    print("Response status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      print("Order successfully set.");
    } else {
      throw Exception('Failed to set order. Status code: ${response.statusCode}');
    }
  }

  void setStatus(String url) async {
    final statusResponse = await http.post(
      Uri.parse(baseUrl + url + '/$clientId'),
      headers: {
        'Authorization': 'Bearer $clientToken',
        'Client-ID': clientId,
      },
      body: json.encode({
        'user_id': clientId
      })
    );

    if (statusResponse.statusCode == 200) {
      print('berhasil');
    } else {
      throw Exception('Failed to get status');
    }
  }

  void setInitStatus() async {
    final statusResponse = await http.post(
      Uri.parse(baseUrl + 'set_status_harap_bayar/$clientId'),
      headers: {
        'Authorization': 'Bearer $clientToken',
        'Client-ID': clientId,
      },
      body: json.encode({
        'user_id': clientId
      })
    );

    print('body');
    if (statusResponse.statusCode == 200) {
      print("Order successfully set.");
    } else {
      throw Exception('Failed to get status');
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
                      onPressed: () async {
                        await SharedPreferencesHelper.deletePreference('user_id');
                        await SharedPreferencesHelper.deletePreference('access_token');
                        await Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginRegisterPage()), (route) => false);
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
                      fetchData(); // Fetch all items if search keyword is empty
                    } else {
                      fetchData(url: 'search_items/$keyword'); // Fetch items based on search keyword
                    }
                  },
                  child: const Icon(Icons.search))
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foodList.length,
              // make this code async with refecth
              itemBuilder: (BuildContext context, int index) {
                final food = foodList[index];
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
                            Text('Rp${food['price']}',
                                style: const TextStyle(fontSize: 12.0)),
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
                              setOrder(itemId, quantityMap[itemId]!);
                              setInitStatus();
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
                            setOrder(itemId, quantityMap[itemId]!);
                            setInitStatus();
                          });
                        },
                      ),
                    ],
                  ),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
