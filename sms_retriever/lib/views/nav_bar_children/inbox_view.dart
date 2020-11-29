import 'package:flutter/material.dart';
import 'package:smsretriever/data/retrieve_sms.dart';
import 'package:smsretriever/models/custom_message.dart';
import 'package:smsretriever/views/helper_widgets/list_messages_view.dart';
import 'package:smsretriever/views/helper_widgets/no_results.dart';

import '../helper_widgets/app_loader.dart';

class InboxMessagesView extends StatefulWidget {
  @override
  _InboxMessagesViewState createState() => _InboxMessagesViewState();
}

class _InboxMessagesViewState extends State<InboxMessagesView> {
  Future<List<CustomMessage>> displayMessages;

  Future<List<CustomMessage>> retrieveMessages() async {
    setState(() {
      displayMessages = SmsRetriever().fetchInboxMessage();
    });
    return displayMessages;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    displayMessages = retrieveMessages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox'),
      ),
      body: FutureBuilder<List<CustomMessage>>(
        future: displayMessages,
        builder: (BuildContext context,
            AsyncSnapshot<List<CustomMessage>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AppLoader();
          }
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null &&
              snapshot.data.isNotEmpty) {
            return ListMessages(
              messages: snapshot.data,
              refreshCallback: retrieveMessages,
            );
          }
          return NoResults();
        },
      ),
    );
  }
}
