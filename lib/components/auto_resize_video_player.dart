import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AutoResizeVideoPlayer extends StatefulWidget {
  final String initialUrl;

  const AutoResizeVideoPlayer({Key? key, required this.initialUrl})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AutoResizeVideoPlayerState();
}

class _AutoResizeVideoPlayerState extends State<AutoResizeVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  double? _height;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(widget.initialUrl)
      ..initialize().then((_) {
        _chewieController = ChewieController(
            videoPlayerController: _controller, allowFullScreen: false);
        setState(() {
          final mWidth = MediaQuery.of(context).size.width;
          _height = (mWidth / _controller.value.size.width) *
              _controller.value.size.height;
        });
      });
  }

  @override
  void dispose() {
    if (_controller.value.isInitialized) {
      _chewieController.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _controller.value.isInitialized
        ? Container(
            height: _height, child: Chewie(controller: _chewieController))
        : Container(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()));
  }
}
