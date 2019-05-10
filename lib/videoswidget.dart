import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  String videoUrl;

//  VideoWidget(String videoUrl){
//    this.videoUrl = videoUrl;
//  }

  VideoWidget(this.videoUrl);

  @override
  State<StatefulWidget> createState() {
    return _VideoWidgetState();
  }

}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController _controller;

  @override
  void initState() {

    _controller = VideoPlayerController.network(widget.videoUrl);
    _controller.initialize().then((v) {
      print("I AM READY");
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.initialized == false) {
      return Center(child: CircularProgressIndicator());
    }

    _controller.play();
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
