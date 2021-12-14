import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/constants.dart';

enum AvatarSize {
  small,
  middle,
  large,
}

extension AvatarSizeExtension on AvatarSize {
  String get avatarUrl {
    switch (this) {
      case AvatarSize.small:
        return AVATAR_URL_SMALL;
      case AvatarSize.middle:
        return AVATAR_URL_MIDDLE;
      case AvatarSize.large:
        return AVATAR_URL_LARGE;
    }
  }

  double get width {
    switch (this) {
      case AvatarSize.small:
        return 24.0;
      case AvatarSize.middle:
        return 32.0;
      case AvatarSize.large:
        return 64.0;
    }
  }

  double get height => width;
}

class Avatar extends StatelessWidget {
  final String uid;
  final AvatarSize size;
  final bool clip;

  const Avatar(
      {Key? key, required this.uid, required this.size, this.clip = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatarUrl = size.avatarUrl + uid;

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
