import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sliderScreen.dart';
import 'package:device_info/device_info.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:flutter_udid/flutter_udid.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  String _deviceName = "";
  String _platformVersion = 'Unknown';
  LocationData? currentLocation;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  TextEditingController code = TextEditingController();
  TextEditingController check = TextEditingController();

  Future login() async {
    // await initPlatformState();
    // Fluttertoast.showToast(
    //     msg: _deviceName +
    //         "\n" +
    //         _platformVersion +
    //         "\n${currentLocation?.latitude}\n${currentLocation?.longitude}",
    //     toastLength: Toast.LENGTH_LONG,
    //     gravity: ToastGravity.CENTER,
    //     timeInSecForIosWeb: 5,
    //     backgroundColor: Color(0xdc3ff132),
    //     textColor: Color(0xfd0b6305),
    //     fontSize: 16.0);
    var url = Uri.parse("https://vrer.herokuapp.com/verify.php");
    // var url = Uri.parse("https://vrer.herokuapp.com/testjson.php");
    var response = await http.post(url, body: {
      "deviceCode": code.text,
      "deviceName": _deviceName,
      "UDID": _platformVersion,
      "LAT": currentLocation?.latitude.toString(),
      "LOG": currentLocation?.longitude.toString(),
    });
    var data = json.decode(response.body);
    if (data != "Error") {
      Fluttertoast.showToast(
          msg: data,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Color(0xdc3ff132),
          textColor: Color(0xfd0b6305),
          fontSize: 16.0);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DownloadFile(text: _platformVersion),
        ),
      );
    } else {
      Fluttertoast.showToast(
          msg: "Invalid Details...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Color(0xdcf5534d),
          textColor: Color(0xffba0404),
          fontSize: 16.0);
    }
  }

  bool _validate1 = false;
  bool _validate2 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   title: Text(
      //     'iBridge.Digital',
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      // ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            // gradient: LinearGradient(
            //     begin: Alignment.topCenter,
            //     colors: <Color>[
            //   Colors.deepOrange,
            //   Colors.orange,
            //   Colors.orangeAccent
            // ])
          color: Colors.teal[100],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "iBridge.digital",
                    style: TextStyle(color: Colors.teal[900], fontSize: 40),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.025,
                  ),
                  Text("Enter the device code",
                    style: TextStyle(color: Colors.teal[700], fontSize: 18),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
                  ),
                child: Column(
                  children: <Widget>[
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                    //   child: Text(
                    //     'Login',
                    //     style:
                    //     TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    //   ),
                    // ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                    Padding(

                      padding: const EdgeInsets.all(8.0),
                      child: TextField(

                        autofocus: true,
                        decoration: InputDecoration(
                          // color: Colors.tealAccent,
                          errorText: _validate1 ? 'Code required' : null,
                          labelText: 'Code',
                          hintText: 'Enter Code received',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.tealAccent, )
                          ),
                        ),
                        controller: code,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
                      // child: Expanded(
                      child: MaterialButton(
                        color: Colors.teal[900],
                        child: Text('   LOGIN    ',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        onPressed: () {
                          setState(() {
                            code.text.isEmpty
                                ? _validate1 = true
                                : _validate1 = false;
                          });
                          if (_validate1 == false) {
                            if (_validate2 == true) {
                              login();
                            } else {}
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<LocationData?> _getLocation() async {
    Location location = new Location();
    LocationData _locationData;

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    _locationData = await location.getLocation();
    return _locationData;
  }

  Future<void> initPlatformState() async {
    _getLocation().then((value) {
      LocationData? location = value;
      setState(() {
        if (value != null) {
          _validate2 = true;
          currentLocation = location;
        }
      });
    });
    String deviceName = 'Unknown';
    String udid;

    try {
      udid = await FlutterUdid.udid;
      if (Platform.isAndroid) {
        deviceName = _readAndroidData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceName = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceName = 'Error:Failed to get name.';
      udid = 'Error: Failed to get UDID';
    }
    if (!mounted) return;

    setState(() {
      _deviceName = deviceName;
      _platformVersion = udid;
    });
  }

  String _readAndroidData(AndroidDeviceInfo build) {
    return build.manufacturer + build.model;
  }

  String _readIosDeviceInfo(IosDeviceInfo build) {
    return build.utsname.machine;
  }
} // TODO Implement this library.
