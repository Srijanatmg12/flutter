import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:music_rental_flutter/core/store.dart';
import 'package:music_rental_flutter/main.dart';
import 'package:music_rental_flutter/network/network_service.dart';
import 'package:music_rental_flutter/pages/homepage/user/components/checkout.dart';
import 'package:music_rental_flutter/pages/homepage/user/user_home.dart';
import 'package:music_rental_flutter/pages/models/cart.dart';
import 'package:music_rental_flutter/pages/static/static_values.dart';
import 'package:velocity_x/velocity_x.dart';

final storage = FlutterSecureStorage();

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StaticValues.creamColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: "Cart".text.color(StaticValues.darkBluishColor).make(),
        iconTheme: IconThemeData(
          color: StaticValues.darkBluishColor,
        ),
      ),
      body: Column(
        children: [
          _CartList().p32().expand(),
          Divider(),
          _CartTotal(),
        ],
      ),
    );
  }
}

class _CartTotal extends StatelessWidget {
  const _CartTotal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CartModel _cart = VxState.store.cart;
    VxState.watch(context, on: [RemoveAllMutation]);
    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          VxBuilder(
            mutations: {RemoveMutation},
            builder: (context, MyStore, _) {
              return "\$${_cart.totalAmount}"
                  .text
                  .xl5
                  .color(StaticValues.darkBluishColor)
                  .make();
            },
          ),
          30.widthBox,
          ElevatedButton(
            onPressed: () async {
              // for (var element in _cart.products) {
              //   NetworkService.sendAuthRequest(
              //       requestType: RequestType.post,
              //       url: StaticValues.apiUrlOrder,
              //       body: {
              //         "orderDate": DateTime.now().toString(),
              //         "customerId": await storage.read(key: "customer_id"),
              //         "productId": element.id,
              //       });
              // }
              // empty cart
              // RemoveAllMutation();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const Checkout()));
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(StaticValues.darkBluishColor),
            ),
            child: "Place Order".text.white.make(),
          ).w32(context)
        ],
      ),
    );
  }
}

class _CartList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    VxState.watch(context, on: [RemoveMutation]);
    final CartModel _cart = VxState.store.cart;
    return _cart.products.isEmpty
        ? "Nothing to show".text.xl3.makeCentered()
        : ListView.builder(
            itemCount: _cart.products.length,
            itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.done),
                  trailing: IconButton(
                    onPressed: () => RemoveMutation(_cart.products[index]),
                    icon: const Icon(
                      Icons.remove_circle_outline,
                    ),
                  ),
                  title: _cart.products[index].name.text.make(),
                ));
  }
}
