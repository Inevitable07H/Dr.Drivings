import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveDrivingData(Map<String, dynamic> data) async {
    await _db.collection("driving_sessions").add(data);
  }
}