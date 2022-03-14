import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

String s = "";

class DownloadFile extends StatefulWidget {
  final String text;

  // const DownloadFile(this.text);
  const DownloadFile({Key? key, required this.text}) : super(key: key);

  @override
  State createState() {
    return _DownloadFileState(this.text);
  }
}

String savePath = "";
List MediaItems = [];
List oldItems = [];
List<Image> Images = [];
bool stat = false;

class _DownloadFileState extends State {
  late String UUID;

  _DownloadFileState(this.UUID);

  // var imageUrl = "https://ibridge.digital/projects/cast/uploads/";
  var imageUrl = "https://vrer.herokuapp.com/img/";

  bool downloading = true;
  String downloadingStr = "Wait while the data is fetched";
  String savePath = "";
  int count = 1;

  @override
  void initState() {
    MediaItems = [];
    super.initState();
    // getAllCampaignMedia();
    downloadFiles();
    Timer.periodic(Duration(seconds: 100), (Timer t) {//ensures if there are any updates
      getAllCampaignMedia();
      if (oldItems != MediaItems) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => this.widget));
      }
    });
  }

  getAllCampaignMedia() async {
    var ud = UUID;
    // var url = Uri.parse(
    //     "https://ibridge.digital/projects/cast/file.php?" + curr_camp);
    var url = Uri.parse("https://vrer.herokuapp.com/testjson.php");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        MediaItems = json.decode(response.body);
      });
      return MediaItems;
    }
  }

  Future downloadFiles() async {
    try {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        if (Platform.isAndroid) {
          savePath = "/sdcard/download/";
        } else {
          savePath = (await getApplicationDocumentsDirectory()).path;
        }
      }
      await getAllCampaignMedia();
      await download();
    } catch (e) {
      // print("Hey.....................................");
      print(e);
    }
  }

  download() async {
    oldItems = MediaItems;
    Dio dio = Dio();
    MediaItems.forEach((MediaItem) async {
      if (!File(savePath + MediaItem['unique_id']).existsSync()) {
        await Future.wait([
          dio.download(
            imageUrl + MediaItem['unique_id'],
            savePath + MediaItem['unique_id'],
            onReceiveProgress: (rec, total) {
              setState(
                () {
                  stat = true;
                  downloadingStr =
                      "Downloading File" + MediaItem['unique_id'] + ": $rec";
                },
              );
            },
          ).then((value) {
            setState(() {
              if (count == MediaItems.length) {
                downloading = false;
                downloadingStr = "Completed";
              }

              count++;
            });
          })
        ]);
      } else
        setState(() {
          if (count == MediaItems.length) {
            downloading = false;
            downloadingStr = "Completed";
          }
          count++;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: downloading
          ? Center(
              child: Container(
                height: 250,
                width: 250,
                child: Card(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        downloadingStr,
                        style: TextStyle(color: Colors.blue),
                      )
                    ],
                  ),
                ),
              ),
            )
          : Builder(builder: (context) {
              final double height = MediaQuery.of(context).size.height;
              return CarouselSlider(
                options: CarouselOptions(
                  height: height,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                ),
                items: MediaItems.map(
                  (item) => Container(
                    //savePath + item['unique_id'].toString()
                    child: Image(
                      image: FileImage(File(savePath + item['unique_id'])),
                      fit: BoxFit.cover,
                      height: height,
                    ),
                  ),
                ).toList(),
              );
            }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => this.widget));
        },
        tooltip: 'Refresh Page',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
