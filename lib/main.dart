import 'dart:convert';
import 'dart:ui';

import 'package:edu_flutter/videoswidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Stellar story',
      theme: ThemeData(
        primarySwatch: Colors.purple,
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
  String title = "Stellar story";
  String imageUrl = '';
  String videoURL = '';
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
    } else if (videoURL != null) {
      // video
      print(videoURL);

      Widget bg = OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
        String img;
        if (orientation == Orientation.portrait) {
          img = "images/walle_portrait.jpg";
        } else {
          img = "images/волли.jpg";
        }

        return Image.asset(
          img,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        );
      });

      body = Stack(
        children: <Widget>[
          bg,
          Center(
            child: OutlineButton(
              onPressed: () {
                launcher.launch(videoURL);
              },
              child: Text(
                "Play Video",
                style: TextStyle(fontSize: 36.0),
              ),
              splashColor: Colors.white70,
              textColor: Color(0xFFFFE500),
            ),
          )
        ],
      );

//      body = VideoWidget(videoURL);
    } else if (imageUrl != null) {
      print(imageUrl);

      // image
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
      appBar: AppBar(
        actions: <Widget>[
          IconButton(icon: Icon(Icons.scatter_plot),
          onPressed: onInfoClick,)
        ],
          title: Text(title,
              style: TextStyle(color: Colors.limeAccent, letterSpacing: 1.2))),
      body: body,
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.event,
          color: Colors.limeAccent,
        ),
        tooltip: 'Choose Date',
        onPressed: onFABClick,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void onInfoClick(){

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

    future.then(onResponseReceived);
  }

  void onResponseReceived(http.Response response) {
    // Parsing response
    if (response.statusCode == 200) {
      // ok

      Map<String, dynamic> map = json.decode(response.body);
      String date = map["explanation"];

      setState(() {
        title = map['title'];

        String type = map["media_type"];
        if (type == "image") {
          imageUrl = map["url"];
          videoURL = null;
        } else {
          videoURL = map["url"];
          print(videoURL);
          imageUrl = null;
        }

        isLoading = false;
      });
    }
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
