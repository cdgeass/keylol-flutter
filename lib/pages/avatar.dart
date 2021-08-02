import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String avatarUrl;
  final Size size;

  const Avatar({Key? key, required this.avatarUrl, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
        child: CachedNetworkImage(
      width: size.width,
      height: size.height,
      imageUrl: avatarUrl,
      placeholder: (context, url) => Image.asset('images/unknown_avatar.jpg'),
      errorWidget: (context, url, error) =>
          Image.asset('images/unknown_avatar.jpg'),
    ));
  }
}
