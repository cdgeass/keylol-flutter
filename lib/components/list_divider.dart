import 'package:flutter/material.dart';

class ListDivider extends StatelessWidget {
  final bool isLast;
  final EdgeInsetsGeometry? padding;

  const ListDivider({
    Key? key,
    required this.isLast,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLast) {
      return Container();
    }
    final divider = Divider(
      color: Theme.of(context).colorScheme.surfaceVariant,
    );
    if (padding != null) {
      return Padding(
        padding: padding!,
        child: divider,
      );
    }
    return divider;
  }
}
