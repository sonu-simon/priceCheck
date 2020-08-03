import 'package:flutter/cupertino.dart';

class Product {
  String productName;
  String productASIN;
  String productPrice;
  String productUrl;
  String priceHistory;

  Product({
    this.productASIN,
    this.productName,
    this.productPrice,
    this.productUrl,
    this.priceHistory,
  });

  // Product.fromJson(Map<String, dynamic> json)
  //     : productName = json['productName'],
  //       productASIN = json['productASIN'],
  //       productPrice = json['productPrice'],
  //       productUrl = json['productUrl'],
  //       priceHistory = json['priceHistory'];

  Map toJson() => {
        'productName': productName,
        'productASIN': productASIN,
        'productPrice': productPrice,
        'productUrl': productUrl,
        'priceHistory': priceHistory
      };
}

List<Product> products = [];
