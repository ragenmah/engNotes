import 'dart:io';

import 'package:engnotes/model/note.dart';
import 'package:engnotes/model/user.dart';
import 'package:engnotes/notifier/auth_notifier.dart';
import 'package:engnotes/notifier/note_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engnotes/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

login(User user, AuthNotifier authNotifier) async {
  AuthResult authResult = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: user.email, password: user.password)
      .catchError((error) => print(error.code));

  if (authResult != null) {
    FirebaseUser firebaseUser = authResult.user;

    if (firebaseUser != null) {
      print("Log In: $firebaseUser");
      authNotifier.setUser(firebaseUser);
    }
  }
}

signup(User user, AuthNotifier authNotifier) async {
  AuthResult authResult = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(
          email: user.email, password: user.password)
      .catchError((error) => print(error.code));

  if (authResult != null) {
    UserUpdateInfo updateInfo = UserUpdateInfo();
    updateInfo.displayName = user.displayName;

    FirebaseUser firebaseUser = authResult.user;

    if (firebaseUser != null) {
      await firebaseUser.updateProfile(updateInfo);

      await firebaseUser.reload();

      print("Sign up: $firebaseUser");

      FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
      authNotifier.setUser(currentUser);
    }
  }
}

signout(AuthNotifier authNotifier) async {
  await FirebaseAuth.instance
      .signOut()
      .catchError((error) => print(error.code));

  authNotifier.setUser(null);
}

initializeCurrentUser(AuthNotifier authNotifier) async {
  FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();

  if (firebaseUser != null) {
    print(firebaseUser);
    authNotifier.setUser(firebaseUser);
  }
}

getNotes(NoteNotifier noteNotifier) async {
  QuerySnapshot snapshot = await Firestore.instance
      .collection('Notes')
      .orderBy("createdAt", descending: true)
      .getDocuments();

  List<Note> _noteList = [];

  snapshot.documents.forEach((document) {
    Note note = Note.fromMap(document.data);
    _noteList.add(note);
  });

  noteNotifier.noteList = _noteList;
}

uploadNoteAndImage(Note note, bool isUpdating, File localFile,
    Function noteUploaded, File pdfFile) async {
  var uuid = Uuid().v4();

  if (localFile != null || pdfFile != null) {
    // image path not null
    print("uploading image");
    String url;
    if (localFile != null) {
      var fileExtension = path.extension(localFile.path);
      print(fileExtension);

      final StorageReference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('Notes/images/$uuid$fileExtension');

      await firebaseStorageRef
          .putFile(localFile)
          .onComplete
          .catchError((onError) {
        print(onError);
        return false;
      });
      url = await firebaseStorageRef.getDownloadURL();
    }
    print("download Imageurl: $url");

    var fileExtensionPdf = path.extension(pdfFile.path);
    final StorageReference firebaseStorageRef2 = FirebaseStorage.instance
        .ref()
        .child('Notes/pdf/$uuid$fileExtensionPdf');
    await firebaseStorageRef2.putFile(pdfFile).onComplete.catchError((onError) {
      print(onError);
      return false;
    });
    String pdfUrl = await firebaseStorageRef2.getDownloadURL();
    _uploadNote(note, isUpdating, noteUploaded, imageUrl: url, pdfUrl: pdfUrl);
  } else {
    print('...skipping image upload');
    // if (pdfFile != null) {
    //   var fileExtensionPdf = path.extension(pdfFile.path);
    //   final StorageReference firebaseStorageRef2 = FirebaseStorage.instance
    //       .ref()
    //       .child('Notes/pdf/$uuid$fileExtensionPdf');
    //   await firebaseStorageRef2
    //       .putFile(pdfFile)
    //       .onComplete
    //       .catchError((onError) {
    //     print(onError);
    //     return false;
    //   });
    //   String pdfUrl = await firebaseStorageRef2.getDownloadURL();
    // }
    _uploadNote(note, isUpdating, noteUploaded);
  }
}

_uploadNote(Note note, bool isUpdating, Function NoteUploaded,
    {String imageUrl, String pdfUrl}) async {
  CollectionReference noteRef = Firestore.instance.collection('Notes');

  if (imageUrl != null) {
    note.image = imageUrl;
  }
  if (pdfUrl != null) {
    note.pdfFile = pdfUrl;
  }

  if (isUpdating) {
    note.updatedAt = Timestamp.now();

    await noteRef.document(note.id).updateData(note.toMap());

    NoteUploaded(note);
    print('updated Note with id: ${note.id}');
  } else {
    note.createdAt = Timestamp.now();

    DocumentReference documentRef = await noteRef.add(note.toMap());

    note.id = documentRef.documentID;

    print('uploaded Note successfully: ${note.toString()}');

    await documentRef.setData(note.toMap(), merge: true);

    NoteUploaded(note);
  }
}

deleteNote(Note note, Function noteDeleted) async {
  if (note.image != null) {
    StorageReference storageReference =
        await FirebaseStorage.instance.getReferenceFromUrl(note.image);
    await storageReference.delete();
    print(storageReference.path);
    print('image deleted');
  }
  if (note.pdfFile != null) {
    StorageReference storageReference2 =
        await FirebaseStorage.instance.getReferenceFromUrl(note.pdfFile);
    await storageReference2.delete();
    print('PDF deleted');
  }
  await Firestore.instance.collection('Notes').document(note.id).delete();
  noteDeleted(note);
  // Home();
}
