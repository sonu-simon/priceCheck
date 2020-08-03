import 'dart:async';
import 'dart:io';

import 'package:amazon_kt/database.dart';
import 'package:amazon_kt/productModel.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription _intentDataStreamSubscription;
  DatabaseReference databaseReference = DatabaseReference();

  initializeContents() async {
    print('read started');
    databaseReference.readcontent().then((_) {
      print('read Completed');
      print('updating contents');
      updateProductDetails();
    });
  }

  @override
  void initState() {
    super.initState();

    initializeContents();

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      if (value != null) processUrl(value, context);
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      if (value != null) processUrl(value, context);
    });
  }

  @override
  void dispose() {
    super.dispose();

    _intentDataStreamSubscription.cancel();
  }

  processUrl(String url, BuildContext context) async {
    print('==============================');
    print('processUrl');
    print('==============================');

    String amazonASIN = 'initialASIN';
    String responseBody = '';
    String amazonPrice = '-123';
    String amazonName;
    String amazonURL;

    int indexOfPrice = 0;
    int indexOfTitle = 0;

    print('processing new product');
    if (url == '') {
      print("URL is empty");
      amazonASIN = 'URL is empty';
    } else {
      //Extract ASIN from the URL.
      RegExp regASIN = new RegExp("dp/([A-Z0-9]{10})/");
      amazonASIN = regASIN.stringMatch(url);
      amazonASIN = amazonASIN.substring(3, 13);
      if (amazonASIN == null) {
        amazonASIN = 'nullException';
      }
      print(amazonASIN);

      //Set Amazon URL.
      amazonURL = 'https://www.amazon.in/dp/$amazonASIN';
      print(amazonURL);

      //Get response from Amazon with the provided URL.
      var response = await http.get(amazonURL);
      print('response.statusCode : ${response.statusCode}');

      //If the http request is successful the statusCode will be 200
      if (response.statusCode == 200) {
        responseBody = response.body;
        print(responseBody.indexOf('data-asin-price'));
        if (responseBody.indexOf('data-asin-price') == -1) {
          print(responseBody);
          return AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.BOTTOMSLIDE,
            title: 'Uh..Oh!',
            desc: 'new indexOf data-asin-price chathichu',
            btnOkOnPress: () {
              print('========== OK ===========');
            },
          )..show();
        }
        //Extract price of the product from the response from Amazon
        indexOfPrice = responseBody.indexOf('data-asin-price') + 17;
        print(indexOfPrice);
        String asinPriceTemp =
            responseBody.substring(indexOfPrice, indexOfPrice + 10);
        amazonPrice = asinPriceTemp.substring(0, asinPriceTemp.indexOf("\""));
        if (amazonPrice == '') {
          amazonPrice = 'Price data not available';
        }
        print(amazonPrice);

        //Extract name of the product from the response from Amazon
        indexOfTitle =
            responseBody.indexOf('a-size-large product-title-word-brea') + 47;
        String asinTitleTemp =
            responseBody.substring(indexOfTitle, indexOfTitle + 150);
        amazonName = asinTitleTemp.substring(0, asinTitleTemp.indexOf("\n"));
        print('processing: $amazonName');

        //Search if the ASIN already exits in the list.
        int flagFound = 1;
        products.forEach((product) {
          if (product.productASIN == amazonASIN) {
            flagFound = 0;
          }
        });

        print('flagFound : $flagFound');
        //If found, return dialog, else append to list.
        if (flagFound == 1) {
          Product product = Product(
              productASIN: amazonASIN,
              productName: amazonName,
              productPrice: amazonPrice,
              productUrl: amazonURL,
              priceHistory: amazonPrice);
          products.add(product);

          databaseReference.writeContent().then((_) {
            print('write successful, proceeding to setState');
            setState(() {});
          });
        } else {
          return AwesomeDialog(
            context: context,
            dialogType: DialogType.INFO,
            animType: AnimType.BOTTOMSLIDE,
            title: 'Uh..Oh!',
            desc: 'Looks like this product is already here.',
            btnOkOnPress: () {},
          )..show();
        }
      }
    }
  }

  updateProductDetails() {
    print('==============================');
    print('updateProductDetails');
    print('==============================');

    int indexOfPrice = 0;

    int forEachIndex = -1;
    products.forEach((product) async {
      ++forEachIndex;
      print('forEachIndex : $forEachIndex');
      String responseBody = '';
      String amazonPrice;
      String url = product.productUrl;
      //Get response from Amazon with the provided URL.
      var response = await http.get(url);

      //If the http request is successful the statusCode will be 200
      if (response.statusCode == 200) {
        responseBody = response.body;

        if (responseBody.indexOf('data-asin-price') == -1) {
          return AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.BOTTOMSLIDE,
            title: 'Uh..Oh!',
            desc: 'update indexOf data-asin-price chathichu',
            btnOkOnPress: () {},
          )..show();
        }

        //Extract price of the product from the response from Amazon
        indexOfPrice = responseBody.indexOf('data-asin-price') + 17;
        String asinPriceTemp =
            responseBody.substring(indexOfPrice, indexOfPrice + 10);
        amazonPrice = asinPriceTemp.substring(0, asinPriceTemp.indexOf("\""));
        if (amazonPrice == '') {
          amazonPrice = 'Price data not available';
        }
        // print(amazonPrice);
        if (amazonPrice != product.priceHistory) {
          product.priceHistory = amazonPrice;
          // print('Price changed, updating dB');
        } else {
          // print('Price remains unchanged');
        }

        //Update at index position of products list.
        Product updatedProduct = Product(
            productASIN: product.productASIN,
            productName: product.productName,
            productPrice: amazonPrice,
            productUrl: product.productUrl,
            priceHistory: product.priceHistory);
        products[forEachIndex] = updatedProduct;
      }
    });

    databaseReference.writeContent().then((_) {
      print('write successful, proceeding to setState');
      setState(() {});
    });
  }

  getTrailingWidget(String price, String history) {
    double doublePrice = double.parse(price);
    double doubleHistory = double.parse(history);

    double difference = doublePrice - doubleHistory;
    if (difference < 0) {
      return Text(
        difference.toString(),
        style: TextStyle(
            color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
      );
    } else if (difference > 0) {
      return Text(
        difference.toString(),
        style: TextStyle(
            color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amazon Prices'),
        backgroundColor: Colors.green,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: updateProductDetails,
          )
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Card(
            elevation: 20,
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(
                '₹ ${products[index].productPrice}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  products[index].productName,
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              trailing: getTrailingWidget(
                  products[index].productPrice, products[index].priceHistory),
              onTap: () {
                launch(products[index].productUrl);
              },
              onLongPress: () {
                products.removeAt(index);
                updateProductDetails();
              },
            ),
          );
        },
        itemCount: products.length,
      ),
    );
  }
}
