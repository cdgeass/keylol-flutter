import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ThreadContent extends StatelessWidget {
  final String data;

  const ThreadContent({Key? key, required this.data}) : super(key: key);

  String _formatData(String data) {
    // 折叠内容
    final collapseReg = RegExp(r'/[collapse=(.*)/]');
    final collapseMatches = collapseReg.allMatches(data);
    for (var collapseMatch in collapseMatches) {
      final title = collapseMatch.group(1);
      if (title != null) {
        data = data.replaceFirst(
            '[collapse=' + title + ']', '<collapse title="' + title + '">');
      }
    }
    data = data.replaceAll('[/collapse]', '</collapse>');

    // 折叠内容
    final spoilReg = RegExp(r'/[spoil=(.*)/]');
    final spoilMatches = spoilReg.allMatches(data);
    for (var spoilMatch in spoilMatches) {
      final title = spoilMatch.group(1);
      if (title != null) {
        data = data.replaceFirst(
            '[spoil=' + title + ']', '<spoil title="' + title + '">');
      }
    }
    data = data.replaceAll('[/spoil]', '</spoil>');

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Html(
      data: _formatData(data),
      onLinkTap: (url, _, attributes, element) {
        if (url != null && url.startsWith('https://keylol.com/')) {
          final subUrl = url.replaceFirst('https://keylol.com/', '');
          if (subUrl.startsWith('t')) {
            final tid = subUrl.split('-')[0].replaceFirst('t', '');
            Navigator.of(context).pushNamed('/thread', arguments: tid);
          } else if (subUrl.startsWith('f')) {
            final fid = subUrl.split('-')[0].replaceFirst('f', '');
            Navigator.of(context).pushNamed('/forum', arguments: fid);
          } else {
            Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
              return WebView(
                initialUrl: url,
                javascriptMode: JavascriptMode.unrestricted,
              );
            }));
          }
        }
      },
      tagsList: Html.tags..addAll(['collapse', 'spoil']),
      customRender: {
        'collapse': (context, child) {

        },
        'spoil': (context, child) {

        }
      },
    );
  }
}
