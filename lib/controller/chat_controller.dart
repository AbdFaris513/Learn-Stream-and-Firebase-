import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_stream_and_firebase/controller/firebase_service.dart';
import 'package:learn_stream_and_firebase/model/menu_model.dart';
import 'package:learn_stream_and_firebase/model/message_model.dart';
import 'package:learn_stream_and_firebase/model/user_model.dart';
import 'package:learn_stream_and_firebase/widget/snackbar.dart';

class ChatController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final TextEditingController idController = TextEditingController();
  late final UserModel currentUser;

  @override
  void onClose() {
    idController.dispose();
    super.onClose();
  }

  RxList<MenuModel> menuList = <MenuModel>[].obs;
  RxList<MessageModel> messagesList = <MessageModel>[].obs;

  Future<void> getUser(UserModel userModel) async {
    try {
      UserModel? user = await _firebaseService.isExistingUser(userModel.id);
      if (user == null) {
        await _firebaseService.createNewUser(userModel);
        currentUser = userModel;
      } else {
        currentUser = user;
      }
      listenContacts();
    } catch (e) {
      debugPrint("Error on $e");
    }
  }

  Future<void> addNewContact(BuildContext context) async {
    try {
      bool result = await _firebaseService.addNewContact(currentUser.id, idController.text);

      if (result) {
        showCustomSnackBar(
          context,
          message: "Contact added successfully!",
          type: SnackBarType.success,
        );
      } else {
        showCustomSnackBar(context, message: "Contact is not exists!", type: SnackBarType.error);
      }
    } catch (e) {
      debugPrint("Error: $e");
      showCustomSnackBar(context, message: "Error adding contact", type: SnackBarType.error);
    } finally {
      idController.clear();
    }
  }

  // StreamSubscription? _contactSub;
  final Map<String, StreamSubscription> _chatSubs = {};

  void listenContacts() {
    _firebaseService.getUserStream(currentUser.id).listen((doc) {
      if (!doc.exists) return;

      final data = doc.data()!;
      final List<dynamic> contacts = data['contacts'] ?? [];

      // final List<MenuModel> temp = [];

      for (final contactId in contacts) {
        // Avoid duplicate listeners
        if (_chatSubs.containsKey(contactId)) continue;

        _firebaseService.getMenuChatStream(currentUser.id, contactId).listen((chatDoc) {
          MenuModel model;

          if (chatDoc.exists) {
            model = MenuModel.fromJsonMenuList(chatDoc.data()!, currentUser.id, contactId);
          } else {
            model = MenuModel(name: contactId);
          }

          // Update or insert
          final index = menuList.indexWhere((e) => e.name == contactId);
          if (index == -1) {
            menuList.add(model);
          } else {
            menuList[index] = model;
            menuList.refresh();
          }
        });
      }
    });
  }

  Future<void> sendMessage(MessageModel message) async {
    try {
      _firebaseService.sendMessage(message);
    } catch (e) {
      debugPrint("Error on : $e");
    }
  }

  void listenMessages({required String userID, required String reciverID}) {
    _firebaseService.getChatStream(userID, reciverID).listen((querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        messagesList.clear();
        return;
      }

      List<MessageModel> tempMessage = [];
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final msg = MessageModel.fromJson(data);
        tempMessage.add(msg);
      }
      messagesList.value = tempMessage;
    });
  }
}
