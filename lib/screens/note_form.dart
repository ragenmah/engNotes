import 'dart:io';

import 'package:engnotes/api/note_api.dart';
import 'package:engnotes/model/note.dart';
import 'package:engnotes/notifier/note_notifier.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class NoteForm extends StatefulWidget {
  final bool isUpdating;

  NoteForm({@required this.isUpdating});

  @override
  _NoteFormState createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List _PDFFiles = [];
  Note _currentNote;
  String _imageUrl;
  File _imageFile;
  TextEditingController PDFFileController = new TextEditingController();
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  bool _hasValidMime = false;
  FileType _pickingType;
  TextEditingController _controller = new TextEditingController();
  File _pdfFile;
  @override
  void initState() {
    super.initState();
    NoteNotifier noteNotifier =
        Provider.of<NoteNotifier>(context, listen: false);

    if (noteNotifier.currentNote != null) {
      _currentNote = noteNotifier.currentNote;
    } else {
      _currentNote = Note();
    }

    // _PDFFiles.addAll(_currentNote.PDFFiles);
    _imageUrl = _currentNote.image;
    _path = _currentNote.pdfFile;
    _controller.addListener(() => _extension = _controller.text);
  }

  void _openFileExplorer() async {
    if (_pickingType != FileType.CUSTOM || _hasValidMime) {
      setState(() => _loadingPath = true);
      try {
        if (_multiPick) {
          _path = null;
          _paths = await FilePicker.getMultiFilePath(
              type: _pickingType, fileExtension: _extension);
        } else {
          _paths = null;
          _path = await FilePicker.getFilePath(
              type: _pickingType, fileExtension: _extension);
          // _pdfFile = null;
          _pdfFile = await FilePicker.getFile(
              type: FileType.CUSTOM, fileExtension: 'pdf');
        }
      } on Exception catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;
      setState(() {
        _loadingPath = false;
        _fileName = _path != null
            ? _path.split('/').last
            : _paths != null ? _paths.keys.toString() : '...';
      });
    }
  }

  _showImage() {
    if (_imageFile == null && _imageUrl == null) {
      // return Text("image placeholder");
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Image.asset(
            "assets/pdfImg.png",
            fit: BoxFit.cover,
            height: 250,
          ),
          // _imageFile == null && _imageUrl == null
          //     ? Image.asset(
          //         "assets/pdfImg.png",
          //         fit: BoxFit.cover,
          //         height: 250,
          //       )
          //     : Image.file(
          //         _imageFile,
          //         fit: BoxFit.cover,
          //         height: 250,
          //       ),
          FlatButton(
            padding: EdgeInsets.all(16),
            color: Colors.black54,
            child: Text(
              'Change Image',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w400),
            ),
            onPressed: () => _getLocalImage(),
          )
        ],
      );
    } else if (_imageFile != null) {
      print('showing image from local file');

      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Image.file(
            _imageFile,
            fit: BoxFit.cover,
            height: 250,
          ),
          FlatButton(
            padding: EdgeInsets.all(16),
            color: Colors.black54,
            child: Text(
              'Change Image',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w400),
            ),
            onPressed: () => _getLocalImage(),
          )
        ],
      );
    } else if (_imageUrl != null) {
      print('showing image from url');

      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Image.network(
            _imageUrl,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            height: 250,
          ),
          FlatButton(
            padding: EdgeInsets.all(16),
            color: Colors.black54,
            child: Text(
              'Change Image',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w400),
            ),
            onPressed: () => _getLocalImage(),
          )
        ],
      );
    }
  }

  _getLocalImage() async {
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 400);

    if (imageFile != null) {
      setState(() {
        _imageFile = imageFile;
      });
    }
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Name'),
      initialValue: _currentNote.noteName,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 20),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Name is required';
        }

        if (value.length < 3 || value.length > 20) {
          return 'Name must be more than 3 and less than 20';
        }

        return null;
      },
      onSaved: (String value) {
        _currentNote.noteName = value;
      },
    );
  }

  Widget _buildSemesterField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Semester'),
      initialValue: _currentNote.semester,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 20),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Semester is required';
        }

        if (value.length < 3 || value.length > 20) {
          return 'Semester must be more than 3 and less than 20';
        }

        return null;
      },
      onSaved: (String value) {
        _currentNote.semester = value;
      },
    );
  }

  _buildPDFFileField() {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: PDFFileController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(labelText: 'PDFFile'),
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  _onNoteUploaded(Note note) {
    NoteNotifier noteNotifier =
        Provider.of<NoteNotifier>(context, listen: false);
    noteNotifier.addNote(note);
    Navigator.pop(context);
  }

  _addPDFFile(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _PDFFiles.add(text);
      });
      PDFFileController.clear();
    }
  }

  _saveNote() {
    print('saveNote Called');
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    print('form saved');

    // _currentNote.PDFFiles = _PDFFiles;

    uploadNoteAndImage(
        _currentNote, widget.isUpdating, _imageFile, _onNoteUploaded, _pdfFile);

    print("name: ${_currentNote.noteName}");
    print("semester: ${_currentNote.semester}");
    // print("PDFFiles: ${_currentNote.PDFFiles.toString()}");
    print("_imageFile ${_imageFile.toString()}");
    print("_imageUrl $_imageUrl");
    print("_pdfPath $_path");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Note Form')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: Column(children: <Widget>[
            _showImage(),
            SizedBox(height: 16),
            Text(
              widget.isUpdating ? "Edit Note" : "Create Note",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 16),
            _imageFile == null && _imageUrl == null
                ? ButtonTheme(
                    child: RaisedButton(
                      onPressed: () => _getLocalImage(),
                      child: Text(
                        'Add Image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : SizedBox(height: 0),
            _buildNameField(),
            _buildSemesterField(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // _buildPDFFileField(),
                ButtonTheme(
                  child: RaisedButton(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Add PDF File',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w300),
                    ),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    // onPressed: () => _addPDFFile(PDFFileController.text),
                    onPressed: () => _openFileExplorer(),
                  ),
                )
              ],
            ),
            SizedBox(height: 16),
            new Builder(
              builder: (BuildContext context) => _loadingPath
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: const CircularProgressIndicator())
                  : _path != null || _paths != null
                      ? new Container(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          height: MediaQuery.of(context).size.height * 0.50,
                          child: new Scrollbar(
                              child: new ListView.separated(
                            itemCount: _paths != null && _paths.isNotEmpty
                                ? _paths.length
                                : 1,
                            itemBuilder: (BuildContext context, int index) {
                              final bool isMultiPath =
                                  _paths != null && _paths.isNotEmpty;
                              final String name = 'File $index: ' +
                                  (isMultiPath
                                      ? _paths.keys.toList()[index]
                                      : _fileName ?? '...');
                              final path = isMultiPath
                                  ? _paths.values.toList()[index].toString()
                                  : _path;

                              return new ListTile(
                                title: new Text(
                                  name,
                                ),
                                subtitle: new Text(path),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    new Divider(),
                          )),
                        )
                      : new Container(),
            ),
            // GridView.count(
            //   shrinkWrap: true,
            //   scrollDirection: Axis.vertical,
            //   padding: EdgeInsets.all(8),
            //   crossAxisCount: 3,
            //   crossAxisSpacing: 4,
            //   mainAxisSpacing: 4,
            //   children: _PDFFiles
            //       .map(
            //         (ingredient) => Card(
            //           color: Colors.black54,
            //           child: Center(
            //             child: Text(
            //               ingredient,
            //               style: TextStyle(color: Colors.white, fontSize: 14),
            //             ),
            //           ),
            //         ),
            //       )
            //       .toList(),
            // )
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          AlertDialog(
            title: Text("Your Note is Being Saved"),
          );
          _saveNote();
        },
        child: Icon(Icons.save),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
      ),
    );
  }
}
