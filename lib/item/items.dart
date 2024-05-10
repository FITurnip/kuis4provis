import 'package:flutter/material.dart';
import 'package:kuis4/cart/carts.dart';

class FoodListPage extends StatefulWidget {
  @override
  _FoodListPageState createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  final List<Map<String, dynamic>> foodList = [
    {
      "title": "Mie Bakso",
      "description": "Mie Bakso gurih dengan bakso yang besar",
      "price": 12000,
      "img_name": "bakso.png",
      "id": 1
    },
    {
      "title": "Nasi Goreng",
      "description": "Nasi goreng enak dan melimpahr",
      "price": 10000,
      "img_name": "nasi_goreng.png",
      "id": 2
    },
    {
      "title": "Nasi Kuning",
      "description": "Nasi kuning lezat pisan",
      "price": 17000,
      "img_name": "nasi_kuning.png",
      "id": 3
    },
    {
      "title": "Kupat Tahu",
      "description": "Kupat Tahu dengan kuah melimpah",
      "price": 5000,
      "img_name": "kupat_tahu.png",
      "id": 4
    },
    {
      "title": "Pecel Lele",
      "description": "Pecel lele dengan ikan lele yang segar",
      "price": 11000,
      "img_name": "pecel_lele.png",
      "id": 5
    },
    {
      "title": "Ayam Geprek",
      "description": "Pecel lele dengan ikan lele yang segar",
      "price": 11000,
      "img_name": "ayam_geprek.png",
      "id": 6
    }
  ];

  Map<int, int> quantityMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food List'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => CartPage(foodList: foodList)));
            },
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
                child: Icon(Icons.search)
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foodList.length,
              itemBuilder: (BuildContext context, int index) {
                final food = foodList[index];
                final int itemId = food['id'];
                return ListTile(
                  leading: Image.network(
                    'https://i.pinimg.com/564x/1c/dc/6d/1cdc6da3ae6c904f7570aa96dba099b1.jpg',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(food['title'], style: TextStyle(fontSize: 14.0), overflow: TextOverflow.ellipsis,),
                            Text(food['description'], style: TextStyle(fontSize: 12.0), overflow: TextOverflow.ellipsis,),
                            Text('\$${food['price']}', style: TextStyle(fontSize: 12.0)),
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
