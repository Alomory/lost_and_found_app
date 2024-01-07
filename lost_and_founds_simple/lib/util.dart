import 'package:flutter/material.dart';

SnackBar showSnackBar(context, String message, String response, Function method){
  return SnackBar(
    content:  Text(message),
    action: SnackBarAction(
      label: 'OK',
      onPressed: () => method,
    ),
  );
}