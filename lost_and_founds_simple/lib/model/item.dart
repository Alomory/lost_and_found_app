

import 'dart:io';

import 'package:lost_and_founds_simple/model/user.dart';

class Item{
  final File imageUrl;
  final String itemName;
  final String itemDescription;
  final String location;
  final User user;
  final DateTime dateTime = DateTime.now();
  final bool type;// true for found false for lost

  Item({
    required this.imageUrl,
    required this.itemName,
    required this.itemDescription,
    required this.location,
    required this.user,
    required this.type
  });
}