import 'package:flutter/material.dart';

class ThreadPage extends StatefulWidget {
  final String tid;

  const ThreadPage({Key? key, required this.tid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
