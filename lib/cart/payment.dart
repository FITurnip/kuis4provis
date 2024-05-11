import 'package:flutter/material.dart';
import 'package:kuis4/auth/shared_preferences_helper.dart';
import 'package:kuis4/barayafood_uri.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> foodList;

  PaymentPage({required this.foodList});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late List<Map<String, dynamic>> cartItems = []; // Initialize cartItems as an empty list
  late String status = "";
  late String clientId = '', clientToken = '';
  bool _isLoading = false;

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
      });
    } else {
      throw Exception('Failed to load cart items');
    }
  }

  void makeOrder() async {
    final statusResponse = await http.post(
      Uri.parse(baseUrl + 'pembayaran/$clientId'),
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

  @override
  Widget build(BuildContext context) {
    int totalItems = 0;
    int totalPriceAllItems = 0;

    for (final cartItem in cartItems) {
      final foodItem = widget.foodList.firstWhere((food) => food['id'] == cartItem['item_id']);
      final totalPrice = cartItem['quantity'] * foodItem['price'];
      totalItems += cartItem['quantity'] as int;
      totalPriceAllItems += totalPrice as int;
      print('total items ${totalItems}');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (BuildContext context, int index) {
                final cartItem = cartItems[index];
                final foodItem = widget.foodList.firstWhere((food) => food['id'] == cartItem['item_id']);
                final totalPrice = cartItem['quantity'] * foodItem['price'];

                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${foodItem['title']}',
                          overflow: TextOverflow.clip,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text('${cartItem['quantity']}', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Rp${foodItem['price']}', style: TextStyle(fontSize: 12)),
                              Text('Rp$totalPrice'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Total Items: $totalItems'),
                Text('Total Price All Items: Rp$totalPriceAllItems'),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });
                    makeOrder();
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: _isLoading ? CircularProgressIndicator() : Text('Order'),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }
}
