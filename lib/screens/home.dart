import 'package:engnotes/api/note_api.dart';
import 'package:engnotes/model/note.dart';
import 'package:engnotes/notifier/auth_notifier.dart';
import 'package:engnotes/notifier/note_notifier.dart';
import 'package:engnotes/screens/detail.dart';
import 'package:engnotes/screens/note_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String searchName = "";

  List<Note> _notesForDisplay = List<Note>();
  @override
  void initState() {
    NoteNotifier noteNotifier =
        Provider.of<NoteNotifier>(context, listen: false);
    getNotes(noteNotifier);
    if (_notesForDisplay.length != 0) _notesForDisplay.clear();
    _notesForDisplay = noteNotifier.noteList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    NoteNotifier noteNotifier = Provider.of<NoteNotifier>(context);
    // TextEditingController editingController = TextEditingController();

    Future<void> _refreshList() async {
      getNotes(noteNotifier);
      if (_notesForDisplay.length != 0) _notesForDisplay.clear();
      _notesForDisplay = noteNotifier.noteList;
    }

    print("building Home");
    return Scaffold(
      appBar: AppBar(
          // title: Text(
          //   // authNotifier.user != null ? authNotifier.user.displayName : "Home",
          // ),
          // actions: <Widget>[
          //   // action button
          //   FlatButton(
          //     onPressed: () => signout(authNotifier),
          //     child: Text(
          //       "Logout",
          //       style: TextStyle(fontSize: 20, color: Colors.white),
          //     ),
          //   ),
          // ],
          ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/drawerimages/notes.jpg"),
                          fit: BoxFit.cover)
                      //                   Image.network(
                      //   'https://picsum.photos/250?image=9',
                      // ),
                      ),
                  child: Text(
                    authNotifier.user != null
                        ? authNotifier.user.displayName
                        : "Home",
                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: ListView(children: [
                ListTile(
                  title: Text("Home"),
                  onTap: () {
                    // Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  },
                ),
                ListTile(
                  title: Text("Logout"),
                  onTap: () {
                    signout(authNotifier);
                  },
                ),
              ]),
            )
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(9.0),
              child: TextField(
                // controller: editingController,
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
                onChanged: (value) {
                  //initiateSearch(value);
                  searchName = value.toLowerCase().trim();

                  setState(() {
                    // NoteNotifier noteNotifier = Provider.of<NoteNotifier>(context);
                    _notesForDisplay = noteNotifier.noteList.where((note) {
                      var noteTitle = note.noteName.toLowerCase();
                      return noteTitle.contains(searchName);
                    }).toList();
                  });
                },
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                child: ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    return _notesForDisplay.length == 0
                        ? _noItemList(index)
                        : _listItem(index);
                    // return _listItem(index - 1);
                  },
                  itemCount: _notesForDisplay.length == 0
                      ? noteNotifier.noteList.length
                      : _notesForDisplay.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      color: Colors.black,
                    );
                  },
                ),
                onRefresh: _refreshList,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          noteNotifier.currentNote = null;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) {
              return NoteForm(
                isUpdating: false,
              );
            }),
          );
        },
        child: Icon(Icons.add),
        foregroundColor: Colors.white,
      ),
    );
  }

  void initiateSearch(String val) {
    setState(() {
      NoteNotifier noteNotifier = Provider.of<NoteNotifier>(context);
      searchName = val.toLowerCase().trim();
      _notesForDisplay = noteNotifier.noteList.where((note) {
        var noteTitle = note.noteName.toLowerCase();
        return noteTitle.contains(searchName);
      }).toList();
    });
  }

  _noItemList(index) {
    //return Center(child: Text(''));
    NoteNotifier noteNotifier = Provider.of<NoteNotifier>(context);
    return ListTile(
      leading: noteNotifier.noteList[index].image != null
          ? Image.network(
              noteNotifier.noteList[index].image,
              width: 100,
              fit: BoxFit.fitWidth,
            )
          : Image.asset(
              "assets/pdfImg.png",
              width: 100,
              fit: BoxFit.fitWidth,
            ),
      title: Text(noteNotifier.noteList[index].noteName),
      subtitle: Text(noteNotifier.noteList[index].semester),
      onTap: () {
        noteNotifier.currentNote = noteNotifier.noteList[index];
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return NoteDetail();
        }));
      },
    );
  }

  _listItem(index) {
    NoteNotifier noteNotifier = Provider.of<NoteNotifier>(context);
    return ListTile(
      leading: _notesForDisplay[index].image != null
          ? Image.network(
              _notesForDisplay[index].image,
              width: 100,
              fit: BoxFit.fitWidth,
            )
          : Image.asset(
              "assets/pdfImg.png",
              width: 100,
              fit: BoxFit.fitWidth,
            ),
      title: Text(_notesForDisplay[index].noteName),
      subtitle: Text(_notesForDisplay[index].semester),
      onTap: () {
        noteNotifier.currentNote = _notesForDisplay[index];
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return NoteDetail();
        }));
      },
    );
  }
}
