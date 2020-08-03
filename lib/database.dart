import 'dart:convert';
import 'dart:io';

import 'package:amazon_kt/productModel.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseReference {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // For your reference print the AppDoc directory
    // print(directory.path);
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.txt');
  }

  Future<File> writeContent() async {
    final file = await _localFile;
    print('writing in progress');

    String jsonProducts = jsonEncode(products);
    // print(jsonProducts);
    // Write the file
    return file.writeAsString(jsonProducts);
  }

  Future<String> readcontent() async {
    try {
      final file = await _localFile;
      print('reading in progress');

      // Read the file
      String contents = await file.readAsString();
      // print(contents);
      writeToProducts(contents);
      return contents;
    } catch (e) {
      // If there is an error reading, return a default String
      return 'Error';
    }
  }

  writeToProducts(String stringProducts) {
    // print('entered writeToProducts');
    List<dynamic> pdtList = json.decode(stringProducts);
    List<Product> tempList = [];
    pdtList.forEach((element) {
      Product pdt = Product(
        productName: element['productName'],
        productASIN: element['productASIN'],
        productPrice: element['productPrice'],
        productUrl: element['productUrl'],
        priceHistory: element['priceHistory'],
      );
      tempList.add(pdt);
    });
    products = tempList;

    print('read successful : $products');
    print('products.length : ${products.length}');
  }
}
