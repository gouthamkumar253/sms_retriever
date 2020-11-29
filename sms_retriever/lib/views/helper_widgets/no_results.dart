import 'package:flutter/material.dart';

class NoResults extends StatelessWidget {
  const NoResults({Key key, this.message, this.height}) : super(key: key);

  final String message;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/no_messages.png'),
            Text(message ?? 'No messages to display'),
          ].map((Widget child) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: child,
            );
          }).toList(),
        ),
      ),
    );
  }
}
