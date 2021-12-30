import 'package:flutter/material.dart';

typedef WidgetBuilder<T> = Function(BuildContext context, T t);

class ThrowableFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final WidgetBuilder<T> builder;

  const ThrowableFutureBuilder(
      {Key? key, required this.future, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, AsyncSnapshot<T> snapshot) {
          if (snapshot.hasError) {
            final error = snapshot.error ?? '不知道怎么了。。。';

            final dialog = AlertDialog(
              title: Text('出错啦!'),
              content: Text(error.toString()),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('确定'))
              ],
            );

            showDialog(context: context, builder: (context) => dialog);
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            return builder.call(context, snapshot.data!);
          }
          return Scaffold(
              body: Center(
            child: CircularProgressIndicator(),
          ));
        });
  }
}
