import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:image_save/image_save.dart';

class ImageViewer extends StatefulWidget {
  final String url;

  const ImageViewer({Key? key, required this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  void initState() {
    super.initState();
  }

  Future<bool> saveNetworkImageToPhoto(String url) async {
    final fileName = url.split('/').last;
    try {
      Response<List<int>> res = await Dio().get<List<int>>(url,
          options: Options(responseType: ResponseType.bytes));
      final data = Uint8List.fromList(res.data!);
      return (await ImageSave.saveImage(data, fileName, albumName: "keylol"))!;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              saveNetworkImageToPhoto(widget.url).then(
                (result) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        children: [result ? Text('保存成功') : Text('保存失败')],
                        contentPadding: EdgeInsets.all(24.0),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ExtendedImageGesturePageView.builder(
        itemBuilder: (BuildContext context, int index) {
          return ExtendedImage.network(
            widget.url,
            fit: BoxFit.contain,
            mode: ExtendedImageMode.gesture,
          );
        },
        itemCount: 1,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
