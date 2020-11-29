import 'package:flutter/material.dart';
import 'package:smsretriever/data/retrieve_sms.dart';
import 'package:smsretriever/models/custom_message.dart';
import 'package:smsretriever/utils/app_constants.dart';
import 'package:smsretriever/views/helper_widgets/app_loader.dart';
import 'package:smsretriever/views/helper_widgets/list_messages_view.dart';
import 'package:smsretriever/views/helper_widgets/no_results.dart';
import 'package:smsretriever/views/nav_bar_children/transaction_statistics.dart';

class TransactionMessagesView extends StatefulWidget {
  @override
  _TransactionMessagesViewState createState() =>
      _TransactionMessagesViewState();
}

class _TransactionMessagesViewState extends State<TransactionMessagesView>
    with SingleTickerProviderStateMixin {
  Future<Map<String, List<CustomMessage>>> displayMessages;
  TabController _tabController;
  int _currentTabIndex = 0;

  Future<Map<String, List<CustomMessage>>> retrieveMessages() async {
    setState(() {
      displayMessages = SmsRetriever().fetchTransactionalMessages();
    });
    return displayMessages;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    displayMessages = retrieveMessages();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              elevation: 2,
              child: TabBar(
                onTap: _tabChangeHandler,
                controller: _tabController,
                labelColor: Colors.blueAccent,
                unselectedLabelColor: Colors.black.withOpacity(0.5),
                tabs: <Widget>[
                  Tab(
                    child: Text('Income'),
                  ),
                  Tab(
                    child: Text('Expenses'),
                  ),
                  Tab(
                    child: Text('Statistics'),
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder<Map<String, List<CustomMessage>>>(
            future: displayMessages,
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, List<CustomMessage>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return AppLoader();
              }
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data.isNotEmpty) {
                if (_currentTabIndex == 0) {
                  if (snapshot.data[AppConstants.income].isNotEmpty) {
                    return Expanded(
                      child: ListMessages(
                        messages: snapshot.data[AppConstants.income],
                        refreshCallback: retrieveMessages,
                      ),
                    );
                  }
                } else if (_currentTabIndex == 1) {
                  if (snapshot.data[AppConstants.expense].isNotEmpty) {
                    return Expanded(
                      child: ListMessages(
                        messages: snapshot.data[AppConstants.expense],
                        refreshCallback: retrieveMessages,
                      ),
                    );
                  }
                } else {
                  return TransactionStatistics(statisticsData: snapshot.data);
                }
              }
              return NoResults();
            },
          ),
        ],
      ),
    );
  }

  void _tabChangeHandler(int value) {
    setState(() {
      _currentTabIndex = value;
    });
  }
}
