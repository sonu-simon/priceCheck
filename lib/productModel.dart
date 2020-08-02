class Product {
  String productName;
  String productASIN;
  String productPrice;
  String productUrl;

  Product(
      {this.productASIN, this.productName, this.productPrice, this.productUrl});
}

List<Product> products = [];
