import 'package:amazon_kt/productModel.dart';
import 'package:http/http.dart' as http;

processUrl(String url) async {
  String amazonASIN = 'initialASIN';
  String responseBody = '';
  String amazonPrice;
  String amazonName;

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
    String amazonURL = 'https://www.amazon.in/dp/$amazonASIN';
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
      print(amazonName);

      products.add(Product(
          productASIN: amazonASIN,
          productName: amazonName,
          productPrice: amazonPrice,
          productUrl: amazonURL));
      products.forEach((element) {
        print(element.productName);
      });
    }
  }
}
