import 'package:flutter/material.dart';
import 'package:kuis4/cart/payment.dart';

class CartPage extends StatelessWidget {
  late List<Map<String, dynamic>> foodList;

  CartPage({required this.foodList}) {
    this.foodList = foodList;
  }

  final List<Map<String, dynamic>> cartItems = [
    {
      "item_id": 1,
      "user_id": 1,
      "quantity": 2,
      "id": 1
    },
    {
      "item_id": 2,
      "user_id": 1,
      "quantity": 1,
      "id": 2
    },
    {
      "item_id": 3,
      "user_id": 1,
      "quantity": 3,
      "id": 3
    }
  ];

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
                Text('Status : '),
                ElevatedButton(onPressed: () {}, child: Icon(Icons.refresh))
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (BuildContext context, int index) {
                final cartItem = cartItems[index];
                final foodItem = foodList.firstWhere((food) => food['id'] == cartItem['item_id']);
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
                              // Decrease quantity logic
                            },
                          ),
                          Text('${cartItem['quantity']}'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              // Increase quantity logic
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
                onPressed: () {
                  // Add your clear cart logic here
                },
                child: Text('Clear Cart'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: ((context) => PaymentPage(foodList: foodList))));
                },
                child: Text('Proceed to Payment'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
