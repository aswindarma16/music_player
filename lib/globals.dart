import 'dart:io';
import 'package:flutter/material.dart';

CircularProgressIndicator loadingProgressIndicator = const CircularProgressIndicator();

Widget defaultErrorWidget(Function tryAgainButtonFunction) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(
          Icons.error,
          size: 48.0,
          color: Colors.red,
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
        const Text(
          "Oops, something went wrong, please try again!",
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
        MaterialButton(
          color: Colors.red,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: const BorderSide(color: Colors.red)
          ),
          onPressed: () {
            tryAgainButtonFunction();
          },
          child: const Text(
            "Try again",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0
            ),
          ),
        )
      ],
    ),
  );
}

onWillPopExit(BuildContext pageContext, bool availableToPop) {
  return availableToPop ? Future.value(true) : showDialog(
    context: pageContext,
    builder: (context) => AlertDialog(
      title: const Text("Are you sure?"),
      content: const Text("Do you want to exit this app?"),
      actions: <Widget>[
        MaterialButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
        MaterialButton(
          onPressed: () => exit(0),
          child: const Text('Yes'),
        ),
      ],
    ),
  );
}