import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:keylol_flutter/common/constants.dart';
import 'package:logger/logger.dart';

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
}

class Avatar extends StatelessWidget {
  final String uid;
  final AvatarSize size;
  final double width;
  final bool clip;

  const Avatar({
    Key? key,
    required this.uid,
    this.size = AvatarSize.middle,
    required this.width,
    this.clip = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatarUrl = size.avatarUrl + uid;

    return FutureBuilder(
        future: _isSvg(avatarUrl),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          late Widget avatar;
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.data!) {
              avatar = CachedNetworkImage(
                width: width,
                height: width,
                imageUrl: avatarUrl,
                placeholder: (context, url) =>
                    Image.asset('images/unknown_avatar.jpg'),
                errorWidget: (context, url, error) =>
                    Image.asset('images/unknown_avatar.jpg'),
              );
            } else {
              avatar = Image.asset(
                'images/unknown_avatar.jpg',
                width: width,
                height: width,
              );
            }
          } else {
            avatar = Image.asset(
              'images/unknown_avatar.jpg',
              width: width,
              height: width,
            );
          }

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
                Navigator.of(context).pushNamed('/space', arguments: uid);
              },
              child: child);
        });
  }

  Future<bool> _isSvg(avatarUrl) async {
    final file = await DefaultCacheManager().getFileFromCache(avatarUrl);
    if (file != null) {
      if (file.file.path.endsWith('.svg')) {
        await DefaultCacheManager().removeFile(avatarUrl);
        return true;
      }
      return false;
    }

    final response = await Dio().head(avatarUrl);
    return response.redirects.any((redirect) {
      return redirect.location.path.contains('noavatar.svg');
    });
  }
}
