import 'package:flutter/material.dart';
import 'package:lost_and_founds_simple/providers/app_provider.dart';
import 'package:lost_and_founds_simple/screens/auth_screen.dart';
import 'package:lost_and_founds_simple/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'Lost & Found',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthScreen(),
      ),
    ),
  );
}
