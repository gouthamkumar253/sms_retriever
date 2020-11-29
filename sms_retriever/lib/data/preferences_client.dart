import 'package:shared_preferences/shared_preferences.dart';
import 'package:smsretriever/models/custom_message.dart';

class PreferencesClient {
  PreferencesClient({this.prefs});

  final SharedPreferences prefs;
  static const String _inboxMessages = 'inbox_message';
  CustomMessagesList inboxJsonList = CustomMessagesList();

  CustomMessagesList getInboxMessages() {
    final String inboxMessages = prefs.getString(_inboxMessages);
    if (inboxMessages == null) {
      return null;
    }
    return CustomMessagesList.fromRawJson(inboxMessages);
  }

  void saveTaggedInboxMessages(CustomMessage taggedMessage) {
    inboxJsonList = getInboxMessages() ??
        CustomMessagesList(customMessages: <CustomMessage>[]);
    inboxJsonList.customMessages.add(taggedMessage);
    prefs.setString(_inboxMessages, inboxJsonList.toRawJson());
  }
}
