import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String uid;
  final String avatarUrl;
  final Size size;
  final bool clip;

  const Avatar(
      {Key? key,
      required this.uid,
      required this.avatarUrl,
      required this.size,
      this.clip = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatar = CachedNetworkImage(
      width: size.width,
      height: size.height,
      imageUrl: avatarUrl,
      placeholder: (context, url) => Image.asset('images/unknown_avatar.jpg'),
      errorWidget: (context, url, error) =>
          Image.asset('images/unknown_avatar.jpg'),
    );

    late Widget child;
    if (clip) {
      child = ClipOval(
        child: avatar,
      );
    } else {
      child = avatar;
    }
    return InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/profile', arguments: uid);
        },
        child: child);
  }
}
