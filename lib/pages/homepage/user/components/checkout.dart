import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:music_rental_flutter/network/network_service.dart';
import 'package:music_rental_flutter/pages/homepage/user/user_home.dart';
import 'package:music_rental_flutter/pages/models/cart.dart';
import 'package:music_rental_flutter/pages/static/static_values.dart';

import 'package:velocity_x/velocity_x.dart';

const storage = FlutterSecureStorage();

class Checkout extends StatefulWidget {
  const Checkout({Key? key}) : super(key: key);

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  @override
  var paymentMethod = ['Esewa', 'Khalti', 'Cash'];
  var selectedPaymentMethod = 'Esewa';
  var _isLoading = false;
  var _isModalOpen = false;
  Widget build(BuildContext context) {
    final CartModel _cart = VxState.store.cart;
    VxState.watch(context, on: [RemoveAllMutation]);

    return Scaffold(
        backgroundColor: StaticValues.creamColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          title: "Checkout".text.color(StaticValues.darkBluishColor).make(),
          iconTheme: IconThemeData(
            color: StaticValues.darkBluishColor,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              "Payment Information"
                  .text
                  .xl2
                  .align(TextAlign.left)
                  .color(StaticValues.darkBluishColor)
                  .make(),
              "Payment information is the data that is required for customers to make a purchase online. This includes entering any payment methods: credit or debit card, a direct debit from a bank account, a digital wallet such as PayPal or Apple Pay, etc"
                  .text
                  .sm
                  .color(Colors.grey)
                  .make(),

              const SizedBox(
                height: 20,
              ),

              "Agreement"
                  .text
                  .xl2
                  .align(TextAlign.left)
                  .color(StaticValues.darkBluishColor)
                  .make(),

              "Agreement text here goes"
                  .text
                  .sm
                  .align(TextAlign.left)
                  .color(StaticValues.darkBluishColor)
                  .make(),

              // dropdown options for payment method: esewa khalti cash on delivery
              "Select Payment Method".text.xl.make(),

              DropdownButton<String>(
                value: selectedPaymentMethod,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 16,
                elevation: 16,
                style: TextStyle(color: StaticValues.darkBluishColor),
                onChanged: (newValue) {
                  setState(() {
                    selectedPaymentMethod = newValue!;
                  });
                },
                items: paymentMethod.map<DropdownMenuItem<String>>(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Text(value),
                      ),
                    );
                  },
                ).toList(),
              ),
              "Amount: \$${_cart.totalPrice}\nDelivery Charge: \$${_cart.totalDeliveryCharge}\nMaintence charge: \$${_cart.totalMC}"
                  .text
                  .color(StaticValues.darkBluishColor)
                  .make(),

              const SizedBox(
                height: 20,
              ),

              SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    VxBuilder(
                      mutations: {RemoveMutation},
                      builder: (context, MyStore, _) {
                        return "Total Amount :\n \$${_cart.totalAmount}"
                            .text
                            .xl2
                            .color(StaticValues.darkBluishColor)
                            .make();
                      },
                    ),
                    30.widthBox,
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        for (var element in _cart.products) {
                          NetworkService.sendAuthRequest(
                              requestType: RequestType.post,
                              url: StaticValues.apiUrlOrder,
                              body: {
                                "orderDate": DateTime.now().toString(),
                                "customerId":
                                    await storage.read(key: "customer_id"),
                                "productId": element.id,
                              });
                        }
                        setState(() {
                          _isLoading = false;
                        });
                        _isModalOpen = true;

                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                child: Column(
                                  children: [
                                    // check image form internet
                                    Image.network(
                                      "https://img.icons8.com/emoji/344/check-mark-emoji.png",
                                      height: 100,
                                    ),
                                    "Order Placed Successfully".text.xl2.make(),
                                    "Your order will be delivered within 2-3 days"
                                        .text
                                        .sm
                                        .make(),

                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        const UserHomePage()));
                                      },
                                      child: "Go to Home".text.xl2.make(),
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            StaticValues.darkBluishColor),
                      ),
                      child: "Place Order".text.white.make(),
                    ).w32(context),

                    //modal
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
