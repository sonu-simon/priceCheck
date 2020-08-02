import 'package:amazon_kt/processUrl.dart';
import 'package:amazon_kt/productModel.dart';
import 'package:amazon_kt/receiveShare.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  @override
  void initState() {
    super.initState();
    initRcvShare(context);
  }

  @override
  void dispose() {
    super.dispose();
    disposeRcvShare();
  }

  @override
  Widget build(BuildContext context) {
    return
        // triggerSetState
        // ? AlertDialog(
        //     shape:
        //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        //     title: Text("Add task"),
        //     content: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: <Widget>[
        //         RaisedButton(
        //             child: Text("OK"),
        //             onPressed: () {
        //               setState(() {
        //                 triggerSetState = false;
        //               });
        //             })
        //       ],
        //     ),
        //   )
        // :
        Scaffold(
      appBar: AppBar(
        title: Text('Amazon Prices'),
        backgroundColor: Colors.green,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {});
              }),
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
