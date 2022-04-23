import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music_rental_flutter/pages/homepage/admin/admin_home.dart';
import 'package:music_rental_flutter/pages/login/admin_login.dart';
import 'package:music_rental_flutter/pages/static/static_values.dart';
import 'package:music_rental_flutter/widgets/my_button.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;

const storage = FlutterSecureStorage();

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  late File _image = File("assets/images/logo.png");
  // load placeholder image form Network
  final ImagePicker imagePicker = ImagePicker();
  TextEditingController name = TextEditingController();
  TextEditingController desc = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController mc = TextEditingController();
  TextEditingController delivery_charge = TextEditingController();

  @override
  void initState() {
    super.initState();
    // if token not exist
    // redirect to login widget
    storage.read(key: "userToken").then((token) {
      if (token == null) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const AdminLogin(),
            ));
      }
    });
  }

  Future chooseImage() async {
    var pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    print("\n" + pickedImage!.path + "\n");
    setState(() {
      _image = File(pickedImage.path);
    });
  }

  uploadProduct() async {
    final uri = Uri.parse(StaticValues.apiUrlProduct);
    // request with token
    var request = http.MultipartRequest('POST', uri);
    if (name.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: "Product name is Empty".text.make(),
        ),
      );
    } else if (desc.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: "Product Description needed".text.make(),
        ),
      );
    } else if (price.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: "Products Price is empty".text.make(),
        ),
      );
    } else {
      request.headers['Authorization'] =
          'Bearer ${await storage.read(key: 'userToken')}';
      // request.fields['name'] = name.text;
      // request.fields['desc'] = desc.text;
      // request.fields['price'] = price.text;

      request.fields.addAll({
        'name': name.text,
        'desc': desc.text,
        'price': price.text,
        'delivery_charge': delivery_charge.text,
        'maintenance_cost': mc.text
      });

      // append image
      request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        _image.path,
        filename: _image.path.split('/').last,
      ));

      var response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: "Products Added".text.make(),
          ),
        );
        // reset data
        name.text = "";
        desc.text = "";
        price.text = "";
        mc.text = "";
        delivery_charge.text = "";
        _image = File("assets/images/logo.png");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: "There was a problem adding the products!!".text.make(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              "Add Product".text.xl3.makeCentered(),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: name,
                decoration: const InputDecoration(
                  hintText: "Product Name",
                ),
              ),
              TextFormField(
                controller: desc,
                decoration: const InputDecoration(
                  hintText: "Description",
                ),
              ),
              TextFormField(
                controller: price,
                decoration: const InputDecoration(
                  hintText: "Price",
                ),
              ),
              TextFormField(
                controller: delivery_charge,
                decoration: const InputDecoration(
                  hintText: "Delivery Charge",
                ),
              ),
              TextFormField(
                controller: mc,
                decoration: const InputDecoration(
                  hintText: "Maintence Cost",
                ),
              ),
              IconButton(
                onPressed: () {
                  chooseImage();
                },
                icon: const Icon(Icons.camera),
              ),
              Container(
                child: _image.path == "assets/images/logo.png"
                    ? Image.asset("assets/images/logo.png")
                    : _image.path.contains("http")
                        ? Image.network(_image.path)
                        : Image.file(_image),
              ),
              const SizedBox(
                height: 20,
              ),
              MyButton(
                onPressed: () {
                  uploadProduct();
                },
                btnText: "Add Product",
                color: const [Color(0xff027f47), Color(0xff01a95c)],
              ),
            ],
          ),
        ),
      )),
    );
  }
}
