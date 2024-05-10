import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
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
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (BuildContext context, int index) {
                final cartItem = cartItems[index];
                return ListTile(
                  title: Text('Item ID: ${cartItem['item_id']}'),
                  subtitle: Text('Quantity: ${cartItem['quantity']}'),
                  // Add any other details you want to display about the item
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Add your payment logic here
            },
            child: Text('Proceed to Payment'),
          ),
        ],
      ),
    );
  }
}
