import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String id;
  String noteName;
  String notePath;
  String image;
  String noteType; //syllabus
  String semester;
  // List subIngredients = [];
  Timestamp createdAt;
  Timestamp updatedAt;
  String pdfFile;

  Note();

  Note.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    noteName = data['noteName'];
    notePath = data['notePath'];
    noteType = data['noteType'];
    semester = data['semester'];
    image = data['image'];
    createdAt = data['createdAt'];
    updatedAt = data['updatedAt'];
    pdfFile = data['pdfFile'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'noteName': noteName,
      'notePath': notePath,
      'noteType': noteType,
      'semester': semester,
      // 'name': name,
      // 'category': category,
      'image': image,
      // 'subIngredients': subIngredients,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'pdfFile': pdfFile ?? notePath
    };
  }
}
