import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_stream_and_firebase/controller/firebase_service.dart';
import 'package:learn_stream_and_firebase/model/menu_model.dart';
import 'package:learn_stream_and_firebase/model/user_model.dart';
import 'package:learn_stream_and_firebase/widget/snackbar.dart';

class ChatController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final TextEditingController idController = TextEditingController();
  late final UserModel currentUser;

  @override
  void onClose() {
    _contactsSubscription?.cancel();
    idController.dispose();
    super.onClose();
  }

  StreamSubscription? _contactsSubscription;
  RxList<MenuModel> menuList = <MenuModel>[
    // MenuModel(name: "Faris"),
    // MenuModel(name: "Vel"),
    // MenuModel(name: "Arun"),
  ].obs;

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
        showCustomSnackBar(context, message: "Contact already exists!", type: SnackBarType.warning);
      }
    } catch (e) {
      debugPrint("Error: $e");
      showCustomSnackBar(context, message: "Error adding contact", type: SnackBarType.error);
    } finally {
      idController.clear();
    }
  }

  void listenContacts() {
    _firebaseService.getUserStream(currentUser.id).listen((doc) {
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final List<dynamic> contactList = (data['contacts'] ?? []) as List<dynamic>;

      final List<MenuModel> temp = [];
      for (int i = 0; i < contactList.length; i++) {
        temp.add(MenuModel(name: contactList[i]));
      }
      menuList.value = temp;
    });
  }
}
