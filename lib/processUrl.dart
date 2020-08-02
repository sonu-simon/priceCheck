import 'package:amazon_kt/productModel.dart';
import 'package:http/http.dart' as http;

processUrl(String url) async {
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
        products.add(Product(
            productASIN: amazonASIN,
            productName: amazonName,
            productPrice: amazonPrice,
            productUrl: amazonURL));
        products.forEach((element) {
          print(element.productName);
        });
      } else {
        Product product = Product(
            productASIN: amazonASIN,
            productName: amazonName,
            productPrice: amazonPrice,
            productUrl: amazonURL);
        products[foundProductAt] = product;
      }
    }
  }
}
