import 'package:flutter/cupertino.dart';

class Product {
  String productName;
  String productASIN;
  String productPrice;
  String productUrl;
  List<String> priceHistory;

  Product({
    this.productASIN,
    this.productName,
    this.productPrice,
    this.productUrl,
    this.priceHistory,
  });
}

List<Product> products = [];
