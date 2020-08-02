import 'dart:async';

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

  @override
  void initState() {
    super.initState();

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
    String amazonASIN = 'initialASIN';
    String responseBody = '';
    String amazonPrice;
    String amazonName;
    String amazonURL;

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

      //If the http request is successful the statusCode will be 200
      if (response.statusCode == 200) {
        responseBody = response.body;

        //Extract price of the product from the response from Amazon
        int indexOfPrice = responseBody.indexOf('data-asin-price') + 17;
        String asinPriceTemp =
            responseBody.substring(indexOfPrice, indexOfPrice + 10);
        amazonPrice = asinPriceTemp.substring(0, asinPriceTemp.indexOf("\""));
        if (amazonPrice == '') {
          amazonPrice = 'Price data not available';
        }
        print(amazonPrice);

        //Extract name of the product from the response from Amazon
        int indexOfTitle =
            responseBody.indexOf('a-size-large product-title-word-brea') + 47;
        String asinTitleTemp =
            responseBody.substring(indexOfTitle, indexOfTitle + 150);
        amazonName = asinTitleTemp.substring(0, asinTitleTemp.indexOf("\n"));
        print('processing: $amazonName');

        //Search if the ASIN already exits in the list.
        int foundProductAt = -1;
        int currentIndex = -1;
        products.forEach((product) {
          currentIndex++;
          if (product.productASIN == amazonASIN) {
            foundProductAt = currentIndex;
          }
        });

        //If found, update values, else append to list.
        if (foundProductAt == -1) {
          Product product = Product(
              productASIN: amazonASIN,
              productName: amazonName,
              productPrice: amazonPrice,
              productUrl: amazonURL,
              priceHistory: [amazonPrice]);
          products.add(product);

          setState(() {});

          products.forEach((element) {
            print(element.productName);
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
    products.forEach((product) async {
      String responseBody = '';
      String amazonPrice;
      String url = product.productUrl;
      //Get response from Amazon with the provided URL.
      var response = await http.get(url);

      //If the http request is successful the statusCode will be 200
      if (response.statusCode == 200) {
        responseBody = response.body;

        //Extract price of the product from the response from Amazon
        int indexOfPrice = responseBody.indexOf('data-asin-price') + 17;
        String asinPriceTemp =
            responseBody.substring(indexOfPrice, indexOfPrice + 10);
        amazonPrice = asinPriceTemp.substring(0, asinPriceTemp.indexOf("\""));
        if (amazonPrice == '') {
          amazonPrice = 'Price data not available';
        }
        print(amazonPrice);
        product.priceHistory.add(amazonPrice);
        print(product.priceHistory);

        //Search if the ASIN already exits in the list.
        int foundProductAt = -1;
        int currentIndex = -1;
        products.forEach((productSearch) {
          currentIndex++;
          if (productSearch.productASIN == product.productASIN) {
            foundProductAt = currentIndex;
          }
        });

        Product updatedProduct = Product(
            productASIN: product.productASIN,
            productName: product.productName,
            productPrice: amazonPrice,
            productUrl: product.productUrl,
            priceHistory: product.priceHistory);
        products[foundProductAt] = (updatedProduct);

        setState(() {});
      }
    });
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
              onLongPress: () {
                launch(products[index].productUrl);
              },
            ),
          );
        },
        itemCount: products.length,
      ),
    );
  }
}
