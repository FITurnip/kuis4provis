import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kuis4/auth/shared_preferences_helper.dart';
import 'package:kuis4/barayafood_uri.dart';
import 'package:kuis4/cart/payment.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> foodList;

  CartPage({required this.foodList});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<Map<String, dynamic>> cartItems = []; // Initialize cartItems as an empty list
  late String status = "";
  late String clientId = '', clientToken = '';

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  void fetchCartItems() async {
    clientId = '${await SharedPreferencesHelper.getPreference('user_id')}';
    clientToken = await SharedPreferencesHelper.getPreference('access_token');

    final response = await http.get(
      Uri.parse('${baseUrl}carts/${clientId}?skip=0&limit=100'),
      headers: {
        'Authorization': 'Bearer $clientToken',
        'Client-ID': clientId,
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        cartItems = responseData.map((item) => item as Map<String, dynamic>).toList();
        print(cartItems);
      });

      final statusResponse = await http.get(
        Uri.parse('${baseUrl}get_status/${clientId}'),
        headers: {
          'Authorization': 'Bearer $clientToken',
          'Client-ID': clientId,
        },
      );

      if (statusResponse.statusCode == 200) {
        final dynamic statusData = json.decode(statusResponse.body);
        final String curStatus = (cartItems.length > 0 ? statusData['status']['status'] : 'No Order');
        setState(() {
          status = curStatus;
        });
      } else {
        throw Exception('Failed to get status');
      }
    } else {
      throw Exception('Failed to load cart items');
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
      fetchCartItems();
    } else {
      throw Exception('Failed to get status');
    }
  }

  void refetchCartItems() async {
    print('status' + status);
    switch(status) {
      case 'belum_bayar':
      setStatus('pembayaran');
      break;
      case 'sudah_bayar':
      setStatus('set_status_penjual_terima');
      break;
      case 'pesanan_diterima':
      setStatus('set_status_diantar');
      break;
      case 'pesanaan_diantar':
      setStatus('set_status_diterima');
      break;
      default:
      break;
    }
    fetchCartItems();
  }

  void clearCartItems() async {
    final statusResponse = await http.delete(
      Uri.parse(baseUrl + 'clear_whole_carts_by_userid/$clientId'),
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
      fetchCartItems();
    } else {
      throw Exception('Failed to get status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status :'),
                    SizedBox(width: MediaQuery.of(context).size.width / 3, child: Text('${status}', overflow: TextOverflow.clip,)),
                  ],
                ),
                ElevatedButton(
                  onPressed: refetchCartItems, // Refresh button now refreshes the cart items
                  child: Icon(Icons.refresh),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (BuildContext context, int index) {
                final cartItem = cartItems[index];
                final foodItem = widget.foodList
                    .firstWhere((food) => food['id'] == cartItem['item_id']);
                final totalPrice = cartItem['quantity'] * foodItem['price'];
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${foodItem['title']}'),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                cartItem['quantity']--;
                              });
                              removeOrder(cartItem['id']);
                              setOrder(foodItem['id'], cartItem['quantity']);
                              setInitStatus();
                            },
                          ),
                          Text('${cartItem['quantity']}'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                cartItem['quantity']++;
                              });
                              removeOrder(cartItem['id']);
                              setOrder(foodItem['id'], cartItem['quantity']);
                              setInitStatus();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  subtitle: Text('Price per item: Rp${foodItem['price']}'),
                  // Add any other details you want to display about the item
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: (status != "belum_bayar" ? null : () {
                  clearCartItems();
                }),
                child: Text('Clear Cart'),
              ),
              ElevatedButton(
                onPressed: (status != "belum_bayar" ? null : () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: ((context) => PaymentPage(foodList: widget.foodList))));
                }),
                child: Text('Checkout'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
