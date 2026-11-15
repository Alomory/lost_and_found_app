import 'dart:core';
import 'package:lost_and_founds_simple/model/item.dart';

class User {
  String email;
  String? username;
  String password;
  String phoneNo;
  User({required this.email, required this.username, required this.password,required this.phoneNo});
  User.login({
    required this.email,
    required this.password,
    required this.phoneNo,
  });



  get userName {
    return username;
  }

  bool checkUser(List<User> users) {
    return users.isNotEmpty && users.any((user) => user.email == email);
  }

  (User, bool) auth(String email, String password, User user) {
    print("coming User: $email, $password");
    print("compared to: ${user.email}, ${user.password}");
    bool grantAccess =
        (user.email == email && user.password == password) ? true : false;
    print(user);
    return (user, grantAccess);
  }


  




}
