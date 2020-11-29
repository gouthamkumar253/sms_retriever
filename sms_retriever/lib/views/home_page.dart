import 'package:flutter/material.dart';
import 'package:smsretriever/views/nav_bar_children/inbox_view.dart';
import 'package:smsretriever/views/nav_bar_children/sent_view.dart';
import 'package:smsretriever/views/nav_bar_children/tagged_messages_view.dart';
import 'package:smsretriever/views/nav_bar_children/transaction_view.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;

  List<Widget> children;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    children = <Widget>[
      InboxMessagesView(),
      SentMessagesView(),
      TransactionMessagesView(),
      TaggedMessagesView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: children[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _navigationTapHandler,
        unselectedItemColor: Colors.black.withOpacity(0.75),
        showUnselectedLabels: true,
        selectedItemColor: Colors.blueAccent,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text('Inbox'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send),
            title: Text('Sent'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            title: Text('Transactional'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark),
            title: Text('Tags'),
          ),
        ],
      ),
    );
  }

  void _navigationTapHandler(int value) {
    setState(() {
      currentIndex = value;
    });
  }
}
