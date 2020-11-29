import 'package:flutter/material.dart';
import 'package:smsretriever/data/retrieve_sms.dart';
import 'package:smsretriever/models/custom_message.dart';
import 'package:smsretriever/views/helper_widgets/app_loader.dart';
import 'package:smsretriever/views/helper_widgets/list_messages_view.dart';
import 'package:smsretriever/views/helper_widgets/no_results.dart';

class SentMessagesView extends StatefulWidget {
  @override
  _SentMessagesViewState createState() => _SentMessagesViewState();
}

class _SentMessagesViewState extends State<SentMessagesView> {
  Future<List<CustomMessage>> displayMessages;

  Future<List<CustomMessage>> retrieveMessages() async {
    setState(() {
      displayMessages = SmsRetriever().fetchSentMessages();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sent'),
      ),
      body: FutureBuilder<List<CustomMessage>>(
        future: displayMessages,
        builder: (BuildContext context,
            AsyncSnapshot<List<CustomMessage>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AppLoader();
          }
          if (snapshot.connectionState == ConnectionState.done &&
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
