

import 'package:flutter/material.dart';
import 'package:lost_and_founds_simple/data/list_of_items_dummy.dart';
import 'package:lost_and_founds_simple/screens/auth_screen.dart';
import 'package:provider/provider.dart';

void main() {  
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => ListOfItems())],
    child:  MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: './',
      routes: {
        './': (context) => const AuthScreen(),
      },
    ),
  ));
}
