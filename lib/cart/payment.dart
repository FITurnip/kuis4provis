import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  late final List<Map<String, dynamic>> foodList;

  PaymentPage({required this.foodList});

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
    int totalItems = 0;
    int totalPriceAllItems = 0;

    for (final cartItem in cartItems) {
      final foodItem = foodList.firstWhere((food) => food['id'] == cartItem['item_id']);
      final totalPrice = cartItem['quantity'] * foodItem['price'];
      totalItems += cartItem['quantity'] as int;
      totalPriceAllItems += totalPrice as int;
      print('total items ${totalItems}');
    }

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
                final foodItem = foodList.firstWhere((food) => food['id'] == cartItem['item_id']);
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
                    Navigator.pop(context);
                  },
                  child: Text('Make A Payment'),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }
}
