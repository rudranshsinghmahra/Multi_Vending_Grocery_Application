import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_vending_grocery_app/providers/orders_provider.dart';
import 'package:multi_vending_grocery_app/services/order_services.dart';
import 'package:provider/provider.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);
  static const String id = "my-orders-screen";
  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final OrderService _orderServices = OrderService();
  User? user = FirebaseAuth.instance.currentUser;

  int tag = 0;
  List<String> options = [
    "All Orders",
    "Ordered",
    "Accepted",
    "Rejected",
    "Picked-Up",
    "Out for Delivery",
    "Delivered",
  ];

  @override
  Widget build(BuildContext context) {
    var _orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: const Text(
            "My Orders",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                CupertinoIcons.search,
                color: Colors.white,
              ),
            )
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 56,
              width: MediaQuery.of(context).size.width,
              child: ChipsChoice<int>.single(
                  // choiceStyle: const C2Choice(
                  //     borderRadius: BorderRadius.all(Radius.circular(3))),
                  value: tag,
                  onChanged: (val) {
                    if (val == 0) {
                      setState(() {
                        _orderProvider.status == null;
                      });
                    }
                    setState(() {
                      tag = val;
                      _orderProvider.status = options[val];
                    });
                  },
                  choiceItems: C2Choice.listFrom<int, String>(
                      source: options, value: (i, v) => i, label: (i, v) => v)),
            ),
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: _orderServices.orders
                    .where('userId', isEqualTo: user?.uid)
                    .where('orderStatus',
                        isEqualTo: tag > 0 ? _orderProvider.status : null)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data?.size == 0) {
                    //TODO: No orders screen
                    return Center(
                      child: Text(tag > 0
                          ? "No ${options[tag]} orders"
                          : "No Orders. Continue Shopping"),
                    );
                  }
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          return Container(
                            color: Colors.white,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 14,
                                    child: _orderServices.statusIcon(document),
                                  ),
                                  title: Text(
                                    data['orderStatus'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color:
                                          _orderServices.statusColor(document),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "On ${DateFormat.yMMMd().format(
                                      DateTime.parse(data['timestamp']),
                                    )}",
                                    style: const TextStyle(fontSize: 1),
                                  ),
                                  trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Payment Type : ${data['cod'] == true ? "Cash On Delivery" : "Paid Online"}",
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "Amount : Rs ${data['total'].toStringAsFixed(0)}",
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                //TODO: Delivery boy live location, contact number
                                if (document['deliveryBoy']['image'].length > 2)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.3),
                                        child: ListTile(
                                          leading: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: SizedBox(
                                              width: 50,
                                              height: 40,
                                              child: Image.network(
                                                document['deliveryBoy']
                                                    ['image'],
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            document['deliveryBoy']['name'],
                                          ),
                                          subtitle: Text(_orderServices
                                              .statusComment(document)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ExpansionTile(
                                  title: const Text(
                                    "Order Details",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black),
                                  ),
                                  subtitle: const Text(
                                    "View order details",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.grey),
                                  ),
                                  children: [
                                    ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: data['products'].length,
                                      shrinkWrap: true,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.white,
                                            child: Image.network(
                                                data['products'][index]
                                                    ['productImage']),
                                          ),
                                          title: Text(data['products'][index]
                                              ['productName']),
                                          subtitle: Text(
                                              "${data['products'][index]['qty']} x Rs ${data['products'][index]['price']} = Rs ${data['products'][index]['total'].toStringAsFixed(0)}"),
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12,
                                          right: 12,
                                          top: 8,
                                          bottom: 8),
                                      child: Card(
                                        elevation: 8,
                                        color: Colors.green,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Seller : ',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    data['seller']['shopName'],
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              (int.parse(data['discount']) > 0)
                                                  ? Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'Discount : ',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Text(
                                                              "${data['discount']}",
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'Discount Code: ',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Text(
                                                              "${data['discountCode']}",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    )
                                                  : Container(),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Delivery Fee: ',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "${data['deliveryFee']}",
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const Divider(
                                  height: 3,
                                  color: Colors.grey,
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
