import 'dart:convert';
import 'dart:async';
import 'package:arduino_bluetooth_tutorial/MainPage.dart';
import 'package:arduino_bluetooth_tutorial/SelectBondedDevicePage.dart';
import 'package:arduino_bluetooth_tutorial/widget/button.dart';
import 'package:arduino_bluetooth_tutorial/widget/inputEmail.dart';
import 'package:arduino_bluetooth_tutorial/widget/password.dart';
import 'package:arduino_bluetooth_tutorial/widget/textLogin.dart';
import 'package:arduino_bluetooth_tutorial/widget/verticalText.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';
import './ChatPage.dart';

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _DeviceWithAvailability extends BluetoothDevice {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class _LoginState extends State<Login> {
  List<_DeviceWithAvailability> devices = List<_DeviceWithAvailability>();
  final textController = TextEditingController();
  final passwordController = TextEditingController();
  final LocalStorage storage = new LocalStorage('user');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.blueGrey, Colors.lightBlueAccent]),
        ),
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(children: <Widget>[
                  VerticalText(),
                  TextLogin(),
                ]),
                InputEmail(
                  textController: textController,
                ),
                PasswordInput(
                  passwordController: passwordController,
                ),
                ButtonLogin(fn: login),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ChatPage(server: server);
    }));
  }

  login() async {
    var data = storage.getItem('data');
    if (data != null) {
      var user = jsonDecode(data)["user"];
      if (user["mobile"] == textController.text &&
          user["password"] == passwordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Login success",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

        final BluetoothDevice selectedDevice = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) {
          return SelectBondedDevicePage(
            checkAvailability: false,
            deviceName: user["device"],
          );
        }));
        if (selectedDevice != null) {
          print('Connect -> selected ' + selectedDevice.address);
          _startChat(context, selectedDevice);
        } else {
          print('Connect -> no device selected');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Login failed",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
      return;
    }
    var url = Uri.parse('https://takwasoft.com/shopix/api/check?mobile=' +
        textController.text +
        '&password=' +
        passwordController.text);

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (jsonDecode(response.body)["status"] == "success") {
      storage.setItem('data', response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Login success",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Login failed",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}
