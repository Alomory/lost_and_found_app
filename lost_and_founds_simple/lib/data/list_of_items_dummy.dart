import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lost_and_founds_simple/model/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lost_and_founds_simple/model/item.dart';

class ListOfItems extends ChangeNotifier {
  final List<User> users;

  List<Item> items = [];

  ListOfItems()
      : users = [
          User(
            email: "omar@gmail.com",
            username: "Omar Alomory",
            password: "Omar",
            phoneNo: '0182850579'
          ),
          User(
            email: "ali@gmail.com",
            username: "Ali Alomory",
            password: "ali",
            phoneNo: '1078746567'
          ),
          User(
            email: "mohammad@gmail.com",
            username: "Mohammad Alomory",
            password: "mohammad",
            phoneNo: '01765209878'
          )
        ];

  List<Item> get itemList {
    print("#Debug listOfItems.dart ->  ${items.length}");
    return items;
  }

  List<User> get userList {
    return users;
  }

  Future<void> initializeItems() async {
    items = [
      Item(
        imageUrl: await getImageFileFromAssets("images/nokia.jpg"),
        itemName: "Nokia SuperSonic 5G 1",
        itemDescription:
            "White and Blue Nokia, with small screen and old number pad",
        location: "Location: I lost it in FTKKI i think",
        user: users[1],
        type: false,
      ),
      Item(
        imageUrl: await getImageFileFromAssets("images/nokia.jpg"),
        itemName: "Nokia SuperSonic 5G 2",
        itemDescription:
            "White and Blue Nokia, with small screen and old number pad",
        location: "Location: I lost it in FTKKI i think",
        user: users[0],
        type: false,
      ),
      Item(
        imageUrl: await getImageFileFromAssets("images/nokia.jpg"),
        itemName: "Nokia SuperSonic 5G 3",
        itemDescription:
            "White and Blue Nokia, with small screen and old number pad",
        location: "Location: I lost it in FTKKI i think",
        user: users[2],
        type: false,
      ),
      Item(
        imageUrl: await getImageFileFromAssets("images/nokia.jpg"),
        itemName: "Nokia SuperSonic 5G 4",
        itemDescription:
            "White and Blue Nokia, with small screen and old number pad",
        location: "Location: I lost it in FTKKI i think",
        user: users[0],
        type: true,
      ),
      Item(
        imageUrl: await getImageFileFromAssets("images/nokia.jpg"),
        itemName: "Nokia SuperSonic 5G 5",
        itemDescription:
            "White and Blue Nokia, with small screen and old number pad",
        location: "Location: I lost it in FTKKI i think",
        user: users[2],
        type: true,
      ),
      Item(
        imageUrl: await getImageFileFromAssets("images/nokia.jpg"),
        itemName: "Nokia SuperSonic 5G 6",
        itemDescription:
            "White and Blue Nokia, with small screen and old number pad",
        location: "Location: I lost it in FTKKI i think",
        user: users[1],
        type: true,
      ),
    ];
    notifyListeners();
  }

  // converting the images in the assets to file for testing
  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    print("#Debug home.dart file path = ${file.path}");
    return file;
  }
void deleteItem(value) {
    items.removeWhere((element) => value == element);
    notifyListeners();
  }
  void addItem(Item item) {
    print("#Debug list_of_items_dummy.dart -> item added = ${item.imageUrl}");
    print("#Debug list_of_items_dummy.dart -> item added = ${item.type}");

    items.add(item);
    print("#Debug list_of_items_dummy.dart -> item length = ${items.length}");
    notifyListeners();
  }
  void addUser(User user){
    userList.add(user);
    notifyListeners();
  }
  void updateItem(Item item, int index){
    items[index] = item;
    print("#Debug list_of_items_dummy.dart -> item index  = ${index} type = ${item.type}");
    notifyListeners();
  }

}
