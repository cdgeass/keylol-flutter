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
      child: FadeInImage(
        width: size.width,
        height: size.height,
        placeholder: AssetImage('images/unknown_avatar.jpg'),
        image: CachedNetworkImageProvider(avatarUrl),
        imageErrorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'images/unknown_avatar.jpg',
            width: size.width,
            height: size.height,
          );
        },
      ),
    );
  }
}
