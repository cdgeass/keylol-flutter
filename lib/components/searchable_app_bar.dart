import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef InputFinishCallback = void Function(String);

class SearchableAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Widget? title;
  final List? actions;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final Color? shadowColor;
  final ShapeBorder? shape;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconThemeData? iconTheme;
  final IconThemeData? actionsIconTheme;
  final bool primary;
  final bool? centerTitle;
  final bool excludeHeaderSemantics;
  final double? titleSpacing;
  final double toolbarOpacity;
  final double bottomOpacity;
  final double? toolbarHeight;
  final double? leadingWidth;
  final TextStyle? toolbarTextStyle;
  final TextStyle? titleTextStyle;
  final SystemUiOverlayStyle? systemOverlayStyle;

  final InputFinishCallback callback;
  final bool isClearAfterCallback;

  const SearchableAppBar({
    Key? key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.shadowColor,
    this.shape,
    this.backgroundColor,
    this.foregroundColor,
    this.iconTheme,
    this.actionsIconTheme,
    this.primary = true,
    this.centerTitle,
    this.excludeHeaderSemantics = false,
    this.titleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
    this.toolbarHeight,
    this.leadingWidth,
    this.toolbarTextStyle,
    this.titleTextStyle,
    this.systemOverlayStyle,
    required this.callback,
    this.isClearAfterCallback = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchableAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(
      (toolbarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0));
}

class _SearchableAppBarState extends State<SearchableAppBar> {
  bool _expanded = false;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarTheme = Theme.of(context).appBarTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = appBarTheme.foregroundColor ??
        (colorScheme.brightness == Brightness.dark
            ? colorScheme.onSurface
            : colorScheme.onPrimary);
    final titleTextStyle = appBarTheme.titleTextStyle ??
        Theme.of(context).textTheme.headline6?.copyWith(color: foregroundColor);

    return AppBar(
      leading: widget.leading,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      title: _expanded
          ? TextField(
              controller: _controller,
              style: titleTextStyle,
              cursorColor: foregroundColor,
              autofocus: true,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              onSubmitted: (text) {
                if (text.isNotEmpty) {
                  widget.callback.call(text);
                }
                if (text.isEmpty || widget.isClearAfterCallback) {
                  _controller.clear();
                  setState(() {
                    _expanded = false;
                  });
                }
              },
            )
          : widget.title,
      actions: [
        IconButton(
          icon: Icon(Icons.search_outlined),
          onPressed: () {
            setState(() {
              _expanded = true;
            });
          },
        ),
        for (final action in widget.actions ?? const []) action,
      ],
      flexibleSpace: widget.flexibleSpace,
      bottom: widget.bottom,
      elevation: widget.elevation,
      shadowColor: widget.shadowColor,
      shape: widget.shape,
      backgroundColor: widget.backgroundColor,
      foregroundColor: widget.foregroundColor,
      iconTheme: widget.iconTheme,
      actionsIconTheme: widget.actionsIconTheme,
      primary: widget.primary,
      centerTitle: widget.centerTitle,
      excludeHeaderSemantics: widget.excludeHeaderSemantics,
      titleSpacing: widget.titleSpacing,
      toolbarOpacity: widget.toolbarOpacity,
      bottomOpacity: widget.bottomOpacity,
      toolbarHeight: widget.toolbarHeight,
      leadingWidth: widget.leadingWidth,
      toolbarTextStyle: widget.toolbarTextStyle,
      titleTextStyle: widget.titleTextStyle,
      systemOverlayStyle: widget.systemOverlayStyle,
    );
  }
}
