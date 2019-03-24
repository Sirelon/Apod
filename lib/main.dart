import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String title = "Astronomy picture";
  String imageUrl = '';
  bool isLoading = false;
  DateTime firstDate = DateTime(1995, 06, 16);
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (isLoading) {
      body = Center(child: CircularProgressIndicator());
    } else {
      body = Stack(
        children: <Widget>[
          Image.network(
            imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 3.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
            ),
          ),
          ScalableWidget(imageUrl),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Increment',
        onPressed: onFABClick,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void onFABClick() {
    //
    Future<DateTime> future = showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: firstDate,
        lastDate: DateTime.now());

    future.then((DateTime value) {
      if (value != null) {
        currentDate = value;
        fetchData();
      }
    });
  }

// https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&date=2018-01-28
  // Video example
  void fetchData() {
    setState(() {
      isLoading = true;
    });

    DateFormat format = DateFormat("yyyy-MM-dd");
    String dateStr = format.format(currentDate);
    print(dateStr);

    Future<http.Response> future = http.get(
        "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&date=$dateStr");
    future.then((http.Response response) {
      // Parsing response
      if (response.statusCode == 200) {
        // ok

        Map<String, dynamic> map = json.decode(response.body);
        String date = map["explanation"];

        setState(() {
          title = map['title'];
          imageUrl = map["hdurl"];
          isLoading = false;
        });
      }
    });

    // asdasdsa
    //
    print("ASdasdas");
  }
}

class ScalableWidget extends StatelessWidget {
  String _image;

  ScalableWidget(this._image);

  @override
  Widget build(BuildContext context) {
    NetworkImage imageProvider = NetworkImage(_image);

    return Center(
        child: PhotoView(
      imageProvider: imageProvider,
      backgroundDecoration: BoxDecoration(color: Colors.transparent),
    ));
  }
}
