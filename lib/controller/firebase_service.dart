import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:learn_stream_and_firebase/model/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createNewUser(UserModel userModel) async {
    try {
      _firestore.collection("temp_user").doc(userModel.id).set({
        'id': userModel.id,
        'isOnline': false,
        'contacts': [],
      });
    } catch (e) {
      debugPrint("Erron on createNewUser() : $e ");
      rethrow;
    }
  }

  Future<UserModel?> isExistingUser(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection("temp_user").doc(id).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }
    } catch (e) {
      debugPrint("Erron on createNewUser() : $e ");
      rethrow;
    }
    return null;
  }

  Future<bool> addNewContact(String userId, String newContactId) async {
    try {
      final myContactIdIsExisist = await isExistingUser(newContactId);
      if (myContactIdIsExisist != null) {
        _firestore.collection("temp_user").doc(userId).update({
          'contacts': FieldValue.arrayUnion([newContactId]),
        });
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Erron on createNewUser() : $e ");
      rethrow;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(String userID) {
    return _firestore.collection("temp_user").doc(userID).snapshots();
  }
}
