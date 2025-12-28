import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:learn_stream_and_firebase/model/menu_model.dart';
import 'package:learn_stream_and_firebase/model/message_model.dart';
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

  ///////////////////////////////////////////////////////////////
  Future<void> setMessageSeen(MessageModel message) async {
    try {
      String docId = getChatId(senderId: message.senderId, receiverId: message.receiverId);
      final messageQuery = await _firestore
          .collection("temp_chats")
          .doc(docId)
          .collection("messages")
          .where("senderId", isNotEqualTo: message.senderId)
          .orderBy("timestamp", descending: true)
          .get();
      bool seen = false;
      for (final entry in messageQuery.docs) {
        final data = entry.data();
        seen = data['isSeen'] ?? false;

        if (seen) return;

        await entry.reference.update({'isSeen': true});
      }

      await _firestore.collection("temp_chats").doc(docId).update({});
    } catch (e) {
      rethrow;
    }
  }

  String getChatId({required String senderId, required String receiverId}) {
    final List<String> particpaters = [senderId, receiverId];
    particpaters.sort();
    return particpaters.join('-');
  }

  Future<void> sendMessage(MessageModel message) async {
    try {
      String docId = getChatId(senderId: message.senderId, receiverId: message.receiverId);
      _firestore.collection("temp_chats").doc(docId).collection("messages").add(message.toJson());

      final getLastUpdate = await _firestore.collection("temp_chats").doc(docId).get();
      int reciverCount = 1;
      if (getLastUpdate.exists) {
        final Map<String, dynamic> data = getLastUpdate.data() as Map<String, dynamic>;
        final int unreadCounts =
            (int.tryParse(data["unreadCounts"][message.receiverId]?.toString() ?? '0') ?? 0) + 1;
        reciverCount = unreadCounts;
      }
      _firestore.collection("temp_chats").doc(docId).set({
        "last_message": message.messageText,
        "last_sender": message.senderId,
        "last_msg_time": FieldValue.serverTimestamp(),
        "unreadCounts": {message.senderId: 0, message.receiverId: reciverCount},
        "participantIds": [message.senderId, message.receiverId],
      });
    } catch (e) {
      debugPrint("Erron on sendMessage() : $e ");
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChatStream(String userID, String reciverId) {
    String docId = getChatId(senderId: userID, receiverId: reciverId);
    return _firestore
        .collection("temp_chats")
        .doc(docId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<MenuModel?> getChatData(String userID, String reciverId) async {
    try {
      String docId = getChatId(senderId: userID, receiverId: reciverId);
      final reciverData = await _firestore.collection("temp_chats").doc(docId).get();
      if (!reciverData.exists) return null;
      return MenuModel.fromJsonMenuList(reciverData.data() ?? {}, userID, reciverId);
    } catch (e) {
      rethrow;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getMenuChatStream(
    String userID,
    String receiverId,
  ) {
    final docId = getChatId(senderId: userID, receiverId: receiverId);
    return _firestore.collection("temp_chats").doc(docId).snapshots();
  }
}
