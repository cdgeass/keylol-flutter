import 'package:flutter/material.dart';
import 'package:keylol_flutter/components/user_account_drawer.dart';

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
            final error = (snapshot.error is String
                ? snapshot.error
                : '不知道怎么了。。。') as String;

            // showDialog(
            //     context: context,
            //     builder: (context) {
            //       return AlertDialog(
            //         title: Text('出错啦'),
            //         content: Text(error),
            //         actions: [
            //           ElevatedButton(
            //               onPressed: () {
            //                 Navigator.of(context).pop();
            //               },
            //               child: Text('确定'))
            //         ],
            //       );
            //     });
            return Scaffold(
                body: Center(
              child: Text(error),
            ));
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
