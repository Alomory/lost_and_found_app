import 'package:flutter/material.dart';
import 'package:lost_and_founds_simple/data/list_of_items_dummy.dart';
import 'package:lost_and_founds_simple/model/user.dart';
import 'package:lost_and_founds_simple/screens/home_screen.dart';
import 'package:lost_and_founds_simple/util.dart' as util;
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();

  late List<User> _users;
  bool _logState = false;
  String _logTextButton = 'Sign Up';
  String _logText = "Login";
  String _logScript = 'Already have an account ';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ListOfItems logingProvider = Provider.of<ListOfItems>(context);
    double screenHeight = MediaQuery.of(context).size.height;
    _users = logingProvider.userList;

    return Scaffold(
      appBar: AppBar(
        title: Text(_logTextButton),
        backgroundColor: Theme.of(context).primaryColorLight,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).orientation == Orientation.landscape
              ? MediaQuery.of(context).size.height * 2
              : MediaQuery.of(context).size.height,
          decoration: BoxDecoration(color: Colors.grey[100]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 40),
                child: Column(
                  children: _logState
                      ? [
                          TextFormField(
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Email';
                              }
                              return null;
                            },
                            decoration:
                                const InputDecoration(labelText: 'Email'),
                          ),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Password';
                              }
                              return null;
                            },
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                          )
                        ]
                      : [
                          TextFormField(
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Email';
                              }
                              return null;
                            },
                            decoration:
                                const InputDecoration(labelText: 'Email'),
                          ),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Password';
                              }
                              return null;
                            },
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                          ),
                          TextFormField(
                            controller: usernameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Username';
                              }
                              return null;
                            },
                            decoration:
                                const InputDecoration(labelText: 'Username'),
                          ),
                          TextFormField(
                            controller: phoneNoController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Phone No';
                              }
                              return null;
                            },
                            decoration:
                                const InputDecoration(labelText: 'Phone No'),
                          )
                        ],
                ),
              ),
              Gap(!_logState ? 50 : 110),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(2.0, 7.0),
                              blurRadius: 30.0,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100]),
                          child: Text(
                            _logTextButton,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          onPressed: () {
                            if (_logState) {
                              if (emailController.text.isNotEmpty &&
                                  passwordController.text.isNotEmpty) {
                                User thisUser = User.login(
                                    email: emailController.text,
                                    password: passwordController.text,
                                    phoneNo: "");
                                bool grantAccess = false;
                                User anotherTemp = thisUser;
                                for (User tempUser in _users) {
                                  (anotherTemp, grantAccess) = thisUser.auth(
                                      thisUser.email,
                                      thisUser.password,
                                      tempUser);
                                  if (grantAccess) break;
                                }
                                if (grantAccess) {
                                  ScaffoldMessenger.of(context).showSnackBar(util.showSnackBar(context, "${anotherTemp.userName} Logged in Successfully", "", (){}));

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(user: anotherTemp),
                                    ),
                                  );
                                }else{
                                  ScaffoldMessenger.of(context).showSnackBar(util.showSnackBar(context, "${thisUser.email}, is not signed up yet", "", (){}));

                                }
                              }
                            } else {
                              if (emailController.text.isNotEmpty &&
                                  passwordController.text.isNotEmpty &&
                                  usernameController.text.isNotEmpty) {
                                User newUser = User(
                                    email: emailController.text,
                                    username: usernameController.text,
                                    password: passwordController.text,
                                    phoneNo: phoneNoController.text);
                                bool checkBeforeAdding =
                                    newUser.checkUser(logingProvider.userList);
                                print(
                                    "#Debug auth_screen.dart -> users return value = $checkBeforeAdding");
                                if (checkBeforeAdding) {
                                  ScaffoldMessenger.of(context).showSnackBar(util.showSnackBar(context, "${newUser.email} Already Registered..", "OK", (){}));

                                } else {
                                  logingProvider.addUser(newUser);
                                  print(
                                      "#Debug auth_screen.dart -> users number = ${logingProvider.userList.length}");
                                  print(
                                      "#Debug auth_screen.dart -> users number(local) = ${_users.length}");
                                  ScaffoldMessenger.of(context).showSnackBar(util.showSnackBar(context, "${newUser.userName} Signed up Successfully", "", (){}));

                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) {
                                    return HomeScreen(
                                      user: newUser,
                                    );
                                  }));
                                }
                              }
                            }
                          },
                        ),
                      ),
                      Gap(!_logState ? 100 : 50),
                      TextButton(
                        child: RichText(
                          text: TextSpan(
                            text: _logScript,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold),
                            children: <TextSpan>[
                              TextSpan(
                                text: _logText,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _logState = !_logState;
                            _logTextButton = (_logState) ? "Login" : "Sign Up";
                            _logText = (!_logState) ? "Login" : "Sign Up";
                            _logScript = (!_logState)
                                ? 'Already have an account '
                                : 'Become a member and ';
                            usernameController.text ="";
                            phoneNoController.text = "";
                          });
                        },
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
