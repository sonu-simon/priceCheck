import 'dart:async';

import 'package:amazon_kt/processUrl.dart';
import 'package:flutter/cupertino.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

StreamSubscription _intentDataStreamSubscription;

initRcvShare(BuildContext context) {
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

disposeRcvShare() {
  _intentDataStreamSubscription.cancel();
}
