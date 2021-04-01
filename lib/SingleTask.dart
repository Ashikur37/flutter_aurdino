import 'dart:async';

import 'package:flutter/material.dart';

class SingleTask extends StatefulWidget {
  String data;
  Function fn;
  SingleTask({this.data, this.fn});
  @override
  _SingleTaskState createState() => _SingleTaskState();
}

class _SingleTaskState extends State<SingleTask> {
  Timer _clockTimer;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _clockTimer = Timer.periodic(new Duration(seconds: 3), (timer) {
      var x = widget.fn();
      setState(() {
        widget.data = x;
      });
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("child"),
      ),
      body: Container(
        child: Text(widget.data),
      ),
    );
  }
}
