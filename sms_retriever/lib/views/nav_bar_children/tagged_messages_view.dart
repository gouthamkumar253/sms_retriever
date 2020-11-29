import 'package:flutter/material.dart';
import 'package:smsretriever/data/retrieve_sms.dart';
import 'package:smsretriever/models/custom_message.dart';
import 'package:smsretriever/views/helper_widgets/list_messages_view.dart';
import 'package:smsretriever/views/helper_widgets/no_results.dart';

import '../helper_widgets/app_loader.dart';

class TaggedMessagesView extends StatefulWidget {
  @override
  _TaggedMessagesViewState createState() => _TaggedMessagesViewState();
}

class _TaggedMessagesViewState extends State<TaggedMessagesView> {
  Future<List<CustomMessage>> displayMessages;
  List<CustomMessage> _totalList;
  List<CustomMessage> _filterList;

  final TextEditingController _searchController = TextEditingController();

  Future<List<CustomMessage>> retrieveMessages() async {
    _totalList = await SmsRetriever().fetchTaggedMessages();
    _filterList = _totalList;
    setState(() {});
    return _totalList;
  }

  Future<List<String>> retrieveTags() async {
    return await SmsRetriever().fetchTags();
  }

  void _searchTag(String searchQuery) {
    _filterList = <CustomMessage>[];
    if (searchQuery.isEmpty) {
      _filterList = _totalList;
      return;
    }
    for (CustomMessage message in _totalList) {
      if (message.tag.toLowerCase().contains(searchQuery.toLowerCase())) {
        setState(() {
          _filterList.add(message);
        });
      }
    }
    if (_filterList.isEmpty) {
      setState(() {
        _filterList = <CustomMessage>[];
      });
    }
    return;
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
        title: Text('Tagged Messages'),
      ),
      body: InkWell(
        onTap: () {
          setState(() {
            FocusScope.of(context).unfocus();
          });
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (text) => _searchTag(text),
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.text = '';
                      setState(() {
                        _filterList = _totalList;
                        FocusScope.of(context).unfocus();
                      });
                    },
                  ),
                  hintText: 'Search',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 3.1, color: Colors.red),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<CustomMessage>>(
                future: displayMessages,
                builder: (BuildContext context,
                    AsyncSnapshot<List<CustomMessage>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return AppLoader();
                  }
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data.isNotEmpty) {
                    return _filterList.isEmpty
                        ? NoResults()
                        : ListMessages(
                            messages: _filterList,
                            refreshCallback: retrieveMessages,
                          );
                  }
                  return NoResults();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
