import 'package:engnotes/api/note_api.dart';
import 'package:engnotes/model/note.dart';
import 'package:engnotes/notifier/note_notifier.dart';
import 'package:engnotes/screens/home.dart';
import 'package:engnotes/widgets/ButtonAnimation.dart';
import 'package:engnotes/widgets/DownloadPDF.dart';
import 'package:engnotes/widgets/PdfLoader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'note_form.dart';

class NoteDetail extends StatelessWidget {
  final fileurl = "";
  bool isDownloading = false;
  @override
  Widget build(BuildContext context) {
    NoteNotifier noteNotifier = Provider.of<NoteNotifier>(context);

    _onNoteDeleted(Note note) {
      noteNotifier.deleteNote(note);

      Navigator.pop(context);
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (BuildContext context) => Home(),
      //     ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(noteNotifier.currentNote.noteName),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            child: Column(
              children: <Widget>[
                noteNotifier.currentNote.image != null
                    ? Image.network(
                        noteNotifier.currentNote.image,
                        width: MediaQuery.of(context).size.width,
                        // width: 100,
                        height: 250,
                        fit: BoxFit.fitWidth,
                      )
                    : Image.asset(
                        "assets/pdfImg.png",
                        // width: 100,
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        fit: BoxFit.fitWidth,
                      ),
                // Image.network(
                //   noteNotifier.currentNote.image != null
                //       ? noteNotifier.currentNote.image
                //       : 'https://www.testingxperts.com/wp-content/uploads/2019/02/placeholder-img.jpg',
                //   width: MediaQuery.of(context).size.width,
                //   height: 250,
                //   fit: BoxFit.fitWidth,
                // ),
                SizedBox(height: 24),
                Text(
                  noteNotifier.currentNote.noteName,
                  style: TextStyle(
                    fontSize: 40,
                  ),
                ),
                Text(
                  'Semester: ${noteNotifier.currentNote.semester}',
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 20),
                Text(
                  "Detail",
                  style: TextStyle(
                      fontSize: 18, decoration: TextDecoration.underline),
                ),

                SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.all(8),
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  // children: noteNotifier.currentNote.subIngredients
                  //     .map(
                  //       (ingredient) => Card(
                  //         color: Colors.black54,
                  //         child: Center(
                  //           child: Text(
                  //             ingredient,
                  //             style: TextStyle(color: Colors.white, fontSize: 16),
                  //           ),
                  //         ),
                  //       ),
                  //     )
                  //     .toList(),
                ),
                // ButtonAnimation(Color.fromRGBO(57, 92, 249, 1), Color.fromRGBO(44, 78, 233, 1)),
              ],
            ),
          ),
        ),
      ),
      persistentFooterButtons: <Widget>[
        RaisedButton(
          child: Text(
            'Read Online',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => Pdfloader(),
                ));
            // _isLoading?Center(child: CircularProgressIndicator(),):PDFViewer(document: document,);
          },
        ),
        RaisedButton(
          child: Text(
            'Download',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => DownloadPDFfile(),
                ));
          },
        ),
        FloatingActionButton(
          heroTag: 'button1',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) {
                return NoteForm(
                  isUpdating: true,
                );
              }),
            );
          },
          child: Icon(Icons.edit),
          foregroundColor: Colors.white,
        ),
        SizedBox(height: 20),
        FloatingActionButton(
          heroTag: 'button2',
          onPressed: () => deleteNote(noteNotifier.currentNote, _onNoteDeleted),
          child: Icon(Icons.delete),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ],

      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: <Widget>[
      //     FloatingActionButton(
      //       heroTag: 'button1',
      //       onPressed: () {
      //         Navigator.of(context).push(
      //           MaterialPageRoute(builder: (BuildContext context) {
      //             return NoteForm(
      //               isUpdating: true,
      //             );
      //           }),
      //         );
      //       },
      //       child: Icon(Icons.edit),
      //       foregroundColor: Colors.white,
      //     ),
      //     SizedBox(height: 20),
      //     FloatingActionButton(
      //       heroTag: 'button2',
      //       onPressed: () => deleteNote(noteNotifier.currentNote, _onNoteDeleted),
      //       child: Icon(Icons.delete),
      //       backgroundColor: Colors.red,
      //       foregroundColor: Colors.white,
      //     ),
      //   ],
      // ),
    );
  }
}
