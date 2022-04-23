import 'package:music_rental_flutter/pages/static/static_values.dart';

class CatalogModel {
  static List<Product> products = [];

  Product getById(int id) =>
      products.firstWhere((element) => element.id == id, orElse: null);

  Product getByPosition(int pos) => products[pos];
}

class Product {
  final int id;
  final String name;
  final String desc;
  final num price;
  final String maintenance_cost;
  final String delivery_charge;
  String image;

  Product(
      {required this.id,
      required this.name,
      required this.desc,
      required this.price,
      this.maintenance_cost = "",
      this.delivery_charge = "",
      required this.image});

  factory Product.fromMap(Map<String, dynamic> map) {
    print(map);
    return Product(
      id: map["id"],
      name: map["name"],
      desc: map["description"],
      price: map["price"],
      maintenance_cost: map['maintenance_cost'].toString(),
      delivery_charge: map['delivery_charge'].toString(),
      image: map["image"] ?? StaticValues.defaultImage,
    );
  }

  toMap() => {
        "id": id,
        "name": name,
        "desc": desc,
        "price": price,
        "maintenance_cost": maintenance_cost,
        "delivery_charge": delivery_charge,
        "image": image,
      };
}
