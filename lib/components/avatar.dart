import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';

class Avatar extends StatelessWidget {
  final String uid;
  final String? username;
  final double width;
  final double height;

  const Avatar({
    Key? key,
    required this.uid,
    this.username,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/space', arguments: uid);
      },
      child: Container(
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: uid == '0'
                ? 'https://keylol.com/static/image/common/systempm.png'
                : 'https://keylol.com/uc_server/avatar.php?uid=$uid',
            errorWidget: (context, error, stackTrace) {
              if (username == null) {
                return Image.asset('images/unknown_avatar.jpg');
              } else {
                final letter = PinyinHelper.getFirstWordPinyin(username!)
                    .toUpperCase()
                    .codeUnitAt(0);
                return Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Icon(
                    IconData(letter),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              }
            },
          ),
        ),
        width: width,
        height: height,
      ),
    );
  }
}
