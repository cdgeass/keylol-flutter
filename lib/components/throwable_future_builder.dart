import 'package:flutter/material.dart';

typedef KWidgetBuilder<T> = Function(BuildContext context, T t);

class ThrowableFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final KWidgetBuilder<T> builder;

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

            return Scaffold(
              body: Center(
                child: Text(error.toString()),
              ),
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
