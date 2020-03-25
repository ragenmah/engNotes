import 'dart:io';

import 'package:dio/dio.dart';
import 'package:engnotes/notifier/note_notifier.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class DownloadPDFfile extends StatefulWidget {
  @override
  _DownloadPDFfileState createState() => _DownloadPDFfileState();
}

class _DownloadPDFfileState extends State<DownloadPDFfile> {
  String fileUrl, fileName;
  bool downloading = false;
  var progressString = "";
  var dir;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    NoteNotifier noteNotifier =
        Provider.of<NoteNotifier>(context, listen: false);
    fileUrl =
        noteNotifier.currentNote.notePath ?? noteNotifier.currentNote.pdfFile;
    fileName = noteNotifier.currentNote.noteName;
    // _downloadFiles(fileUrl);
    downloadFile();
  }

  Future<void> downloadFile() async {
    Dio dio = Dio();

    try {
      // var dir = await getApplicationDocumentsDirectory();
      dir = await getExternalStorageDirectory();

      await dio.download(fileUrl, "${dir.path}/$fileName.pdf",
          onReceiveProgress: (rec, total) {
        print("Rec: $rec , Total: $total,path : ${dir.path}");

        setState(() {
          downloading = true;
          progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
        });
      });
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      downloading = false;
      progressString = "Completed";
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          'Success!\n Downloaded $fileName \n'
          'File Saved in ${dir.path}',
          style: TextStyle(color: Color.fromARGB(255, 0, 155, 0)),
        ),
      ));
    });
    print("Download completed");
  }

  Future<void> _downloadFiles(fileUrl) async {
    // final String url = await ref.getDownloadURL();
    final StorageReference firebaseStorageRef2 =
        FirebaseStorage.instance.ref().child(fileUrl);
    final String uuid = Uuid().v1();
    final http.Response downloadData = await http.get(fileUrl);
    final Directory systemTempDir = Directory.systemTemp;
    // final File tempFile = File('${systemTempDir.path}/$fileName$uuid.pdf');

    final File tempFile = File('${systemTempDir.path}/$fileName.pdf');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create();
    assert(await tempFile.readAsString() == "");
    final StorageFileDownloadTask task =
        firebaseStorageRef2.writeToFile(tempFile);
    if (task != null) {
      final int byteCount = (await task.future).totalByteCount;
      final String tempFileContents = await tempFile.readAsString();
      assert(tempFileContents == fileName);
      assert(byteCount == fileName.length);

      final String fileContents = downloadData.body;
      // final String name = await ref.getName();
      // final String bucket = await ref.getBucket();
      // final String path = await ref.getPath();
      print('Success!\n Downloaded $fileName \n from url: $fileUrl  '
          'at path: $tempFile \n\nFile contents: "$fileContents" \n'
          'Wrote "$tempFileContents" to tmp.txt');
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          'Success!\n Downloaded $fileName \n from url: $fileUrl  '
          'at path: $tempFile \n\nFile contents: "$fileContents" \n'
          'Wrote "$tempFileContents" to tmp.txt',
          style: const TextStyle(color: Color.fromARGB(255, 0, 155, 0)),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(fileName),
      ),
      // appBar: AppBar(
      //   title: Text(),
      // ),
      body: Center(
        child: downloading
            ? Container(
                height: 120.0,
                width: 200.0,
                child: Card(
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        "Downloading File: $progressString",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Text("No File To Download"),

        // : AlertDialog(title: Text("Sample Alert Dialog") ),
      ),
    );
  }
}
