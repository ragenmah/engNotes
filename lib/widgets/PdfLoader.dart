import 'dart:io';

import 'package:engnotes/notifier/note_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class Pdfloader extends StatefulWidget {
  @override
  _PdfloaderState createState() => _PdfloaderState();
}

class _PdfloaderState extends State<Pdfloader> {
  String assetPDFPath = "";
  String urlPDFPath = "";
  String fileUrl, fileName;
  bool downloading = false, _isLoading = false, _isInit = true;
  PDFDocument document;

  @override
  void initState() {
    super.initState();
    NoteNotifier noteNotifier =
        Provider.of<NoteNotifier>(context, listen: false);
    fileUrl =
        noteNotifier.currentNote.notePath ?? noteNotifier.currentNote.pdfFile;
    fileName = noteNotifier.currentNote.noteName;
    // getFileFromAsset("assets/mypdf.pdf").then((f) {
    //   setState(() {
    //     assetPDFPath = f.path;
    //     print(assetPDFPath);
    //   });
    // });
    fileUrl == ""
        ? AlertDialog(title: Text("The File Path Not Found"))
        : loadFromURL();
    // getFileFromUrl(fileUrl).then((f) {
    //   setState(() {
    //     urlPDFPath = f.path;
    //     print(urlPDFPath);
    //   });
    // });
  }
  //    Future<File> getFileFromAsset(String asset) async {
  //   try {
  //     var data = await rootBundle.load(asset);
  //     var bytes = data.buffer.asUint8List();
  //     var dir = await getApplicationDocumentsDirectory();
  //     File file = File("${dir.path}/mypdf.pdf");

  //     File assetFile = await file.writeAsBytes(bytes);
  //     return assetFile;
  //   } catch (e) {
  //     throw Exception("Error opening asset file");
  //   }
  // }

  Future<File> getFileFromUrl(String url) async {
    try {
      var data = await http.get(url);
      var bytes = data.bodyBytes;
      // var dir = await getApplicationDocumentsDirectory();
      // File file = File("${dir.path}/mypdfonline.pdf");
      File file = File(url);
      File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    } catch (e) {
      throw Exception("Error opening url file");
    }
  }

  loadFromURL() async {
    setState(() {
      _isLoading = true;
    });
    try {
      document = await PDFDocument.fromURL(fileUrl);
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }

  int _totalPages = 0;
  int _currentPage = 0;
  bool pdfReady = false;
  PDFViewController _pdfViewController;
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : PDFViewer(
                      document: document,
                    ),
            ),
          )
        ],
      ),
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(fileName),
    //   ),
    //   body: Stack(
    //     children: <Widget>[
    //       PDFView(
    //         // filePath: widget.path, fileUrl
    //         filePath: urlPDFPath,
    //         autoSpacing: true,
    //         enableSwipe: true,
    //         pageSnap: true,
    //         swipeHorizontal: true,
    //         nightMode: false,
    //         onError: (e) {
    //           print(e);
    //         },
    //         onRender: (_pages) {
    //           setState(() {
    //             _totalPages = _pages;
    //             pdfReady = true;
    //           });
    //         },
    //         onViewCreated: (PDFViewController vc) {
    //           _pdfViewController = vc;
    //         },
    //         onPageChanged: (int page, int total) {
    //           setState(() {});
    //         },
    //         onPageError: (page, e) {},
    //       ),
    //       !pdfReady
    //           ? Center(
    //               child: CircularProgressIndicator(),
    //             )
    //           : Offstage()
    //     ],
    //   ),
    //   floatingActionButton: Row(
    //     mainAxisAlignment: MainAxisAlignment.end,
    //     children: <Widget>[
    //       _currentPage > 0
    //           ? FloatingActionButton.extended(
    //               backgroundColor: Colors.red,
    //               label: Text("Go to ${_currentPage - 1}"),
    //               onPressed: () {
    //                 _currentPage -= 1;
    //                 _pdfViewController.setPage(_currentPage);
    //               },
    //             )
    //           : Offstage(),
    //       _currentPage+1 < _totalPages
    //           ? FloatingActionButton.extended(
    //               backgroundColor: Colors.green,
    //               label: Text("Go to ${_currentPage + 1}"),
    //               onPressed: () {
    //                 _currentPage += 1;
    //                 _pdfViewController.setPage(_currentPage);
    //               },
    //             )
    //           : Offstage(),
    //     ],
    //   ),
    // );
  }
}
