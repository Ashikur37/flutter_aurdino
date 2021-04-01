import 'dart:convert';
import 'dart:typed_data';
import 'package:arduino_bluetooth_tutorial/SingleTask.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class _ChatPage extends State<ChatPage> {
  String temp = "";
  String raw1 = "";
  String raw2 = "";
  String raw3 = "";
  String raw4 = "";
  String raw5 = "";
  String raw6 = "";
  String raw7 = "";

  String raw8 = "";

  String humi = "";
  String pinNum = "";
  static final clientID = 0;
  static final maxMessageLength = 4096 - 3;
  BluetoothConnection connection;

  String _messageBuffer = '';

  bool isConnecting = true;
  bool button13 = false;
  bool button12 = false;
  bool button11 = false;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  refresh() {
    return raw1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: HexColor("#1a2040"),
        appBar: AppBar(
          backgroundColor: HexColor("#00a86b"),
          title: const Text('DreisSpace'),
        ),
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: new LinearGradient(
              colors: [
                HexColor("#018250"),
                HexColor("#01f78f"),
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
            ),
          ),
          child: Center(
            child: isConnecting
                ? Text(
                    'Wait until connected...',
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Roboto"),
                  )
                : isConnected
                    ? ListView(children: <Widget>[
                        Padding(padding: EdgeInsets.only(top: 15)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SingleTask(
                                      data: raw1,
                                      fn: refresh,
                                    );
                                  },
                                ),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: HexColor("#0fa96d"),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15.0),
                                    topRight: Radius.circular(35.0),
                                    bottomLeft: Radius.circular(35.0),
                                    bottomRight: Radius.circular(15.0),
                                  ),
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.grey[200],
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.ac_unit,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'data 1 $raw1',
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "Roboto",
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SingleTask();
                                  },
                                ),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: HexColor("#0fa96d"),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(35.0),
                                    topRight: Radius.circular(15.0),
                                    bottomLeft: Radius.circular(15.0),
                                    bottomRight: Radius.circular(35.0),
                                  ),
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.grey[200],
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.lightbulb,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'data 2 $raw2',
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "Roboto",
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SingleTask();
                                  },
                                ),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: HexColor("#0fa96d"),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(35.0),
                                    topRight: Radius.circular(15.0),
                                    bottomLeft: Radius.circular(15.0),
                                    bottomRight: Radius.circular(35.0),
                                  ),
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.grey[200],
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.ac_unit,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'data 3 $raw3',
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "Roboto",
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SingleTask();
                                  },
                                ),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: HexColor("#0fa96d"),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15.0),
                                    topRight: Radius.circular(35.0),
                                    bottomLeft: Radius.circular(35.0),
                                    bottomRight: Radius.circular(15.0),
                                  ),
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.grey[200],
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.lightbulb,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'data 4 $raw4',
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "Roboto",
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SingleTask();
                                  },
                                ),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: HexColor("#0fa96d"),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15.0),
                                    topRight: Radius.circular(35.0),
                                    bottomLeft: Radius.circular(35.0),
                                    bottomRight: Radius.circular(15.0),
                                  ),
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.grey[200],
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.ac_unit,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'data 5 $raw5',
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "Roboto",
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SingleTask();
                                  },
                                ),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: HexColor("#0fa96d"),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(35.0),
                                    topRight: Radius.circular(15.0),
                                    bottomLeft: Radius.circular(15.0),
                                    bottomRight: Radius.circular(35.0),
                                  ),
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.grey[200],
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.lightbulb,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'data 6 $raw6',
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "Roboto",
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SingleTask();
                                  },
                                ),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: HexColor("#0fa96d"),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(35.0),
                                    topRight: Radius.circular(15.0),
                                    bottomLeft: Radius.circular(15.0),
                                    bottomRight: Radius.circular(35.0),
                                  ),
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.grey[200],
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.ac_unit,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'data 7 $raw7',
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "Roboto",
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SingleTask();
                                  },
                                ),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: HexColor("#0fa96d"),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15.0),
                                    topRight: Radius.circular(35.0),
                                    bottomLeft: Radius.circular(35.0),
                                    bottomRight: Radius.circular(15.0),
                                  ),
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.grey[200],
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.lightbulb,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'data 8 $raw8',
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "Roboto",
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 20.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 50, 30, 10),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "LED  ",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 50,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Roboto"),
                              ),
                              ButtonTheme(
                                minWidth: 120,
                                height: 50,
                                child: RaisedButton(
                                    color: Colors.green,
                                    child: Text(
                                      "Turn On",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () => _sendMessage('11 on')),
                              )
                            ],
                          ),
                        ),
                      ])
                    : Text(
                        'Got disconnected',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Roboto"),
                      ),
          ),
        ));
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);

    if (~index != 0) {
      // \r\n
      setState(() {
        String received_data = _messageBuffer + dataString.substring(0, index);
        received_data = received_data.trim();
        //        print(received_data);
        //        print(received_data.substring(0, 4));
        //        print(received_data.length);
        if (received_data.substring(0, 5) == 'raw1:') {
          raw1 = received_data.substring(5, received_data.length);
        }

        if (received_data.substring(0, 5) == 'raw2:') {
          raw2 = received_data.substring(5, received_data.length);
        }
        if (received_data.substring(0, 5) == 'raw3:') {
          raw3 = received_data.substring(5, received_data.length);
        }
        if (received_data.substring(0, 5) == 'raw4:') {
          raw4 = received_data.substring(5, received_data.length);
        }
        if (received_data.substring(0, 5) == 'raw5:') {
          raw5 = received_data.substring(5, received_data.length);
        }
        if (received_data.substring(0, 5) == 'raw6:') {
          raw6 = received_data.substring(5, received_data.length);
        }
        if (received_data.substring(0, 5) == 'raw7:') {
          raw7 = received_data.substring(5, received_data.length);
        }
        if (received_data.substring(0, 5) == 'raw8:') {
          raw8 = received_data.substring(5, received_data.length);
        }
        if (received_data == "13 on") {
          button13 = true;
        }
        if (received_data == "13 off") {
          button13 = false;
        }
        if (received_data == "12 on") {
          button12 = true;
        }
        if (received_data == "12 off") {
          button12 = false;
        }
        if (received_data == "11 on") {
          button11 = true;
        }
        if (received_data == "11 off") {
          button11 = false;
        }
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();

    if (text.length > 0) {
      print(utf8.encode(text + "\r\n"));
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        setState(() {
          //          messages.add(_Message(clientID, text));
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
