import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsView extends StatefulWidget {
  String url;
   NewsView(this.url, {Key? key}) : super(key: key);

  @override
  _NewsViewState createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {

  late String finalUrl;
  final Completer<WebViewController> controller =Completer<WebViewController>();
@override
  void initState() {
    if(widget.url.toString().contains('http://')){
      finalUrl = widget.url.toString().replaceAll('http://', 'https://');
    }
    else {
      finalUrl = widget.url;
    }super.initState();
  }

  @override
  build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Container(
          child: WebView(
            initialUrl: finalUrl,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController){
              setState(() {
                controller.complete(webViewController);
              });
            },
          ),
        ),
      ),
    );
  }
}
