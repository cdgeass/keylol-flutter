import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/authentication/authentication.dart';
import 'package:keylol_flutter/app/home/avatar_action.dart';
import 'package:keylol_flutter/app/home/bloc/forum_index/forum_index_bloc.dart';
import 'package:keylol_flutter/components/authentication_bloc_provider.dart';

class ForumIndexView extends StatefulWidget {
  final GlobalKey<ScaffoldState> homeKey;

  const ForumIndexView({Key? key, required this.homeKey}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ForumIndexViewState();
}

class _ForumIndexViewState extends State<ForumIndexView>
    with AutomaticKeepAliveClientMixin {
  late int _currentIndex;

  @override
  void initState() {
    _currentIndex = 0;

    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  Widget _buildTabBar(BuildContext context, List<Cat> cats) {
    double maxWidth = 56;
    final labelStyle = Theme.of(context).textTheme.labelLarge!;
    for (final cat in cats) {
      final size = _textSize(cat.name, labelStyle);
      final tempWidth = size.width + 16;
      if (maxWidth < tempWidth) {
        maxWidth = tempWidth;
      }
    }
    List<Widget> destinations = [];
    for (var i = 0; i < cats.length; i++) {
      final cat = cats[i];
      final firstCat = Material(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: InkWell(
          radius: 16.0,
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          onTap: () {
            setState(() {
              _currentIndex = i;
            });
          },
          child: Container(
            width: maxWidth,
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              cat.name,
              textAlign: TextAlign.center,
              style: labelStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
      final secondCat = Material(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        color: Theme.of(context).colorScheme.surface,
        child: InkWell(
          radius: 16.0,
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          onTap: () {
            setState(() {
              _currentIndex = i;
            });
          },
          child: Container(
            width: maxWidth,
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              cat.name,
              textAlign: TextAlign.center,
              style: labelStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );

      destinations.add(
        AnimatedCrossFade(
          duration: const Duration(microseconds: 200),
          firstChild: firstCat,
          secondChild: secondCat,
          crossFadeState: _currentIndex == i
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
        ),
      );
      destinations.add(SizedBox(height: 12.0));
    }
    return Container(
      color: Theme.of(context).colorScheme.surface,
      width: 12 + maxWidth + 12,
      padding: EdgeInsets.only(top: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: destinations,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text('版块'),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                widget.homeKey.currentState?.openDrawer();
              },
            ),
            actions: [
              Container(
                padding: EdgeInsets.all(9.0),
                child: AvatarAction(),
                width: 48.0,
                height: 48.0,
              ),
            ],
          ),
          body: AuthenticationBlocProvider(
            create: (_) =>
                ForumIndexBloc(client: context.read<KeylolApiClient>())
                  ..add(ForumIndexReloaded()),
            event: ForumIndexReloaded(),
            child: BlocBuilder<ForumIndexBloc, ForumIndexState>(
              builder: (context, state) {
                if (state.cats == null ||
                    state.status != ForumIndexStatus.success) {
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final cats = state.cats ?? const [];
                Widget tabBar = _buildTabBar(context, cats);

                final forums = cats[_currentIndex].forums;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    tabBar,
                    VerticalDivider(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: forums.length,
                        itemBuilder: (context, index) {
                          final forum = forums[index];
                          late Widget leading;
                          if (forum.icon == null) {
                            leading = Image.asset('images/forum.gif');
                          } else {
                            leading = Image.network(forum.icon!);
                          }
                          return ListTile(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/forum',
                                arguments: forum.fid,
                              );
                            },
                            leading: Container(
                              child: ClipOval(
                                child: leading,
                              ),
                              width: 40.0,
                              height: 40.0,
                            ),
                            title: Text(forum.name),
                          );
                        },
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
